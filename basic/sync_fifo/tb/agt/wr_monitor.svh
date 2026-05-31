class wr_monitor extends uvm_monitor;
  `uvm_component_utils(wr_monitor)

  virtual sync_fifo_intf vintf;
  uvm_analysis_port #(wr_transaction) ap; // note this line

  function new (string name = "wr_mon", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //if(!uvm_config_db#(wr_transactoin)::get(this,"","vif",vintf))
    //  `uvm_fatal(get_name(),"vintf is not set!")
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    wr_transaction tr;
    wait(vintf.rst_n === 1'b1);
    //@(vintf.wr_cb); // note this line: the timing alain has been done in the
    //first line in forever loop
    
    forever begin
      @(vintf.wr_mon_cb); // note this line
      if(vintf.wr_mon_cb.wr_en === 1'b1 /*&& vintf.full === 1'b0*/)begin
        tr = wr_transaction::type_id::create("tr");
        tr.data = vintf.wr_mon_cb.wr_data;
        tr.full = vintf.wr_mon_cb.full; 
        `uvm_info(get_name(),"mon one pkt try to push:",UVM_LOW)
        tr.print();
        ap.write(tr);
      end
    end
  endtask

endclass
