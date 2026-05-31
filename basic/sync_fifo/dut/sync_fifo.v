module sync_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,
    input  wire                  rd_en,
    output wire [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [4:0] count; // 针对 DEPTH=16，计数器需要 5 bit
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // 写逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // 读逻辑 (读出具有一拍延迟，表现为寄存器输出)
    reg [DATA_WIDTH-1:0] rd_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data_reg <= 0;
        end else if (rd_en && !empty) begin
            rd_data_reg <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end
    assign rd_data = rd_data_reg;

    // 计数逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end
endmodule
