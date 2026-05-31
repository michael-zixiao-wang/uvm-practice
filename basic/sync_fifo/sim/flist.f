// ==========================================
// 1. Include Directories (头文件搜索路径)
// ==========================================
+incdir+../tb/agt
+incdir+../tb/cov
+incdir+../tb/env
+incdir+../tb/tc
+incdir+../tb/top

// ==========================================
// 2. RTL Design (设计文件)
// ==========================================
../dut/sync_fifo.v
../tb/intf/sync_fifo_intf.sv

// ==========================================
// 3. UVM Packages (按层级自底向上编译)
//    注意：这里假设你把类都 include 在了 _pkg.sv 文件中
// ==========================================
../tb/agt/wr_agt_pkg.sv
../tb/agt/rd_agt_pkg.sv
../tb/cov/fifo_cov_pkg.sv
../tb/env/fifo_env_pkg.sv
../tb/tc/fifo_test_pkg.sv

// ==========================================
// 4. Top Level Files (接口与顶层文件)
// ==========================================
../tb/top/tb_top.sv
