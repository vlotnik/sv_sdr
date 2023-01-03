//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator
//--------------------------------------------------------------------------------------------------------------------------------
module sin_cos_generator #(
      parameter                         PHASE_W = 12
    , parameter                         SINCOS_W = 16
    , parameter                         RAXI_DW_RX = 12
    , parameter                         RAXI_DW_TX = 32
) (
      input                             irx_clk
    , input                             irx_valid
    , output                            orx_ready
    , input [RAXI_DW_RX-1:0]            irx_data
    , input                             itx_ready
    , output [RAXI_DW_TX-1:0]           otx_data
);

    import pkg_sin_cos_generator::*;

//--------------------------------------------------------------------------------------------------------------------------------
// settings
//--------------------------------------------------------------------------------------------------------------------------------
    localparam                          NOF_PHASES = 2**PHASE_W;
    localparam                          SINCOS_MAX = 2**(SINCOS_W-1)-1;

//--------------------------------------------------------------------------------------------------------------------------------
// rx
//--------------------------------------------------------------------------------------------------------------------------------
    logic ib_rx_clk;
    logic ib_rx_valid;
    logic ob_rx_ready;
    logic [RAXI_DW_RX-1:0] ib_rx_data;

    assign ib_rx_clk                    = irx_clk;
    assign ib_rx_valid                  = irx_valid;
    assign orx_ready                    = ob_rx_ready;
    assign ib_rx_data                   = irx_data;

//--------------------------------------------------------------------------------------------------------------------------------
// tx
//--------------------------------------------------------------------------------------------------------------------------------
    logic ib_tx_ready;
    logic [RAXI_DW_TX-1:0] ob_tx_data;

    assign ib_tx_ready                  = itx_ready;
    assign otx_data                     = ob_tx_data;

//--------------------------------------------------------------------------------------------------------------------------------
// input
//--------------------------------------------------------------------------------------------------------------------------------
    logic [PHASE_W-1:0] ib_rx_data_phase;

    assign ob_rx_ready                  = ib_tx_ready;
    assign ib_rx_data_phase             = ib_rx_data[PHASE_W-1:0];

//--------------------------------------------------------------------------------------------------------------------------------
// initialize arrays
//--------------------------------------------------------------------------------------------------------------------------------
    reg [SINCOS_W-1:0] c_sin_table [NOF_PHASES-1:0];
    reg [SINCOS_W-1:0] c_cos_table [NOF_PHASES-1:0];
    logic signed [SINCOS_W-1:0] table_out_sin;
    logic signed [SINCOS_W-1:0] table_out_cos;

    initial begin : init_table
        for (int ii = 0; ii < NOF_PHASES; ii++) begin
            c_sin_table[ii] = f_sin(ii, SINCOS_MAX, PHASE_W);
            c_cos_table[ii] = f_cos(ii, SINCOS_MAX, PHASE_W);
        end
    end

    // internal triggers
    logic signed [SINCOS_W-1:0] internal_sin;
    logic signed [SINCOS_W-1:0] internal_cos;

//--------------------------------------------------------------------------------------------------------------------------------
// generate sin/cos
//--------------------------------------------------------------------------------------------------------------------------------
    always @(posedge ib_rx_clk) begin : p_sincos
        if (ib_rx_valid == 1) begin
            table_out_sin <= c_sin_table[ib_rx_data_phase];
            table_out_cos <= c_cos_table[ib_rx_data_phase];

            internal_sin <= table_out_sin;
            internal_cos <= table_out_cos;
        end
    end

//--------------------------------------------------------------------------------------------------------------------------------
// output
//--------------------------------------------------------------------------------------------------------------------------------
    logic [SINCOS_W-1:0] ob_tx_data_sin;
    logic [SINCOS_W-1:0] ob_tx_data_cos;

    assign ob_tx_data_sin               = internal_sin;
    assign ob_tx_data_cos               = internal_cos;

    assign ob_tx_data                   = {ob_tx_data_cos, ob_tx_data_sin};

//--------------------------------------------------------------------------------------------------------------------------------
endmodule