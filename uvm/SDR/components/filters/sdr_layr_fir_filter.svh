//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_layr_fir_filter
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_layr_fir_filter #(
      BYPASS = 0
) extends sdr_base_layr;
    `uvm_component_utils(sdr_layr_fir_filter #(BYPASS))
    `uvm_component_new

    // functions
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    sdr_seqc_fir_filter #(
          BYPASS
    )                                   sdr_seqc_fir_filter_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_layr_fir_filter::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_component_create(sdr_seqc_fir_filter #(BYPASS), sdr_seqc_fir_filter_h)
endfunction

function void sdr_layr_fir_filter::connect_phase(uvm_phase phase);
    sdr_seqc_fir_filter_h.sdr_seqr_h = sdr_seqr_rx;
endfunction

task sdr_layr_fir_filter::run_phase(uvm_phase phase);
    sdr_seqc_fir_filter_h.start(sdr_seqr_tx);
endtask