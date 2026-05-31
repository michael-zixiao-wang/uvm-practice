class sync_fifo_cov_collector extends uvm_component;
  `uvm_component_utils(sync_fifo_cov_collector)
  `uvm_analysis_imp_decl(_wr)
  `uvm_analysis_imp_decl(_rd)
  
  uvm_analysis_imp_wr #(wr_transaction, sync_fifo_cov_collector) wr_imp;
  uvm_analysis_imp_rd #(rd_transaction, sync_fifo_cov_collector) rd_imp;

  virtual sync_fifo_intf vintf;

  fifo_wr_cov_obj wr_cov_obj;
  fifo_rd_cov_obj rd_cov_obj;
  fifo_sys_cov_obj sys_cov_obj;

  function new(string name = "cov", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  
    wr_cov_obj = fifo_wr_cov_obj::type_id::create("wr_cov_obj");
    rd_cov_obj = fifo_rd_cov_obj::type_id::create("rd_cov_obj");
    sys_cov_obj = fifo_sys_cov_obj::type_id::create("sys_cov_obj");

    if(!uvm_config_db#(virtual sync_fifo_intf)::get(this,"","vif",vintf))
      `uvm_fatal(get_name(), "vintf is not set!")

  endfunction

  virtual function void write_wr(wr_transaction tr);
    wr_cov_obj.cg_fifo_write.sample(tr);
  endfunction
  
  virtual function void write_rd(rd_transaction tr);
    rd_cov_obj.cg_fifo_read.sample(tr);
  endfunction

  task run_phase(uvm_phase phase);
    wait(vintf.rst_n == 1);
    forever begin
      @(vintf.mon_cb);
      sys_cov_obj.cg_fifo_sys.sample(
        vintf.mon_cb.wr_en,
        vintf.mon_cb.rd_en,
        vintf.mon_cb.full,
        vintf.mon_cb.empty  
      );
    end
  endtask
  
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
    `uvm_info("COV_REPORT", "           FUNCTIONAL COVERAGE REPORT             ", UVM_NONE)
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)

    // 打印单个 Covergroup 的覆盖率
    `uvm_info("COV_REPORT", $sformatf("  Write Channel Coverage : %6.2f %%", wr_cov_obj.cg_fifo_write.get_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("  Read  Channel Coverage : %6.2f %%", rd_cov_obj.cg_fifo_read.get_coverage()), UVM_NONE)

    `uvm_info("COV_REPORT", "--------------------------------------------------", UVM_NONE)
    // $get_coverage() 是系统函数，会计算所有 covergroup 的总平均分
    `uvm_info("COV_REPORT", $sformatf("  OVERALL FIFO COVERAGE  : %6.2f %%", $get_coverage()), UVM_NONE)
    `uvm_info("COV_REPORT", "==================================================", UVM_NONE)
  endfunction

endclass
