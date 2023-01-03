## +-----------------------------------------------------------------------------------------------------------------------------+
## | sin_cos_generator, makefile
## +-----------------------------------------------------------------------------------------------------------------------------+

include make/sin_cos_generator_build.mk
include ${INCLUDE}/test_base_cmds.mk
include make/sin_cos_generator_run_base.mk

	CONFIG_PHASE_W = 12
	CONFIG_SINCOS_W = 16
	CONFIG_SV_SEED = random

    ## uvm:                             compile SIM sources and run all tests
    uvm: \
	comp_sv \
	base_run_sim

    ## all:                             compile all sources and run all tests
    all: \
	build \
	uvm

    run_tests: ##                       launch Python script
	python3.7 scripts/tb_sin_cos_generator.py