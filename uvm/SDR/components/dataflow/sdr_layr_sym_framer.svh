//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_sym_framer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_sym_framer extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_sym_framer)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // sequence
    sdr_seqc_sym_framer                 sdr_seqc_sym_framer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_sym_framer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_sym_framer, sdr_seqc_sym_framer_h)
endfunction

function void sdr_layr_sym_framer::connect_phase(uvm_phase phase);
    sdr_seqc_sym_framer_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_sym_framer::run_phase(uvm_phase phase);
    sdr_seqc_sym_framer_h.start(sdr_seqr_tx);
endtask