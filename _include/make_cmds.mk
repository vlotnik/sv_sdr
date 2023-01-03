## +-----------------------------------------------------------------------------------------------------------------------------+
## | base commands
## +-----------------------------------------------------------------------------------------------------------------------------+
    help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

    clean: ##                           remove base generated data
	rm -rf transcript *.wlf def_lib modelsim.ini wlft* *.vstf _libs *.RESULT _result _dump

    clean_log: ##                       remove log files
	rm -rf *.log

    build_done: ##                      create build_done.RESULT
	touch build_done.RESULT

    rm_transcript: ##                   delete transcript
	rm transcript

LIB_PATH = _libs
DEF_LIB = ${LIB_PATH}/work

    create_base_libs: ##                create base RTL libraries
	vlib ${LIB_PATH}