/// the total uvm_reg_block
class fifo_reg_block extends uvm_reg_block;
  `uvm_object_utils(fifo_reg_block)

  rand reg_fifo_ctrl r_fifo_ctrl;
  rand reg_fifo_stat r_fifo_stat;
  rand reg_watermark r_watermark;
  rand reg_int_en    r_int_en;
  rand reg_int_stat  r_int_stat;
  
  function new(string name = "fifo_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function void build();
    //1. creat map: name, base addr, the byte width of bus, endian
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    
    //2. inst and build all the reg
    r_fifo_ctrl = reg_fifo_ctrl::type_id::create("r_fifo_ctrl");
    r_fifo_ctrl.configure(this, null, ""); // backdoor accecc config
    r_fifo_ctrl.build();
    default_map.add_reg(r_fifo_ctrl, 'h00, "RW");

    r_fifo_stat = reg_fifo_stat::type_id::create("r_fifo_stat");
    r_fifo_stat.configure(this, null, ""); 
    r_fifo_stat.build();
    default_map.add_reg(r_fifo_stat, 'h04, "RO");

    r_watermark = reg_watermark::type_id::create("r_watermark");
    r_watermark.configure(this, null, "");
    r_watermark.build();
    default_map.add_reg(r_watermark, 'h08, "RW");

    r_int_en = reg_int_en::type_id::create("r_int_en");
    r_int_en.configure(this, null, "");
    r_int_en.build();
    default_map.add_reg(r_int_en, 'h0C, "RW");

    r_int_stat = reg_int_stat::type_id::create("r_int_stat");
    r_int_stat.configure(this, null, "");
    r_int_stat.build();
    default_map.add_reg(r_int_stat, 'h10, "RW"); // note this is not W1C
    
    //3. lock the model
    lock_model();
  endfunction

endclass


/// the basic uvm_reg

// 0x00: FIFO_CTRL RW
class reg_fifo_ctrl extends uvm_reg;
  `uvm_object_utils(reg_fifo_ctrl)
  
  rand uvm_reg_field fifo_en;
  rand uvm_reg_field soft_reset;

  function new(string name = "reg_fifo_ctrl")l
    super.new(name, 32, UVM_NO_COVERAGE); // note this line
  endfunction

  function void build(); // build function
    //1. create reg fields
    fifo_en = uvm_reg_field::type_id::create("fifo_en");
    soft_reset = uvm_reg_field::type_id::create("soft_reset");

    //2. config reg fields
    // parameter: parent, size, lsb_pos, access, volatile, 
    //            reset value, has_reset, is_rand, single lost
    fifo_en.configure(this, 1, 0, "RW", 0, 1'b1, 1, 1, 0);
    soft_reset.configure(this, 1, 1, "RW", 0, 1'b1, 1, 1, 0);
  endfunction

endclass

// 0x04: FIFO_STAT RO->set by hw, set to volatile
class reg_fifo_stat extends uvm_reg;
  `uvm_object_utils(reg_fifo_stat)
  uvm_reg_field empty;
  uvm_reg_field full;
  uvm_reg_field count;

  function new(string name = "reg_fifo_stat");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build();
    empty = uvm_reg_field::type_id::create("empty");
    full = uvm_reg_field::type_id::create("full");
    count = uvm_reg_field::type_id::create("count");
    
    empty.configure(this, 1, 0, "RO", 1, 1'b1, 1, 0, 0);
    full.configure(this, 1, 1, "RO", 1, 1'b0, 1, 0, 0);
    count.configure(this, 5, 2, "RO", 1, 5'h0, 1, 0, 0);
  endfunction

endclass


// 0x08: WATERMARK RW
class reg_watermark extends uvm_reg;
  `uvm_object_utils(reg_watermark)
  rand uvm_reg_field almost_empty_thr;
  rand uvm_reg_field almost_full_thr;

  function new(string name = "reg_watermark");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build();
    almost_empty_thr = uvm_reg_field::type_id::create("almost_full_thr");
    almost_full_thr = uvm_reg_field::type_id::create("almost_empty_thr");
   
    almost_empty_thr.configure(this, 4, 0, "RW", 0, 4'h1, 1, 1, 0);
    almost_full_thr.configure(this, 4, 3, "RW", 0, 4'hf, 1, 1, 0); 
  endfunction

endclass

// 0x0c: INT_EN RW
class reg_int_en extends uvm_reg;
  `uvm_object_utils(reg_int_en)
  rand uvm_reg_field overflow_en;
  rand uvm_reg_field underflow_en;

  function new( string name = "reg_int_en");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build();
    overflow_en = uvm_reg_field::type_id::create("overflow_en");
    underflow_en = uvm_reg_field::type_id::create("underflow_en");
    
    overflow_en.configure(this, 1, 0, "RW", 0, 1, 1, 0);
    underflow_en.configure(this, 1, 0, "RW", 0, 1, 1, 0);
  endfunction

endclass

// 0x10: INTS_STAT W1C
class reg_int_stat extends uvm_reg;
  `uvm_object_utils(reg_int_stat)
  uvm_reg_field overflow_stat;
  uvm_reg_field underflow_stat;

  function new (string name = "reg_int_stat");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build();
    overflow_stat  = uvm_reg_field::type_id::create("overflow_stat"); 
    underflow_stat = uvm_reg_field::type_id::create("underflow_stat"); 

    overflow_stat.configure(this, 1, 0, "W1C", 1, 1, 0, 0);
    underflow_stat.configure(this, 1, 0, "W1C", 1, 1, 0, 0);
  endfunction


endclass






