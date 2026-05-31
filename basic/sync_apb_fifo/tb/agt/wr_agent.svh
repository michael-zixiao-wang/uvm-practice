class wr_agent extends uvm_agent;
  `uvm_component_utils(wr_agent)

  wr_sequencer sqr;
  wr_driver    drv;
  wr_monitor   mon;

  uvm_analysis_port#(wr_transaction) ap;

  virtual sync_fifo_intf vintf;

  function new (string name = "wr_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = wr_monitor::type_id::create("wr_mon",this);
    ap = new("ap", this);
    if(get_is_active() == UVM_ACTIVE) begin
      sqr = wr_sequencer::type_id::create("wr_sqr",this);
      drv = wr_driver::type_id::create("wr_drv",this);
    end
    
    if(!uvm_config_db#(virtual sync_fifo_intf)::get(this,"","vif",vintf))
      `uvm_fatal(get_type_name(),"vintf is not set by config_db")
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //0.int
    drv.vintf = this.vintf;
    mon.vintf = this.vintf;
    //1. mon
    mon.ap.connect(this.ap);
    //2. sqr
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(this.sqr.seq_item_export);
    end
  endfunction
endclass

