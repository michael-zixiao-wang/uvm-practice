class sync_fifo_env extends uvm_env;
  `uvm_component_utils(sync_fifo_env)
  wr_agent wr_agt;
  rd_agent rd_agt;
  apb_agent apb_agt;
  int_monitor int_mon; 

  sync_fifo_sb sb;
  sync_fifo_model mdl;  
  sync_fifo_vsqr vsqr;

  sync_fifo_cov_collector clct;

  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_agt = wr_agent::type_id::create("wr_agt", this);
    rd_agt = rd_agent::type_id::create("rd_agt", this);
    wr_agt.is_active = UVM_ACTIVE;
    rd_agt.is_active = UVM_ACTIVE;
    vsqr = sync_fifo_vsqr::type_id::create("vsqr", this);
    mdl = sync_fifo_model::type_id::create("mdl", this);
    sb = sync_fifo_sb::type_id::create("sb", this);
    clct = sync_fifo_cov_collector::type_id::create("clct", this);
    int_mon = int_monitor::type_id::create("int_mon", this);
    apb_agt = apb_agent::type_id::create("apb_agt", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(wr_agt.get_is_active() == UVM_ACTIVE)
      vsqr.wr_sqr = wr_agt.sqr;
    if(rd_agt.get_is_active() == UVM_ACTIVE)
      vsqr.rd_sqr = rd_agt.sqr;
    if(apb_agt.get_is_active() == UVM_ACTIVE)
      vsqr.apb_sqr = apb_agt.sqr;
    
    wr_agt.mon.ap.connect(mdl.wr_imp);
    rd_agt.mon.ap.connect(mdl.rd_imp);

    wr_agt.mon.ap.connect(clct.wr_imp);
    rd_agt.mon.ap.connect(clct.rd_imp);

    wr_agt.mon.ap.connect(sb.act_wr_fifo.analysis_export);
    rd_agt.mon.ap.connect(sb.act_rd_fifo.analysis_export);
 
    mdl.wr_ap.connect(sb.exp_wr_fifo.analysis_export);
    mdl.rd_ap.connect(sb.exp_rd_fifo.analysis_export); 
  endfunction

endclass
