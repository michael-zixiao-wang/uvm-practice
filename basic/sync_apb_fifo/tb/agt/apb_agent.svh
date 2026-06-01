class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  
  apb_monitor mon;
  apb_driver drv;
  apb_sequencer sqr;
  
  uvm_analysis_port#(apb_transaction) ap;

  function new(string name = "apb_agt", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = apb_monitor::type_id::create("mon",this);
    ap = new("ap", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = apb_sequencer::type_id::create("sqr",this);
      drv = apb_driver::type_id::create("drv",this);
    end
  endfunction
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //ap.connect(mon.ap); // this is a bug
    mon.ap.connect(ap); 
    if( get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction

endclass
