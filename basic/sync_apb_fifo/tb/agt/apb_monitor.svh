class apb_monitor extends uvm_component;
  `uvm_component_utils(apb_monitor)
 
  uvm_analysis_port#(apb_transaction) ap; 
  virtual apb_intf vif;

  function new (string name = "apb_mon", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif))
      `uvm_fatal(get_name(),"vif must be set")
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    apb_transaction tr;
    wait(vif.presetn === 1'b1);
    @(vif.mon_cb);
    forever begin
      wait( vif.pready === 1'b1 && 
            vif.penable === 1'b1 && 
            vif.psel === 1'b1);
      @(vif.mon_cb);
      tr = apb_transaction::type_id::create("tr"); 
      if(vif.mon_cb.pwrite === 1'b1) begin
        tr.kind = apb_transaction::APB_WRITE;
        tr.data = vif.mon_cb.pwdata;
        tr.addr = vif.mon_cb.paddr;
        tr.slverr = vif.mon_cb.pslverr;    
      end else if(vif.mon_cb.pwrite === 1'b0)begin
        tr.kind = apb_transaction::APB_READ;
        tr.data = vif.mon_cb.prdata;
        tr.addr = vif.mon_cb.paddr;
        tr.slverr = vif.mon_cb.pslverr;    
      end     
      ap.write(tr);
    end
  endtask
endclass
