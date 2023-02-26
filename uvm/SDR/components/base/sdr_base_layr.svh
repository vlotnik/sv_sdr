//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_base_layr
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_base_layr extends uvm_component;
    `uvm_component_utils(sdr_base_layr)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);

    sdr_seqr                            sdr_seqr_rx;
    sdr_seqr                            sdr_seqr_tx;

    sdr_aprt                            sdr_aprt_rx;
    sdr_aprt                            sdr_aprt_tx;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------

function void sdr_base_layr::build_phase(uvm_phase phase);
    `uvm_component_create(uvm_sequencer #(sdr_seqi), sdr_seqr_rx)
    sdr_aprt_rx = new("sdr_aprt_rx", this);
    sdr_aprt_tx = new("sdr_aprt_tx", this);
endfunction