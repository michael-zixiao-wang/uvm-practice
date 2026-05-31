class rd_agent extends uvm_agent;
  `uvm_component_utils(rd_agent)

  rd_monitor mon;
  rd_sequencer sqr;
  rd_driver drv;

  virtual sync_fifo_intf vintf;
  uvm_analysis_port #(rd_transaction) ap;

  function new(string name = "rd_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = rd_monitor::type_id::create("rd_mon", this);
    if(get_is_active() == UVM_ACTIVE)begin
      drv = rd_driver::type_id::create("rd_drv", this);
      sqr = rd_sequencer::type_id::create("rd_sqr", this);
    end
    if(!uvm_config_db#(virtual sync_fifo_intf)::get(this,"","vif",vintf))
      `uvm_fatal(get_name(), "vintf is not set!")
    ap = new("ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon.ap.connect(this.ap);
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
      drv.vintf = this.vintf;
      mon.vintf = this.vintf;
    end
  endfunction
endclass
