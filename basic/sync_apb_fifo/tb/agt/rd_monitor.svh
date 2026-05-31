class rd_monitor extends uvm_monitor;
  `uvm_component_utils(rd_monitor)

  virtual sync_fifo_intf vintf;
  uvm_analysis_port #(rd_transaction) ap;

  function new(string name = "rd_mon", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("rd_ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    wait(vintf.rst_n === 1'b1);
    forever begin
      @(vintf.rd_mon_cb);
      if(vintf.rd_mon_cb.rd_en === 1'b1 /*&& vintf.rd_mon_cb.empty === 1'b0*/)begin
        fork 
          begin
          rd_transaction tr;
          tr = rd_transaction::type_id::create("tr");
          @(vintf.rd_mon_cb);
          tr.data =  vintf.rd_mon_cb.rd_data;
          tr.empty = vintf.rd_mon_cb.empty;
          `uvm_info(get_name(), "mon one pkt try to pop:", UVM_LOW)
          tr.print();
          ap.write(tr);
          end
        join_none
      end
    end
  endtask

endclass
