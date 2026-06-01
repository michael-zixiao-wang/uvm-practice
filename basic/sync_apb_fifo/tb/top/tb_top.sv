import uvm_pkg::*;
`include "uvm_macros.svh"
import fifo_test_pkg::*;
module tb_top();
  // signals
  localparam PERIOD = 20;
  bit clk, rst_n;
 
  // dut inst 
  localparam DATA_WIDTH = 32, DEPTH = 16;
  sync_fifo_intf #(
     .DATA_WIDTH(DATA_WIDTH)
    ,.DEPTH(DEPTH)
  ) intf (
     .clk   (clk    )
    ,.rst_n (rst_n  )
  );
 
  localparam ADDR_WIDTH = 32; 
  apb_intf #(
     .DATA_WIDTH(DATA_WIDTH)
    ,.ADDR_WIDTH(ADDR_WIDTH)
  ) apb_intf (
     .pclk    (clk    )
    ,.presetn (rst_n  )
  );

  sync_apb_fifo #(
     .DATA_WIDTH(DATA_WIDTH)
    ,.DEPTH(DEPTH)
  ) dut (
     .clk         (clk              )
    ,.rst_n       (rst_n            )   
    ,.wr_en       (intf.wr_en       )       
    ,.wr_data     (intf.wr_data     )   
    ,.full        (intf.full        )   
    ,.almost_full (intf.almost_full )   
    ,.rd_en       (intf.rd_en       )   
    ,.rd_data     (intf.rd_data     ) 
    ,.empty       (intf.empty       ) 
    ,.almost_empty(intf.almost_empty) 
    ,.fifo_int    (intf.fifo_int    ) 
    ,.paddr       (apb_intf.paddr   )   
    ,.psel        (apb_intf.psel    )   
    ,.penable     (apb_intf.penable )     
    ,.pwrite      (apb_intf.pwrite  )   
    ,.pwdata      (apb_intf.pwdata  ) 
    ,.prdata      (apb_intf.prdata  ) 
    ,.pready      (apb_intf.pready  ) 
  
  );
  
  // uvm config
  initial begin
    uvm_config_db#(virtual sync_fifo_intf)::set(null, "uvm_test_top.env.*","vif",intf);
    uvm_config_db#(virtual apb_intf)::set(null, "uvm_test_top.env.*","vif",apb_intf);
    run_test();
  end    

  // clock gen
  initial begin
    clk = 0;
    forever #(PERIOD / 2) clk = ~clk;
  end
    
  initial begin
    rst_n = 0;
    #200 rst_n = 1;
  end

endmodule
