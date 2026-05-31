class wr_sequencer extends uvm_sequencer #(wr_transaction);
  `uvm_component_utils(wr_sequencer)

  function new (string name = "wr_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction


endclass
