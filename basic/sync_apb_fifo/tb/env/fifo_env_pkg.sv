package fifo_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 导入底层的包，这样 env 就能识别 wr_agent 和 rd_agent 类了
  import wr_agt_pkg::*;
  import rd_agt_pkg::*;
  import apb_agt_pkg::*;
  import int_mon_pkg::*;
  import fifo_cov_pkg::*;

  // Include 环境组件类
  // (未来如果你写了 Reference Model 和 Scoreboard，也统一 include 在这里)
  `include "sync_fifo_vsqr.svh"
  `include "sync_fifo_model.svh"
  `include "sync_fifo_sb.svh"
  
  `include "sync_fifo_cov_collector.svh"
  `include "sync_fifo_env.svh"

endpackage : fifo_env_pkg
