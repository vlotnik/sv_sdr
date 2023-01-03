//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator_scrb
//--------------------------------------------------------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_tx)

class sin_cos_generator_scrb #(
      PHASE_W
    , SINCOS_W
) extends raxi_scrb;
    `uvm_component_param_utils(sin_cos_generator_scrb #(PHASE_W, SINCOS_W))
    `uvm_component_new

    // UVM functions
    extern function void build_phase(uvm_phase phase);

    // arrays
    raxi_seqi raxi_seqi_queue_rx[$];
    raxi_seqi raxi_seqi_queue_tx[$];

    uvm_analysis_imp_rx #(raxi_seqi, sin_cos_generator_scrb #(PHASE_W, SINCOS_W)) raxi_aprt_rx;
    uvm_analysis_imp_tx #(raxi_seqi, sin_cos_generator_scrb #(PHASE_W, SINCOS_W)) raxi_aprt_tx;

    // sim model
    sim_sin_cos_generator #(
          .PHASE_W(PHASE_W)
        , .SINCOS_W(SINCOS_W)
    )                                   sim_h;

    // functions
    extern virtual function void write_rx(raxi_seqi raxi_seqi_h);
    extern virtual function void write_tx(raxi_seqi raxi_seqi_h);
    extern function void processing();

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sin_cos_generator_scrb::build_phase(uvm_phase phase);
    raxi_aprt_rx = new("raxi_aprt_rx", this);
    raxi_aprt_tx = new("raxi_aprt_tx", this);

    `uvm_object_create(sim_sin_cos_generator #(PHASE_W, SINCOS_W), sim_h);
endfunction

function void sin_cos_generator_scrb::write_rx(raxi_seqi raxi_seqi_h);
    raxi_seqi_queue_rx.push_back(raxi_seqi_h);
    `uvm_info("SCRB", $sformatf("\nPING... sequence with %s", raxi_seqi_h.convert2string()), UVM_HIGH);
endfunction

function void sin_cos_generator_scrb::write_tx(raxi_seqi raxi_seqi_h);
    raxi_seqi_queue_tx.push_back(raxi_seqi_h);
    `uvm_info("SCRB", $sformatf("\n...PONG sequence with %s", raxi_seqi_h.convert2string()), UVM_HIGH);
    processing();
endfunction

function void sin_cos_generator_scrb::processing();
    raxi_seqi raxi_seqi_rx;
    raxi_seqi raxi_seqi_rx_dly;
    raxi_seqi raxi_seqi_tx_sim;
    raxi_seqi raxi_seqi_tx_rtl;
    string data_str;

    `uvm_object_create(raxi_seqi, raxi_seqi_rx_dly);
    `uvm_object_create(raxi_seqi, raxi_seqi_tx_sim);

    raxi_seqi_rx = raxi_seqi_queue_rx.pop_front();
    sim_h.delay(raxi_seqi_rx, raxi_seqi_rx_dly);
    sim_h.simulate(raxi_seqi_rx, raxi_seqi_tx_sim);
    raxi_seqi_tx_rtl = raxi_seqi_queue_tx.pop_front();

    // print results
    data_str = {data_str, "\ninput,   DLY: ", sim_h.raxi2string_rx(raxi_seqi_rx_dly)};
    data_str = {data_str, "\ngot from RTL: ", sim_h.raxi2string_tx(raxi_seqi_tx_rtl)};
    data_str = {data_str, "\ngot from SIM: ", sim_h.raxi2string_tx(raxi_seqi_tx_sim)};

    // check results
    data_good = 1;
    if (!sim_h.compare_results(raxi_seqi_tx_sim, raxi_seqi_tx_rtl)) begin
        `uvm_error("FAIL", data_str)
        fail_cnt++;
    end else
        `uvm_info("PASS", data_str, UVM_NONE)
endfunction