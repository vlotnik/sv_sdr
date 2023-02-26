//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_resampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_resampler extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_resampler)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    int filter_type = 1;
    real cutoff = 0.5;

    // sequence
    sdr_seqc_resampler                  sdr_seqc_resampler_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_resampler::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_resampler, sdr_seqc_resampler_h)
    sdr_seqc_resampler_h.filter_type = this.filter_type;
    sdr_seqc_resampler_h.cutoff = this.cutoff;
endfunction

function void sdr_layr_resampler::connect_phase(uvm_phase phase);
    sdr_seqc_resampler_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_resampler::run_phase(uvm_phase phase);
    sdr_seqc_resampler_h.start(sdr_seqr_tx);
endtask