//--------------------------------------------------------------------------------------------------------------------------------
// name : sim_sin_cos_generator
//--------------------------------------------------------------------------------------------------------------------------------
class sim_sin_cos_generator #(
      PHASE_W = 12
    , SINCOS_W = 16
) extends uvm_object;
    `uvm_object_param_utils(sim_sin_cos_generator #(PHASE_W, SINCOS_W))

    localparam                          LATENCY = pkg_sin_cos_generator::LATENCY;

    localparam                          RAXI_DW_RX = PHASE_W;
    localparam                          PIPE_CE = 0;
    localparam                          RAXI_DW_TX = SINCOS_W*2;
    localparam                          SINCOS_MAX = 2**(SINCOS_W-1)-1;

    // components
    sim_pipe #(
          .DW(RAXI_DW_RX)
        , .SIZE(LATENCY)
        , .PIPE_CE(PIPE_CE)
    )                                   sim_delay_h;
    sim_pipe #(
          .DW(RAXI_DW_TX)
        , .SIZE(LATENCY)
        , .PIPE_CE(PIPE_CE)
    )                                   sim_pipe_h;
    raxi_seqi                           raxi_seqi_h_pipe;

    extern function new(string name = "");
    extern function automatic void delay(raxi_seqi raxi_seqi_i, ref raxi_seqi raxi_seqi_o);
    extern function automatic void simulate(raxi_seqi raxi_seqi_i, ref raxi_seqi raxi_seqi_o);

    extern function string raxi2string_rx(raxi_seqi raxi_seqi_h);
    extern function string raxi2string_tx(raxi_seqi raxi_seqi_h);

    extern function bit compare_results(raxi_seqi raxi_seqi_sim, raxi_seqi raxi_seqi_rtl);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function sim_sin_cos_generator::new(string name = "");
    `uvm_object_create(sim_pipe #(RAXI_DW_RX, LATENCY, PIPE_CE), sim_delay_h)
    `uvm_object_create(sim_pipe #(RAXI_DW_TX, LATENCY, PIPE_CE), sim_pipe_h)
    `uvm_object_create(raxi_seqi, raxi_seqi_h_pipe)
endfunction

function automatic void sim_sin_cos_generator::delay(raxi_seqi raxi_seqi_i, ref raxi_seqi raxi_seqi_o);
    // pipeline
    sim_delay_h.simulate(raxi_seqi_i, raxi_seqi_o);
endfunction

function automatic void sim_sin_cos_generator::simulate(raxi_seqi raxi_seqi_i, ref raxi_seqi raxi_seqi_o);
    bit[RAXI_DW_RX-1:0] raxi_rx_data;

    bit[PHASE_W-1:0] rx_phase;

    int phase;
    int sin;
    int cos;

    bit[SINCOS_W-1:0] tx_sin;
    bit[SINCOS_W-1:0] tx_cos;

    bit[RAXI_DW_TX-1:0] raxi_tx_data;

    raxi_rx_data = {<<{raxi_seqi_i.data}};

    // parse rx
    rx_phase = raxi_rx_data;
    phase = rx_phase;

    // calculate sin/cos
    sin = f_sin(phase, SINCOS_MAX, PHASE_W);
    cos = f_cos(phase, SINCOS_MAX, PHASE_W);

    // make tx
    tx_sin = sin;
    tx_cos = cos;

    // apply data
    raxi_tx_data = {tx_cos, tx_sin};

    raxi_seqi_h_pipe.valid = raxi_seqi_i.valid;
    raxi_seqi_h_pipe.data = {<<{raxi_tx_data}};

    // pipeline
    sim_pipe_h.simulate(raxi_seqi_h_pipe, raxi_seqi_o);
endfunction

function string sim_sin_cos_generator::raxi2string_rx(raxi_seqi raxi_seqi_h);
    bit[RAXI_DW_RX-1:0] raxi_data = 0;
    bit[PHASE_W-1:0] raxi_data_phase;

    string s;

    s = $sformatf("valid = %0b", raxi_seqi_h.valid);

    if (raxi_seqi_h.data.size() > 0) begin
        raxi_data = {<<{raxi_seqi_h.data}};
        raxi_data_phase = raxi_data;

        s = {s, $sformatf(", phase = %d", raxi_data_phase)};
    end else begin
        s = {s, ", no data"};
    end

    return s;
endfunction

function string sim_sin_cos_generator::raxi2string_tx(raxi_seqi raxi_seqi_h);
    bit[RAXI_DW_TX-1:0] raxi_data = 0;
    bit[SINCOS_W-1:0] raxi_data_sin;
    bit[SINCOS_W-1:0] raxi_data_cos;

    string s;

    s = $sformatf("valid = %0b", raxi_seqi_h.valid);

    if (raxi_seqi_h.data.size() > 0) begin
        raxi_data = {<<{raxi_seqi_h.data}};
        {raxi_data_cos, raxi_data_sin} = raxi_data;

        s = {s, $sformatf(", sin = %d", $signed(raxi_data_sin))};
        s = {s, $sformatf(", cos = %d", $signed(raxi_data_cos))};
    end else begin
        s = {s, ", no data"};
    end

    return s;
endfunction

function bit sim_sin_cos_generator::compare_results(raxi_seqi raxi_seqi_sim, raxi_seqi raxi_seqi_rtl);
    bit[RAXI_DW_TX-1:0] raxi_data[2];

    bit[SINCOS_W-1:0] raxi_data_sin[2];
    bit[SINCOS_W-1:0] raxi_data_cos[2];

    int sin[2];
    int cos[2];

    bit result = 1;

    raxi_data[0] = {<<{raxi_seqi_sim.data}};
    raxi_data[1] = {<<{raxi_seqi_rtl.data}};

    for (int ii = 0; ii < 2; ii++) begin
        {raxi_data_cos[ii], raxi_data_sin[ii]} = raxi_data[ii];

        sin[ii] = $signed(raxi_data_sin[ii]);
        cos[ii] = $signed(raxi_data_cos[ii]);
    end

    // check valid
    if (raxi_seqi_sim.valid != raxi_seqi_rtl.valid) begin
        result = 0;
    end;

    // check data
    if (sin[0] != sin[1]) begin
        result = 0;
    end
    if (cos[0] != cos[1]) begin
        result = 0;
    end

    return result;
endfunction