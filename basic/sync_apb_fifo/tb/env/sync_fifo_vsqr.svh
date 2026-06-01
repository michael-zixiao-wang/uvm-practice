class sync_fifo_vsqr extends uvm_sequencer;
  `uvm_component_utils(sync_fifo_vsqr)
  
  apb_sequencer apb_sqr;
  wr_sequencer wr_sqr;
  rd_sequencer rd_sqr;

  function new (string name = "vsqr", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
