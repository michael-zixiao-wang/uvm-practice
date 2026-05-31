# ==========================================
# 变量定义
# ==========================================
# 默认跑的测试用例名，可以通过 make sim TEST=xxx 覆盖
TEST ?= sanity_test 
# 默认的随机种子，使用系统时间确保每次随机激励不同
SEED ?= $(shell date +%s)
# 默认的打印级别
VERB ?= UVM_HIGH

# ==========================================
# 覆盖率相关选项
# line: 行覆盖率 | cond: 条件 | tgl: 翻转 | branch: 分支 | fsm: 状态机 | cvg: 功能
# ==========================================
COV_OPTS = -cm line+cond+tgl+branch+fsm
# 指定覆盖率数据库(vdb)的名字，默认是 simv.vdb
COV_DIR  = -cm_dir ./coverage.vdb


# ==========================================
# VCS 编译选项
# ==========================================
VCS_OPTS = -full64 -sverilog \
           -ntb_opts uvm-1.2 \
           -timescale=1ns/1ps \
           -debug_access+all -kdb \
					 $(COV_OPTS) $(COV_DIR) \
           -l comp.log \
           -f flist.f

# ==========================================
# 仿真运行选项
# ==========================================
SIM_OPTS = +UVM_TESTNAME=$(TEST) \
           +ntb_random_seed=$(SEED) \
           +UVM_VERBOSITY=$(VERB) \
					 $(COV_OPTS) $(COV_DIR) \
					 -cm_name $(TEST)_$(SEED) \
           -l sim.log \
           -ucli -do simulate.do

# ==========================================
# 执行目标 (Targets)
# ==========================================
.PHONY: all comp sim verdi clean

# 默认目标：编译并仿真
all: comp sim

# 编译步骤
comp:
	vcs $(VCS_OPTS)

# 仿真步骤
sim:
	./simv $(SIM_OPTS)

# 打开 Verdi 查看波形
verdi:
	verdi -ssf tb_top.fsdb -nologo &

cov:
	verdi -cov -covdir ./coverage.vdb -nologo &
	#verdi -cov -covdir ./coverage.vdb -dbdir ./simv.daidir -nologo &
	#verdi -elab ./simv.daidir/kdb -cov -covdir ./coverage.vdb -nologo &

# 工业界标准：生成网页版覆盖率报告
urg:
	urg -full64 -lca -dir ./coverage.vdb -report cov_html
	# 如果你在 Ubuntu 桌面环境下，可以直接用火狐浏览器打开：
	firefox ./cov_html/dashboard.html &


# 清理编译产生的临时文件
clean:
	@rm -rf csrc simv simv.* *.log *.fsdb *.vpd *.vcd ucli.key vc_hdrs.h novas* verdiLog coverage.vdb
	@rm -rf vdCovLog verdi_config_file
