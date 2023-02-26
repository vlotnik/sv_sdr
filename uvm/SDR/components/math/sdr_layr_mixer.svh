//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_mixer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_mixer extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_mixer)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_mixer                      sdr_seqc_mixer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_mixer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_mixer, sdr_seqc_mixer_h)
endfunction

function void sdr_layr_mixer::connect_phase(uvm_phase phase);
    sdr_seqc_mixer_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_mixer::run_phase(uvm_phase phase);
    sdr_seqc_mixer_h.start(sdr_seqr_tx);
endtask