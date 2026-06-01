class int_monitor extends uvm_monitor; // note there is no transaction
  `uvm_component_utils(int_monitor)
  virtual sync_fifo_intf vif;
  uvm_event int_ev; // note this

  function new(string name = "sys_mon", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual sync_fifo_intf)::get(this,"","vif",vif))
      `uvm_fatal(get_name(),"vif must be set");
  endfunction
  
  task run_phase(uvm_phase phase);
    int_ev = uvm_event_pool::get_global("fifo_irq"); // note this line
    wait(vif.rst_n === 1'b1);
    forever begin
      @(vif.int_mon_cb); // step
      if(vif.int_mon_cb.fifo_int === 1'b1)begin
        `uvm_info(get_name(),"hardware interrupt detected",UVM_LOW)
        int_ev.trigger();
        // wait int is done
        while(vif.int_mon_cb.fifo_int === 1'b1)
          @(vif.int_mon_cb);
        
        `uvm_info(get_name(),"hardware interrupt is done",UVM_LOW)
        int_ev.reset();
      end
    end
  endtask

endclass
