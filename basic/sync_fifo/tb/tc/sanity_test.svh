class wr_sanity_seq extends uvm_sequence #(wr_transaction);
  `uvm_object_utils(wr_sanity_seq)

  function new (string name = "wr_sanity_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      `uvm_do_with(req,{});
      `uvm_info(get_type_name(),"a wr trans was generated",UVM_HIGH)
    end
  endtask

endclass

class rd_sanity_seq extends uvm_sequence #(rd_transaction);
  `uvm_object_utils(rd_sanity_seq)

  function new (string name = "rd_sanity_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      `uvm_do_with(req,{});
      `uvm_info(get_type_name(),"a rd trans was generated",UVM_HIGH)
    end
  endtask
endclass

/* use virtual seq */
class sanity_vseq extends base_vseq;
  `uvm_object_utils(sanity_vseq)
  
  function new(string name = "sanity_vseq");
    super.new(name);
  endfunction

  virtual task body();
    wr_sanity_seq wr_seq;
    rd_sanity_seq rd_seq;
    
    `uvm_info(get_name(),"start write seq", UVM_LOW); 
    `uvm_do_on(wr_seq, p_sequencer.wr_sqr)

    `uvm_info(get_name(),"start read seq", UVM_LOW);
    `uvm_do_on(rd_seq,p_sequencer.rd_sqr)

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



/* original */
/*
class sanity_test extends base_test;
  `uvm_component_utils(sanity_test)

  function new(string name = "sanity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    wr_sanity_seq wr_seq;
    rd_sanity_seq rd_seq;

    wr_seq = wr_sanity_seq::type_id::create("wr_seq");
    rd_seq = rd_sanity_seq::type_id::create("rd_seq");

    phase.raise_objection(this);

    `uvm_info("TEST", "Executing Write Sequence...", UVM_LOW)
    wr_seq.start(env.wr_agt.sqr); // 把 sequence 挂载到指定的 sequencer 上运行

    `uvm_info("TEST", "Executing Read Sequence...", UVM_LOW)
    rd_seq.start(env.rd_agt.sqr);

    #150ns;

    phase.drop_objection(this);
  endtask

endclass
*/
