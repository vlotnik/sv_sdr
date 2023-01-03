//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator_base_test
//--------------------------------------------------------------------------------------------------------------------------------
class sin_cos_generator_base_test #(
      PHASE_W
    , SINCOS_W
    , RAXI_DW_RX
    , RAXI_DW_TX
) extends raxi_base_test #(
      .RAXI_DW_RX(RAXI_DW_RX)
    , .RAXI_DW_TX(RAXI_DW_TX)
);

    `uvm_component_new

    typedef uvm_component_registry #(sin_cos_generator_base_test #(
          PHASE_W
        , SINCOS_W
        , RAXI_DW_RX
        , RAXI_DW_TX
    ), "sin_cos_generator_base_test") type_id;

    // functions
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // RX sequence
    sin_cos_generator_base_seqc_rx #(
          .PHASE_W(PHASE_W)
    )                                   seqc_rx;

    // TX sequence
    raxi_base_seqc_tx                   seqc_tx;

    // scoreboard
    sin_cos_generator_scrb #(
          .PHASE_W(PHASE_W)
        , .SINCOS_W(SINCOS_W)
    )                                   scrb_h;

    // coverboard
    sin_cos_generator_cvrb #(
          .PHASE_W(PHASE_W)
    )                                   cvrb_h;

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sin_cos_generator_base_test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    raxi_agnt_tx.driver_mode = TX_MODE;

    // build RX sequence
    `uvm_component_create(sin_cos_generator_base_seqc_rx #(PHASE_W), seqc_rx)

    // build TX sequence
    `uvm_component_create(raxi_base_seqc_tx, seqc_tx)

    // build scoreboard
    `uvm_component_create(sin_cos_generator_scrb #(PHASE_W, SINCOS_W), scrb_h);

    // build coverboard
    `uvm_component_create(sin_cos_generator_cvrb #(PHASE_W), cvrb_h);
endfunction

function void sin_cos_generator_base_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect scoreboard
    raxi_agnt_rx.raxi_aprt_h.connect(scrb_h.raxi_aprt_rx);
    raxi_agnt_tx.raxi_aprt_h.connect(scrb_h.raxi_aprt_tx);

    // connect coverboard
    raxi_agnt_rx.raxi_aprt_h.connect(cvrb_h.analysis_export);
endfunction

task sin_cos_generator_base_test::run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
        fork
            seqc_rx.start(raxi_agnt_rx.raxi_seqr_h);
            seqc_tx.start(raxi_agnt_tx.raxi_seqr_h);
        join_any
    phase.drop_objection(this);
endtask