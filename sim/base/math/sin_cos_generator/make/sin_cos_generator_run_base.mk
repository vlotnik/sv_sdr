    ## base

BASE_RUN_SIM_CMD = \
	-g PHASE_W=${CONFIG_PHASE_W} \
	-g SINCOS_W=${CONFIG_SINCOS_W} \
	-L ${DEF_LIB} \
	-sv_seed ${CONFIG_SV_SEED} \
	${DEF_LIB}.tb_sin_cos_generator \
	+UVM_VERBOSITY=UVM_NONE \
	+UVM_TESTNAME=sin_cos_generator_base_test \
	-do "wave.do" \
	-do "run -all" \
	-do "quit"

base_run_sim:
	vsim -64 -c -voptargs="+acc" \
	${BASE_RUN_SIM_CMD}

base_run_sim_gui:
	vsim -64 -voptargs="+acc" \
	${BASE_RUN_SIM_CMD}

base_uvm: \
	comp_sim \
	base_run_sim

base_uvm_gui: \
	comp_sim \
	base_run_sim_gui

base_all: \
	build \
	base_uvm \

base_all_gui: \
	build \
	base_uvm_gui \