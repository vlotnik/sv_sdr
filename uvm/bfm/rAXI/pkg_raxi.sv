//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_raxi
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_raxi;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "common_macros.svh"

    localparam                          RAXI_SEQC_MODE_RX = 0;
    localparam                          RAXI_SEQC_MODE_TX = 1;

    localparam                          RAXI_DRVR_MODE_RX = 0;
    localparam                          RAXI_DRVR_MODE_TX = 1;

    localparam                          RAXI_DEFAULT_DW = 8;
    localparam                          RAXI_DEFAULT_UW = 8;
    localparam                          RAXI_DEFAULT_IW = 8;

    `include "raxi_seqi.svh"
    typedef uvm_sequencer #(raxi_seqi) raxi_seqr;

    `include "raxi_drvr.svh"

    typedef uvm_analysis_port #(raxi_seqi) raxi_aprt;
    `include "raxi_mont.svh"

    `include "raxi_agnt.svh"

    `include "raxi_scrb.svh"

    `include "raxi_seqc.svh"
    `include "raxi_test.svh"

//--------------------------------------------------------------------------------------------------------------------------------
endpackage