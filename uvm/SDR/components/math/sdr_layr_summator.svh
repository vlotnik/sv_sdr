//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_summator
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_summator #(
      NOFCH = 1
) extends uvm_component;
    `uvm_component_param_utils(sdr_layr_summator #(NOFCH))
    `uvm_component_new

    // settings
    real tr_gain = 1.0;
    real amp = 0.0;
    real ort = 0.0;
    int zsc_re = 0;
    int zsc_im = 0;

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // input sequencer
    sdr_seqr                            sdr_seqr_rx[NOFCH];

    // multichannel sequence handler
    sdr_seqc_summator #(
          NOFCH
    )                                   sdr_seqc_summator_h;

    // output sequencer
    sdr_seqr                            sdr_seqr_tx;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_summator::build_phase(uvm_phase phase);
    foreach (sdr_seqr_rx[ii])
        `uvm_component_create(uvm_sequencer #(sdr_seqi), sdr_seqr_rx[ii], ii)

    `uvm_component_create(sdr_seqc_summator #(NOFCH), sdr_seqc_summator_h)
    sdr_seqc_summator_h.tr_gain = this.tr_gain;
    sdr_seqc_summator_h.amp = this.amp;
    sdr_seqc_summator_h.ort = this.ort;
    sdr_seqc_summator_h.zsc_re = this.zsc_re;
    sdr_seqc_summator_h.zsc_im = this.zsc_im;
endfunction

function void sdr_layr_summator::connect_phase(uvm_phase phase);
    sdr_seqc_summator_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_summator::run_phase(uvm_phase phase);
    sdr_seqc_summator_h.start(sdr_seqr_tx);
endtask