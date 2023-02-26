//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_sampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_sampler extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_sampler)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_sampler                    sdr_seqc_sampler_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_sampler::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_sampler, sdr_seqc_sampler_h)
endfunction

function void sdr_layr_sampler::connect_phase(uvm_phase phase);
    sdr_seqc_sampler_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_sampler::run_phase(uvm_phase phase);
    sdr_seqc_sampler_h.start(sdr_seqr_tx);
endtask