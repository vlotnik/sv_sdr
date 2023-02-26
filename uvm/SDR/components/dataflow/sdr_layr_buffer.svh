//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_buffer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_buffer extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_buffer)
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    // buffer sequence handler
    sdr_seqc_buffer                     sdr_seqc_buffer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_buffer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_buffer, sdr_seqc_buffer_h)
endfunction

function void sdr_layr_buffer::connect_phase(uvm_phase phase);
    sdr_seqc_buffer_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_buffer::run_phase(uvm_phase phase);
    sdr_seqc_buffer_h.start(sdr_seqr_tx);
endtask