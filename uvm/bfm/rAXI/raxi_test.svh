//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_test
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_test #(
      RAXI_DW_RX = RAXI_DEFAULT_DW
    , RAXI_UW_RX = RAXI_DEFAULT_UW
    , RAXI_IW_RX = RAXI_DEFAULT_IW
    , RAXI_DW_TX = RAXI_DEFAULT_DW
    , RAXI_UW_TX = RAXI_DEFAULT_UW
    , RAXI_IW_TX = RAXI_DEFAULT_IW
) extends uvm_test;

    `uvm_component_new

    typedef uvm_component_registry #(raxi_test #(
          RAXI_DW_RX
        , RAXI_UW_RX
        , RAXI_IW_RX
        , RAXI_DW_TX
        , RAXI_UW_TX
        , RAXI_IW_TX
    ), "raxi_test") type_id;

    // functions
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // objects
    virtual raxi_bfm #(
          .DW(RAXI_DW_RX)
        , .UW(RAXI_UW_RX)
        , .IW(RAXI_IW_RX)
    )                                   raxi_bfm_rx;
    virtual raxi_bfm #(
          .DW(RAXI_DW_TX)
        , .UW(RAXI_UW_TX)
        , .IW(RAXI_IW_TX)
    )                                   raxi_bfm_tx;

    // RX agent
    raxi_agnt #(
          .DW(RAXI_DW_RX)
        , .UW(RAXI_UW_RX)
        , .IW(RAXI_IW_RX)
    )                                   raxi_agnt_rx;

    // TX agent
    raxi_agnt #(
          .DW(RAXI_DW_TX)
        , .UW(RAXI_UW_TX)
        , .IW(RAXI_IW_TX)
    )                                   raxi_agnt_tx;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void raxi_test::build_phase(uvm_phase phase);
    // get bfm from database
    if (!uvm_config_db #(virtual raxi_bfm #(
          .DW(RAXI_DW_RX)
        , .UW(RAXI_UW_RX)
        , .IW(RAXI_IW_RX)
    ))::get(this, "", "raxi_bfm_rx", raxi_bfm_rx)) `uvm_fatal("BFM", "Failed to get raxi_bfm_rx");

    if (!uvm_config_db #(virtual raxi_bfm #(
          .DW(RAXI_DW_TX)
        , .UW(RAXI_UW_TX)
        , .IW(RAXI_IW_TX)
    ))::get(this, "", "raxi_bfm_tx", raxi_bfm_tx)) `uvm_fatal("BFM", "Failed to get raxi_bfm_tx");

    // build RX agent
    `uvm_component_create(raxi_agnt #(
          .DW(RAXI_DW_RX)
        , .UW(RAXI_UW_RX)
        , .IW(RAXI_IW_RX)
    ), raxi_agnt_rx)
    raxi_agnt_rx.raxi_bfm_h = raxi_bfm_rx;

    // build TX agent
    `uvm_component_create(raxi_agnt #(
          .DW(RAXI_DW_TX)
        , .UW(RAXI_UW_TX)
        , .IW(RAXI_IW_TX)
    ), raxi_agnt_tx)
    raxi_agnt_tx.raxi_bfm_h = raxi_bfm_tx;
endfunction

function void raxi_test::connect_phase(uvm_phase phase);

endfunction

task raxi_test::run_phase(uvm_phase phase);
    phase.raise_objection(this);
        `uvm_info(get_name(), " rAXI BASE TEST IS STARTED", UVM_NONE);
    phase.drop_objection(this);
endtask