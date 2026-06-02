class sync_fifo_model extends uvm_component;
  `uvm_component_utils(sync_fifo_model)
  
  `uvm_analysis_imp_decl(_wr)
  `uvm_analysis_imp_decl(_rd)

  uvm_analysis_imp_wr #(wr_transaction, sync_fifo_model) wr_imp;
  uvm_analysis_imp_rd #(rd_transaction, sync_fifo_model) rd_imp;

  uvm_analysis_port #(wr_transaction) wr_ap;
  uvm_analysis_port #(rd_transaction) rd_ap;

  parameter DEPTH = 16;
  bit [31:0] fifo_model [$];

  function new(string name = "ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
    wr_ap  = new("wr_ap", this);
    rd_ap  = new("rd_ap", this);
  endfunction

  function void write_wr(wr_transaction tr);
    wr_transaction exp_tr;
    exp_tr = wr_transaction::type_id::create("exp_wr");

    if(fifo_model.size() < DEPTH)begin
      fifo_model.push_back(tr.data);
      `uvm_info(get_name(),$sformatf("write to ref, dep=%0d", fifo_model.size()),UVM_MEDIUM)
    end else begin
      `uvm_info(get_name(),$sformatf("ref fifo is full, dep=%0d", fifo_model.size()),UVM_MEDIUM)
    end

    exp_tr.full = (fifo_model.size() == DEPTH);
    wr_ap.write(exp_tr); 

  endfunction

  function void write_rd(rd_transaction tr);
    rd_transaction exp_tr;
    exp_tr = rd_transaction::type_id::create("exp_tr");

    if(fifo_model.size() > 0)begin
      exp_tr.data = fifo_model.pop_front();
      `uvm_info(get_name(),$sformatf("read form ref, dep=%0d", fifo_model.size()),UVM_MEDIUM)
    end else begin
      `uvm_info(get_name(),$sformatf("ref fifo is empty, dep=%0d", fifo_model.size()),UVM_MEDIUM)
      exp_tr.data = 'x; //note this line
    end

    exp_tr.empty = (fifo_model.size() == 0);
    rd_ap.write(exp_tr);

  endfunction

  //no run_phase

endclass


/*
class sync_fifo_model extends uvm_component;
  `uvm_component_utils(sync_fifo_model)

  uvm_block_get_port #(wr_transaction) port;
  uvm_analysis_port #(rd_transaction) ap;

  bit [32-1:0] fifo [$]; // queue

  function new(string name = "ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    wr_transaction wr_req;
    rd_transaction rd_exp;
    int num;
    forever begin
      port.get(wr_req);
      if(fifo.size() < 16)begin
        fifo.push_back(wr_req.wr_data);
        rd_exp = rd_transaction::type_id::create("rd_exp");
        rd_exp.rd_data = wr_req.data
      end 

      

    end

  endtask


endclass
*/
