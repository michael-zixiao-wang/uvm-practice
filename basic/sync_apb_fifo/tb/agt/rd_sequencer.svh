class rd_sequencer extends uvm_sequencer #(rd_transaction);
  `uvm_component_utils(rd_sequencer)

  function new (string name = "rd_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
