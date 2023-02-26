//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_iq_scrambler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_iq_scrambler extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_iq_scrambler)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_iq_scrambler               sdr_seqc_iq_scrambler_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_iq_scrambler::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_iq_scrambler, sdr_seqc_iq_scrambler_h)
endfunction

function void sdr_layr_iq_scrambler::connect_phase(uvm_phase phase);
    sdr_seqc_iq_scrambler_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_iq_scrambler::run_phase(uvm_phase phase);
    sdr_seqc_iq_scrambler_h.start(sdr_seqr_tx);
endtask