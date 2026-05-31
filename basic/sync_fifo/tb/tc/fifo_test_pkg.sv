package fifo_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 导入所有底层依赖
  import wr_agt_pkg::*;
  import rd_agt_pkg::*;
  import fifo_env_pkg::*;

  // Include 测试类，注意继承关系：先父类，后子类
  `include "base_test.svh"
  `include "sanity_test.svh"

endpackage : fifo_test_pkg
