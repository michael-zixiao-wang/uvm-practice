class base_vseq extends uvm_sequence;
  `uvm_object_utils(base_vseq)
  
  `uvm_declare_p_sequencer(sync_fifo_vsqr) // note this line

  function new(string name = "base_vseq");
    super.new(name);
  endfunction

  //uvm 1.2
  virtual task pre_start();
    uvm_phase phase = get_starting_phase();
    if (phase != null) phase.raise_objection(this);
  endtask

  virtual task post_start();
    uvm_phase phase = get_starting_phase();
    if (phase != null) phase.drop_objection(this);
  endtask
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  sync_fifo_env env;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sync_fifo_env::type_id::create("env",this);
  endfunction

  virtual task run_phase(uvm_phase phase); // note this line for drain time
    phase.phase_done.set_drain_time(this,100ns);
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction
endclass
