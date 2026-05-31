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
  
  sync_fifo #(
     .DATA_WIDTH(DATA_WIDTH)
    ,.DEPTH(DEPTH)
  ) dut (
     .clk     (clk            )
    ,.rst_n   (rst_n          )   
    ,.wr_en   (intf.wr_en     )       
    ,.wr_data (intf.wr_data   )   
    ,.full    (intf.full      )   
    ,.rd_en   (intf.rd_en     )   
    ,.rd_data (intf.rd_data   ) 
    ,.empty   (intf.empty     ) 
  );
  
  // uvm config
  initial begin
    //uvm_config_db#(virtual sync_fifo_intf)::set(null, "uvm_test_top.env.wr_agt","vif",intf);
    //uvm_config_db#(virtual sync_fifo_intf)::set(null, "uvm_test_top.env.rd_agt","vif",intf);
    uvm_config_db#(virtual sync_fifo_intf)::set(null, "uvm_test_top.env.*","vif",intf);
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
