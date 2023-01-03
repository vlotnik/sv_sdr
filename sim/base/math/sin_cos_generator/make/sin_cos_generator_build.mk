## +-----------------------------------------------------------------------------------------------------------------------------+
## | sin_cos_generator
## +-----------------------------------------------------------------------------------------------------------------------------+

# path to Src
UVM_PATH = ../../../..
INCLUDE  = ${UVM_PATH}/_include
include ${INCLUDE}/make_cmds.mk

    comp_rtl: ##                        compile RTL sources
	vlog -64 -work ${DEF_LIB} ${UVM_PATH}/rtl/base/math/*.sv

    ## build:                           build RTL
    build: \
	clean \
	create_base_libs \
	comp_rtl

    comp_sim: ##                        compile SIM sources
	vlog -64 -work ${DEF_LIB} +incdir+${UVM_PATH}/_include \
	-work ${DEF_LIB} ${UVM_PATH}/uvm/bfm/rAXI/*.sv \
	-work ${DEF_LIB} ${UVM_PATH}/sim/base/dataflow/pipe/*.sv \
	-work ${DEF_LIB} ${UVM_PATH}/sim/base/math/sin_cos_generator/*.sv
