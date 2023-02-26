//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_mch_buffer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_mch_buffer #(
    NOFCH = 1,
    NOFTR = 0
) extends uvm_component;
    `uvm_component_param_utils(sdr_layr_mch_buffer #(NOFCH, NOFTR))
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // input sequencer
    sdr_seqr                            sdr_seqr_rx[NOFCH];

    // multichannel sequence handler
    sdr_seqc_mch_buffer #(
          .NOFCH(NOFCH)
        , .NOFTR(NOFTR)
    )                                   sdr_seqc_mch_buffer_h;

    // output sequencer
    sdr_seqr                            sdr_seqr_tx;
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_mch_buffer::build_phase(uvm_phase phase);
    foreach (sdr_seqr_rx[ii])
        `uvm_component_create(uvm_sequencer #(sdr_seqi), sdr_seqr_rx[ii], ii)

    `uvm_component_create(sdr_seqc_mch_buffer #(NOFCH, NOFTR), sdr_seqc_mch_buffer_h)
endfunction

function void sdr_layr_mch_buffer::connect_phase(uvm_phase phase);
    sdr_seqc_mch_buffer_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_mch_buffer::run_phase(uvm_phase phase);
    sdr_seqc_mch_buffer_h.start(sdr_seqr_tx);
endtask