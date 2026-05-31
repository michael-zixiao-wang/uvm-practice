class fifo_rd_cov_obj extends uvm_object;
  `uvm_object_utils(fifo_rd_cov_obj)

  covergroup cg_fifo_read with function sample(rd_transaction tr);
    cp_rd_data: coverpoint tr.data {
      bins all_zeros = {'0};  
      bins all_ones  = {'1};  
      bins others = default;
    }
    
    cp_empty_flag: coverpoint tr.empty {
      bins not_empty = {1'b0};    
      bins is_empty = {1'b1};    
    }
  
    cross_data_empty: cross cp_rd_data, cp_empty_flag;
  endgroup

  function new(string name = "fifo_rd_cov_obj");
    super.new(name);
    cg_fifo_read = new(); // note this line
  endfunction


endclass
