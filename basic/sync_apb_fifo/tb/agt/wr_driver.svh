class wr_driver extends uvm_driver #(wr_transaction);
  `uvm_component_utils(wr_driver)

  virtual sync_fifo_intf vintf; // note this line
  
  function new(string name = "wr_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
   // if(!uvm_config_db#(virtual sync_fifo_intf)::get(this,"","vif",vintf))
   //   `uvm_fatal(get_name(),"no vif is set in uvm_config_db");
  endfunction
  
  // run phase
  task init_signal;
    vintf.wr_en = 0;
    vintf.wr_data  = 0;
    wait (vintf.rst_n == 1);
    @(vintf.wr_cb); // note this line
  endtask

  task drive_one_pkt;
    // 1. get one pkt from sqr
    seq_item_port.get_next_item(req); // seq_item_port is a member var
    `uvm_info(get_name(),$sformatf("get one req to write to fifo:\n%s",req.sprint()),UVM_HIGH) 

    // 2. handle the idle
    repeat(req.idle_cycles) begin
      vintf.wr_cb.wr_en <= 1'b0;
      @(vintf.wr_cb);
    end

    // 3. write one data
    vintf.wr_cb.wr_en <= 1'b1;
    vintf.wr_cb.wr_data <= req.data;
    @(vintf.wr_cb);
   
    vintf.wr_cb.wr_en <= 1'b0;
     
    
    // 4. tell the sqr
    seq_item_port.item_done();
  endtask

  task run_phase (uvm_phase phase);
    init_signal();
    forever begin
      drive_one_pkt();
    end

  endtask

endclass
