class apb_driver extends uvm_driver #(apb_transaction);
  `uvm_component_utils(apb_driver)
  
  virtual apb_intf vif;

  function new (string name = "apb_drv", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif))
      `uvm_fatal(get_name(),"vif is not set yet");
  endfunction

  task run_phase(uvm_phase phase);
    reset_bus();
    forever begin
      seq_item_port.get_next_item(req);
      drive_one_packet(req);
      seq_item_port.item_done();
    end
  endtask

  task reset_bus();
    vif.psel = 0;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = '0;
    vif.pwdata = '0;
    wait(vif.presetn === 1'b1);
    @(vif.drv_cb); // note this line
  endtask

  task drive_one_packet(apb_transaction tr);
    `uvm_info(get_name(),"get one new transaction",UVM_HIGH);
    tr.print();
    repeat(tr.idle_cycles)begin
      @(vif.drv_cb);
    end
    // setup phase
    vif.drv_cb.psel <= 1'b1;
    vif.drv_cb.paddr <= tr.addr;
    vif.drv_cb.pwrite <= (tr.kind == apb_transaction::APB_WRITE) ? 1'b1 : 1'b0;
    if(tr.kind == apb_transaction::APB_WRITE) begin
      vif.drv_cb.pwdata <= tr.data;
    end
    @(vif.drv_cb);

    // access phase
    vif.drv_cb.penable <= 1'b1;
    @(vif.drv_cb);

    // wait ready
    wait(vif.drv_cb.pready === 1'b1);
    //wait(vif.pready === 1'b1); // note this line is also right but not good
    if(tr.kind == apb_transaction::APB_READ)begin
      tr.data = vif.drv_cb.prdata;
    end
    tr.slverr = vif.drv_cb.pslverr;

    // idle
    vif.drv_cb.psel <= 1'b0;
    vif.drv_cb.penable <= 1'b0;

  endtask

endclass
