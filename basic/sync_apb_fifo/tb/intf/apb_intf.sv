interface apb_intf #(
   parameter ADDR_WIDTH = 32
  ,parameter DATA_WIDTH = 32
)(
   input pclk
  ,input presetn
);
  
  logic [ADDR_WIDTH-1:0]  paddr;
  logic                   psel;
  logic                   penable;
  logic                   pwrite;
  logic [DATA_WIDTH-1:0]  pwdata;
  logic [DATA_WIDTH-1:0]  prdata;
  logic                   pready;
  logic                   pslverr;

  clocking drv_cb @(posedge pclk);
    default input #1step output #1ns;
    output paddr, psel, penable, pwrite, pwdata;
    input prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1step output #1ns;
    input paddr, psel, penable, pwrite, pwdata;
    input prdata, pready, pslverr;
  endclocking

  modport master(
     input pclk
    ,input presetn
    ,clocking drv_cb 
  );

  modport monitor(
     input pclk
    ,input presetn
    ,clocking mon_cb 
  );

endinterface
