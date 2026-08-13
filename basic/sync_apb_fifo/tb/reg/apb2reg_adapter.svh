class apb2reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb2reg_adapter)

  function new(string name = "apb2reg_adapter");
    super.new(name);
    // note this two line
    support_byte_enable = 0; // APB has no byte enable
    provides_responses = 1; // APB has slverr
  endfunction

  // from reg model(sw) to seq(hw)
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw); // note this line
    apb_transaction tr = apb_transaction::type_id::create("tr");
    tr.kind = (rw.kind == UVM_READ) ? apb_transaction::APB_READ : apb_transaction::APB_WRITE;
    tr.addr = rw.addr;
    tr.data = rw.data;
    return tr;
  endfunction

  // from seq(hw) to reg model(sw)
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);//note
    apb_transaction tr;
    if(!$cast(tr, bus_item))begin
      `uvm_fatal(get_name(), "Failed to cast bus_item to apb_transaction"
      return;
    end

    rw.kind = (tr.kind == apb_transaction::APB_READ) ? UVM_READ : UVM_WRITE;
    rw.addr = tr.addr;
    rw.data = tr.data;
    rw.status = (tr.slverr == 1) ? UVM_NOT_OK : UVM_IS_OK; //note this

  endfunction 

endclass
