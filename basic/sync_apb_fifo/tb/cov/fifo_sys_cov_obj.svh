class fifo_sys_cov_obj extends uvm_object;
  `uvm_object_utils(fifo_sys_cov_obj)

  covergroup cg_fifo_sys with function sample(logic wr_en, logic rd_en, logic full, logic empty);
    cp_wr_en: coverpoint wr_en {bins active = {1'b1};}
    cp_rd_en: coverpoint rd_en {bins active = {1'b1};}

    cp_full: coverpoint full;
    cp_empty: coverpoint empty;

    cross_rw_state: cross cp_wr_en, cp_rd_en, cp_full, cp_empty{
      ignore_bins impossible_state = binsof(cp_full) intersect {1} &&
                                     binsof(cp_empty) intersect {1};
      bins concurent_rw_full = binsof(cp_wr_en) intersect {1} &&
                               binsof(cp_rd_en) intersect {1} &&
                               binsof(cp_full)  intersect {1} ;
      bins concurent_rw_empty = binsof(cp_wr_en) intersect {1} &&
                               binsof(cp_rd_en) intersect {1} &&
                               binsof(cp_empty)  intersect {1} ;
      bins concurrent_rw_partial = binsof(cp_wr_en) intersect {1} && 
                                   binsof(cp_rd_en) intersect {1} && 
                                   binsof(cp_full) intersect {0} && 
                                   binsof(cp_empty) intersect {0};
    }
  endgroup

  function new(string name = "fifo_sys_cov_obj");
    super.new(name);
    cg_fifo_sys = new();
  endfunction

endclass
