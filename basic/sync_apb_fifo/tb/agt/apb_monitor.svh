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
    forever begin
      @(vif.mon_cb); // go to next cycle
      if( vif.mon_cb.pready === 1'b1 && 
          vif.mon_cb.penable === 1'b1 && 
          vif.mon_cb.psel === 1'b1) begin
        // wait will cause bug
        // wait( vif.mon_cb.pready === 1'b1 && 
        //       vif.mon_cb.penable === 1'b1 && 
        //       vif.mon_cb.psel === 1'b1);
        tr = apb_transaction::type_id::create("tr"); 
        tr.addr = vif.mon_cb.paddr;
        tr.slverr = vif.mon_cb.pslverr;    
        if(vif.mon_cb.pwrite === 1'b1) begin
          tr.kind = apb_transaction::APB_WRITE;
          tr.data = vif.mon_cb.pwdata;
        end else if(vif.mon_cb.pwrite === 1'b0)begin
          tr.kind = apb_transaction::APB_READ;
          tr.data = vif.mon_cb.prdata;
        end     
        `uvm_info(get_name(), $sformatf("mon one transaction:\n%s", tr.sprint()), UVM_HIGH)
        ap.write(tr);
      end
    end
  endtask
endclass
