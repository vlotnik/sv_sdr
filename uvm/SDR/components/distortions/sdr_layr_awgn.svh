//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_awgn
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_awgn extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_awgn)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_awgn                       sdr_seqc_awgn_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_awgn::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_awgn, sdr_seqc_awgn_h)
    sdr_seqc_awgn_h.sdr_aprt_rx = new("sdr_seqc_awgn_aprt_rx", this);
    sdr_seqc_awgn_h.sdr_aprt_tx = new("sdr_seqc_awgn_aprt_tx", this);
endfunction

function void sdr_layr_awgn::connect_phase(uvm_phase phase);
    sdr_seqc_awgn_h.sdr_seqr_h = sdr_seqr_rx;
    sdr_seqc_awgn_h.sdr_aprt_rx.connect(sdr_aprt_rx);
    sdr_seqc_awgn_h.sdr_aprt_tx.connect(sdr_aprt_tx);
endfunction

task sdr_layr_awgn::run_phase(uvm_phase phase);
    sdr_seqc_awgn_h.start(sdr_seqr_tx);
endtask