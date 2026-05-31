class rd_transaction extends uvm_sequence_item;
  bit [32-1:0]  data; // note this is not a rand
  rand int      idle_cycles;

  bit empty;
  `uvm_object_utils_begin(rd_transaction)
    `uvm_field_int(data,  UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(empty, UVM_ALL_ON )
  `uvm_object_utils_end

  function new (string name = "rd_transaction");
    super.new(name);
  endfunction

  constraint idle{
    idle_cycles dist{
      0 := 50,
      [1:4] := 40,
      [6:20] := 10
    }; 
  }

endclass
