//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_gainer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_gainer extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_gainer)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_gainer                     sdr_seqc_gainer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_gainer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_gainer, sdr_seqc_gainer_h)
    sdr_seqc_gainer_h.sdr_aprt_rx = new("dsp_seqc_gainer_aprt_rx", this);
    sdr_seqc_gainer_h.sdr_aprt_tx = new("dsp_seqc_gainer_aprt_tx", this);
endfunction

function void sdr_layr_gainer::connect_phase(uvm_phase phase);
    sdr_seqc_gainer_h.sdr_seqr_h = sdr_seqr_rx;
    sdr_seqc_gainer_h.sdr_aprt_rx.connect(sdr_aprt_rx);
    sdr_seqc_gainer_h.sdr_aprt_tx.connect(sdr_aprt_tx);
endfunction

task sdr_layr_gainer::run_phase(uvm_phase phase);
    sdr_seqc_gainer_h.start(sdr_seqr_tx);
endtask