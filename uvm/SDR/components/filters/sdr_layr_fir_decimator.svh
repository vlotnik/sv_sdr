//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_fir_decimator
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_fir_decimator extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_fir_decimator)
    `uvm_component_new

    // functions
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // settings
    real rolloff = 0.35;
    real cutoff = 0.5;
    int decimation = 1;

    sdr_seqc_fir_decimator              sdr_seqc_fir_decimator_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_fir_decimator::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_fir_decimator, sdr_seqc_fir_decimator_h)
    sdr_seqc_fir_decimator_h.rolloff = this.rolloff;
    sdr_seqc_fir_decimator_h.cutoff = this.cutoff;
    sdr_seqc_fir_decimator_h.decimation = this.decimation;
    sdr_seqc_fir_decimator_h.decimation = 8;
endfunction

function void sdr_layr_fir_decimator::connect_phase(uvm_phase phase);
    sdr_seqc_fir_decimator_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_fir_decimator::run_phase(uvm_phase phase);
    sdr_seqc_fir_decimator_h.start(sdr_seqr_tx);
endtask