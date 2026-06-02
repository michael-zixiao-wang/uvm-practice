class apb_transaction extends uvm_sequence_item;
  typedef enum {APB_READ, APB_WRITE} kind_e;
  rand kind_e kind;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand int        idle_cycles;
  

  bit slverr;

  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(slverr, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

  // 32 bits align
  constraint addr_align {
    addr[1:0] == 2'b00;  
  }
  
  constraint idle {
    idle_cycles inside {[0:2]};  
  }
endclass
