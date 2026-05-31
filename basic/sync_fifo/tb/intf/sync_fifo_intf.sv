interface sync_fifo_intf #(
   parameter DATA_WIDTH = 32
  ,parameter DEPTH = 16
)(
   input wire clk
  ,input wire rst_n);

  // signals
  logic wr_en,rd_en;
  logic [DATA_WIDTH-1:0] wr_data, rd_data;
  logic full, empty;

  // clocking block: note the direction is op
  clocking wr_cb @(posedge clk);
    default input #1step output #1ns;
    output wr_en, wr_data;  // to dut
    input full;             // from dut
  endclocking

  clocking rd_cb @(posedge clk);
    default input #1step output #1ns;
    output rd_en;
    input rd_data, empty;
  endclocking

  clocking wr_mon_cb @(posedge clk);
    default input #1step output #1ns;
    input wr_en, wr_data, full;  
  endclocking

  clocking rd_mon_cb @(posedge clk);
    default input #1step output #1ns;
    input rd_data, empty, rd_en;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #1ns;
    input rd_data, empty, rd_en;
    input wr_en, wr_data, full;  
  endclocking

  // modport
  modport wr_master(
     input clk
    ,input rst_n
    ,clocking wr_cb
  );

  modport rd_master(
     input clk
    ,input rst_n
    ,clocking rd_cb
  );


endinterface


