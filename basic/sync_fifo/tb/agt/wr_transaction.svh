class wr_transaction extends uvm_sequence_item;
  rand bit [32-1:0] data;
  rand int          idle_cycles;

  bit full; 

  `uvm_object_utils_begin(wr_transaction)
    `uvm_field_int(data, UVM_ALL_ON|UVM_NOCOMPARE)  
    `uvm_field_int(idle_cycles, UVM_ALL_ON|UVM_NOCOMPARE) // note this line
    `uvm_field_int(full, UVM_ALL_ON)  
  `uvm_object_utils_end

  function new (string name = "wr_trans");
    super.new(name);
  endfunction

  constraint idle{
    idle_cycles dist{
      0     := 50,
      [1:5] := 40,
      [6:20]:= 10
    }; // note this
  }

endclass
