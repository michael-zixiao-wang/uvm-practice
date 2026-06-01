class sanity_vseq extends base_vseq;
  `uvm_object_utils(sanity_vseq)
  
  function new(string name = "sanity_vseq");
    super.new(name);
  endfunction

  virtual task body();
    apb_transaction apb_tr;
    wr_transaction  wr_tr;
    rd_transaction  rd_tr;

    `uvm_info("get_name()", "========================================", UVM_LOW)
    `uvm_info("get_name()", "       Start Sanity Smoke Test          ", UVM_LOW)
    `uvm_info("get_name()", "========================================", UVM_LOW)

    // 第一步：控制面配置 (通过 APB 唤醒 FIFO)
    `uvm_info("get_name()", "[STEP 1] Configuring FIFO via APB...", UVM_LOW)
    // 向 0x00 (FIFO_CTRL) 写入 1，使能 FIFO
    `uvm_info("get_name()", "enable fifo by fifo ctrl", UVM_LOW)
    `uvm_do_on_with(apb_tr, p_sequencer.apb_sqr, {
      kind == apb_transaction::APB_WRITE;
      addr == 32'h0000_0000; 
      data == 32'h0000_0001; 
    })
    // 向 0x08 (WATERMARK) 写入阈值 (Almost Full=10, Almost Empty=5)
    `uvm_info("get_name()", "rewrite watermark", UVM_LOW)
    `uvm_do_on_with(apb_tr, p_sequencer.apb_sqr, {
      kind == apb_transaction::APB_WRITE;
      addr == 32'h0000_0008; 
      data == 32'h0000_A005; 
    })

    // 第二步：数据面激励 (写满再读空)
    `uvm_info("get_name()", "[STEP 2] Driving Data Path...", UVM_LOW)
    // 连续写入 5 个随机数据
    `uvm_info("get_name()", "Writing 5 items...", UVM_LOW)
    for(int i = 0; i < 5; i++) begin
      `uvm_do_on(wr_tr, p_sequencer.wr_sqr)
    end
    // 稍微延迟一下，模拟真实的系统节拍
    #50ns;
    // 连续读取 3 个数据
    `uvm_info("get_name()", "Reading 3 items...", UVM_LOW)
    for(int i = 0; i < 3; i++) begin
      `uvm_do_on(rd_tr, p_sequencer.rd_sqr)
    end
    
    // 第三步：控制面状态检查 (裸读寄存器)
    `uvm_info("get_name()", "[STEP 3] Checking Status via APB...", UVM_LOW)
    // 读取 0x04 (FIFO_STAT) 寄存器，看看 FIFO 现在的状态
    `uvm_do_on_with(apb_tr, p_sequencer.apb_sqr, {
      kind == apb_transaction::APB_READ;
      addr == 32'h0000_0004; 
    })
    // 打印从 APB 读回来的状态数据 (写了5个，读了3个，此时 count 应该是 2)
    `uvm_info("get_name()", $sformatf("Read FIFO_STAT (0x04) Value = 'h%08x", apb_tr.data), UVM_LOW)
    `uvm_info("get_name()", "========================================", UVM_LOW)
    `uvm_info("get_name()", "       Smoke Test Finished              ", UVM_LOW)
    `uvm_info("get_name()", "========================================", UVM_LOW)
  endtask
endclass

class sanity_test extends base_test;
  `uvm_component_utils(sanity_test)
  function new(string name = "sanity_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,"env.vsqr.run_phase","default_sequence",sanity_vseq::type_id::get());
  endfunction


endclass
