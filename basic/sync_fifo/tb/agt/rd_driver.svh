class rd_driver extends uvm_driver #(rd_transaction);
  `uvm_component_utils(rd_driver)
  virtual sync_fifo_intf vintf;

  function new (string name = "rd_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task init_signal();
    vintf.rd_en = 0;
    wait(vintf.rst_n == 1);
    @(vintf.rd_cb); // note this line 
  endtask

  task drive_one_pkt();
    rd_transaction req;
    //1. get from seq
    seq_item_port.get_next_item(req);
    
    //2. idle
    repeat(req.idle_cycles) begin
      vintf.rd_cb.rd_en <= 0;
      @(vintf.rd_cb);
    end

    //3. send
    vintf.rd_cb.rd_en <= 1;
    @(vintf.rd_cb);
    vintf.rd_cb.rd_en <= 0;

    //4. tell seq
    seq_item_port.item_done();
  endtask


  task run_phase(uvm_phase phase);
    init_signal();
    forever begin
      drive_one_pkt();    
    end
  endtask


endclass
