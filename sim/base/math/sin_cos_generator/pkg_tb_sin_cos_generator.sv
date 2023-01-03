//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_tb_sin_cos_generator
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_tb_sin_cos_generator;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "common_macros.svh"

    import pkg_raxi::*;
    import pkg_pipe::*;

    import pkg_sin_cos_generator::*;
    `include "./uvm/sim_sin_cos_generator.svh"

    `include "./uvm/sin_cos_generator_seqi.svh"
    `include "./uvm/sin_cos_generator_base_seqc_rx.svh"
    `include "./uvm/sin_cos_generator_scrb.svh"
    `include "./uvm/sin_cos_generator_cvrb.svh"
    `include "./uvm/sin_cos_generator_base_test.svh"

//--------------------------------------------------------------------------------------------------------------------------------
endpackage