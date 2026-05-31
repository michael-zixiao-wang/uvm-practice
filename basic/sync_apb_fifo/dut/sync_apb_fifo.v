module sync_fifo_apb_top #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
)(
    // 时钟与复位
    input  wire                  clk,
    input  wire                  rst_n,

    // APB 总线接口
    input  wire [31:0]           paddr,
    input  wire                  psel,
    input  wire                  penable,
    input  wire                  pwrite,
    input  wire [31:0]           pwdata,
    output reg  [31:0]           prdata,
    output wire                  pready,

    // FIFO 原有数据端口（受寄存器使能控制）
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full, 
    output wire                  almost_full, 
    input  wire                  rd_en,
    output wire [DATA_WIDTH-1:0] rd_data,
    output wire                  empty, 
    output wire                  almost_empty, 
    
    // 中断输出管脚
    output wire                  fifo_int
);

    // ==========================================================
    // 1. 内部寄存器定义 (CSR)
    // ==========================================================
    reg  [31:0] reg_fifo_ctrl; // 0x00: [0]=fifo_en, [1]=soft_reset (自清零)
    wire [31:0] reg_fifo_stat; // 0x04: 只读 [0]=empty, [1]=full, [6:2]=count
    reg  [31:0] reg_watermark; // 0x08: [3:0]=almost_empty_thr, [7:4]=almost_full_thr
    reg  [31:0] reg_int_en;    // 0x0C: [0]=overflow_en, [1]=underflow_en
    reg  [31:0] reg_int_stat;  // 0x10: [0]=overflow_stat (W1C), [1]=underflow_stat (W1C)

    // 寄存器核心控制信号
    wire fifo_en     = reg_fifo_ctrl[0];
    wire soft_reset  = reg_fifo_ctrl[1];
    wire csr_rst_n   = rst_n && !soft_reset; // 软复位结合硬复位

    // ==========================================================
    // 2. APB 读写自动机
    // ==========================================================
    wire apb_write_req = psel && penable && pwrite;
    wire apb_read_req  = psel && !pwrite; // SETUP 阶段即可准备读数据
    
    assign pready = 1'b1; // FIFO 寄存器响应极快，无需等待周期

    // APB 写逻辑 (支持 RW 和 W1C)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_fifo_ctrl <= 32'h0000_0001; // 默认使能 FIFO
            reg_watermark <= 32'h0000_F102; // 默认几乎满=14, 几乎空=2
            reg_int_en    <= 32'h0000_0000; // 默认关闭中断
        end else if (soft_reset) begin
            reg_fifo_ctrl[1] <= 1'b0;       // soft_reset 释放，自清零
        end else if (apb_write_req) begin
            case (paddr[7:0])
                8'h00: reg_fifo_ctrl <= pwdata;
                8'h08: reg_watermark <= pwdata;
                8'h0C: reg_int_en    <= pwdata;
                default: ;
            endcase
        end
    end

    // APB 读逻辑 (RO)
    always @(*) begin
        if (!rst_n) begin
            prdata = 32'h0;
        end else if (apb_read_req) begin
            case (paddr[7:0])
                8'h00: prdata = reg_fifo_ctrl;
                8'h04: prdata = reg_fifo_stat;
                8'h08: prdata = reg_watermark;
                8'h0C: prdata = reg_int_en;
                8'h10: prdata = reg_int_stat;
                default: prdata = 32'h0;
            endcase
        end else begin
            prdata = 32'h0;
        end
    end

    // ==========================================================
    // 3. FIFO 核心例化逻辑 (与软硬件状态联动)
    // ==========================================================
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [4:0] count; 
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    assign almost_full  = (count >= reg_watermark[7:4]);
    assign almost_empty = (count <= reg_watermark[3:0]);

    // 状态寄存器实时拼接映射 (RO)
    assign reg_fifo_stat = {25'b0, count, full, empty};

    // 实际有效的读写行为：必须在全局使能 (fifo_en) 且未发生异常时
    wire actual_wr = wr_en && fifo_en && !full;
    wire actual_rd = rd_en && fifo_en && !empty;

    // 硬件触发中断状况
    wire hw_overflow  = wr_en && fifo_en && full;
    wire hw_underflow = rd_en && fifo_en && empty;

    // 写逻辑
    always @(posedge clk or negedge csr_rst_n) begin
        if (!csr_rst_n) begin
            wr_ptr <= 0;
        end else if (actual_wr) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // 读逻辑
    reg [DATA_WIDTH-1:0] rd_data_reg;
    always @(posedge clk or negedge csr_rst_n) begin
        if (!csr_rst_n) begin
            rd_ptr <= 0;
            rd_data_reg <= 0;
        end else if (actual_rd) begin
            rd_data_reg <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end
    assign rd_data = rd_data_reg;

    // 计数逻辑
    always @(posedge clk or negedge csr_rst_n) begin
        if (!csr_rst_n) begin
            count <= 0;
        end else begin
            case ({actual_wr, actual_rd})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

    // ==========================================================
    // 4. 中断与 W1C (写 1 清零) 核心逻辑
    // ==========================================================
    // 练习点：当硬件触发异常时置 1；当总线向对应位写 1 时清 0
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_int_stat <= 32'h0;
        end else begin
            // Overflow 中断位处理
            if (hw_overflow) 
                reg_int_stat[0] <= 1'b1; // 硬件置位
            else if (apb_write_req && (paddr[7:0] == 8'h10) && pwdata[0])
                reg_int_stat[0] <= 1'b0; // 软件写 1 清零

            // Underflow 中断位处理
            if (hw_underflow) 
                reg_int_stat[1] <= 1'b1; // 硬件置位
            else if (apb_write_req && (paddr[7:0] == 8'h10) && pwdata[1])
                reg_int_stat[1] <= 1'b0; // 软件写 1 清零
        end
    end

    // 最终中断信号输出：状态位 与 使能位 相与
    assign fifo_int = (reg_int_stat[0] && reg_int_en[0]) || 
                      (reg_int_stat[1] && reg_int_en[1]);

endmodule
