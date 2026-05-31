package rd_agt_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 1. Include 基础事务类 (文件实际在 ../tc/ 目录下)
  `include "rd_transaction.svh"
  
  // 2. Include 组件类
  `include "rd_sequencer.svh"
  `include "rd_driver.svh"
  `include "rd_monitor.svh"
  `include "rd_agent.svh"

endpackage : rd_agt_pkg
