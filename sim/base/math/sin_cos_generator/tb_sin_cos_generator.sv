//--------------------------------------------------------------------------------------------------------------------------------
// name : tb_sin_cos_generator
//--------------------------------------------------------------------------------------------------------------------------------
`timescale 100ps/100ps

module tb_sin_cos_generator;
//--------------------------------------------------------------------------------------------------------------------------------
// settings
//--------------------------------------------------------------------------------------------------------------------------------
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // main test package
    import pkg_tb_sin_cos_generator::*;

    parameter                           PHASE_W = 12;
    parameter                           SINCOS_W = 16;
    localparam                          RAXI_DW_RX = PHASE_W;
    localparam                          RAXI_DW_TX = SINCOS_W*2;

//--------------------------------------------------------------------------------------------------------------------------------
// clock generator
//--------------------------------------------------------------------------------------------------------------------------------
    bit clk = 0;
    // 100 MHz
    always #5 clk = ~clk;

    bit[PHASE_W-1:0] test_cnt;

    initial begin
        test_cnt = 0;
    end

    always @(posedge clk) begin
        test_cnt++;
    end

//--------------------------------------------------------------------------------------------------------------------------------
// interfaces
//--------------------------------------------------------------------------------------------------------------------------------
    raxi_bfm #(
          .DW(RAXI_DW_RX)
    )                                   raxi_bfm_rx(clk);
    raxi_bfm #(
          .DW(RAXI_DW_TX)
    )                                   raxi_bfm_tx(clk);

//--------------------------------------------------------------------------------------------------------------------------------
// DUT connection
//--------------------------------------------------------------------------------------------------------------------------------
    bit                                 idut_rx_clk;
    bit                                 idut_rx_valid;
    bit                                 odut_rx_ready;
    bit[RAXI_DW_RX-1:0]                 idut_rx_data;
    bit                                 idut_tx_ready;
    bit[RAXI_DW_TX-1:0]                 odut_tx_data;
//--------------------------------------------------------------------------------------------------------------------------------
    sin_cos_generator #(
          .PHASE_W                      (PHASE_W)
        , .SINCOS_W                     (SINCOS_W)
        , .RAXI_DW_RX                   (RAXI_DW_RX)
        , .RAXI_DW_TX                   (RAXI_DW_TX)
    )
    dut(
          .irx_clk                      (idut_rx_clk)
        , .irx_valid                    (idut_rx_valid)
        , .orx_ready                    (odut_rx_ready)
        , .irx_data                     (idut_rx_data)
        , .itx_ready                    (idut_tx_ready)
        , .otx_data                     (odut_tx_data)
    );

    assign idut_rx_clk                  = raxi_bfm_rx.clk;
    assign idut_rx_valid                = raxi_bfm_rx.valid;
    assign raxi_bfm_rx.ready            = odut_rx_ready;
    assign idut_rx_data                 = raxi_bfm_rx.data;

    assign raxi_bfm_tx.valid            = idut_rx_valid;
    assign idut_tx_ready                = raxi_bfm_tx.ready;
    assign raxi_bfm_tx.data             = odut_tx_data;

//--------------------------------------------------------------------------------------------------------------------------------
// UVM test
//--------------------------------------------------------------------------------------------------------------------------------
    typedef sin_cos_generator_base_test #(
          .PHASE_W(PHASE_W)
        , .SINCOS_W(SINCOS_W)
        , .RAXI_DW_RX(RAXI_DW_RX)
        , .RAXI_DW_TX(RAXI_DW_TX)
    )                                   sin_cos_generator_base_test_h;

    initial begin
        uvm_config_db #(virtual raxi_bfm #(RAXI_DW_RX))::set(null, "*", "raxi_bfm_rx", raxi_bfm_rx);
        uvm_config_db #(virtual raxi_bfm #(RAXI_DW_TX))::set(null, "*", "raxi_bfm_tx", raxi_bfm_tx);
        run_test();
    end

//--------------------------------------------------------------------------------------------------------------------------------
endmodule