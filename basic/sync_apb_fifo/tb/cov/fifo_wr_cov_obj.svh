class fifo_wr_cov_obj extends uvm_object;
  `uvm_object_utils(fifo_wr_cov_obj)

  covergroup cg_fifo_write with function sample(wr_transaction tr);
    
    cp_wr_data: coverpoint tr.data {
      bins all_zeros = {'0};  
      bins all_ones = {'1};  
      bins others = default;
    }

    cp_full_flag: coverpoint tr.full{
      bins not_full = {1'b0};
      bins is_full = {1'b1};
    }

    cross_data_full: cross cp_wr_data, cp_full_flag;

  endgroup


  function new(string name = "fifo_wr_cov_obj");
    super.new(name);
    cg_fifo_write = new();
  endfunction

endclass
