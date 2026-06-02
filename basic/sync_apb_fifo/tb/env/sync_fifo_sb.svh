class sync_fifo_sb extends uvm_scoreboard;
  `uvm_component_utils(sync_fifo_sb)

  uvm_tlm_analysis_fifo #(wr_transaction) exp_wr_fifo;
  uvm_tlm_analysis_fifo #(wr_transaction) act_wr_fifo;

  uvm_tlm_analysis_fifo #(rd_transaction) exp_rd_fifo;
  uvm_tlm_analysis_fifo #(rd_transaction) act_rd_fifo;

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_wr_fifo = new("exp_wr_fifo", this);
    act_wr_fifo = new("act_wr_fifo", this);
    exp_rd_fifo = new("exp_rd_fifo", this);
    act_rd_fifo = new("act_rd_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    fork
      check_write_channel();
      check_read_channel();
    join
  endtask

  task check_write_channel();
    wr_transaction exp_tr, act_tr;
    forever begin
      // wait both two get
      fork 
        exp_wr_fifo.get(exp_tr);
        act_wr_fifo.get(act_tr);
      join
      
      // check full flag
      if(exp_tr.compare(act_tr))begin
        `uvm_info(get_name(),"wr compare successfull",UVM_LOW) 
      end else begin
        `uvm_error(get_name(),"wr compare failed")
        `uvm_info(get_name(), $sformatf("the exp pkt is:\n%s\nthe act pkt is:\n%s", exp_tr.sprint(), act_tr.sprint()),UVM_LOW)
      end
    end
  endtask
  
  task check_read_channel();
    rd_transaction exp_tr, act_tr;
    forever begin
      // wait both two get
      fork 
        exp_rd_fifo.get(exp_tr);
        act_rd_fifo.get(act_tr);
      join
      
      // check full flag
      if(exp_tr.compare(act_tr))begin
        `uvm_info(get_name(),"rd compare successfull",UVM_LOW) 
      end else begin
        `uvm_error(get_name(),"rd compare failed")
        `uvm_info(get_name(), $sformatf("the exp pkt is:\n%s\nthe act pkt is:\n%s", exp_tr.sprint(), act_tr.sprint()),UVM_LOW)
      end
    end
  endtask


endclass
