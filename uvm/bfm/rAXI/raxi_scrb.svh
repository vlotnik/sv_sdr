//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_scrb
//--------------------------------------------------------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_tx)

class raxi_scrb extends uvm_scoreboard;
    `uvm_component_utils(raxi_scrb)
    `uvm_component_new

    // base UVM functions
    extern function void report_phase(uvm_phase phase);

    // arrays
    raxi_seqi raxi_seqi_queue_rx[$];
    raxi_seqi raxi_seqi_queue_tx[$];

    // sim model
    int fail_cnt = 0;
    bit data_good = 0;

    extern virtual function void write_rx(raxi_seqi raxi_seqi_h);
    extern virtual function void write_tx(raxi_seqi raxi_seqi_h);

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void raxi_scrb::write_rx(raxi_seqi raxi_seqi_h);
    raxi_seqi_queue_rx.push_back(raxi_seqi_h);
    `uvm_info("SCRB", $sformatf("\nPING... sequence with %s", raxi_seqi_h.convert2string()), UVM_FULL);
endfunction

function void raxi_scrb::write_tx(raxi_seqi raxi_seqi_h);
    raxi_seqi_queue_tx.push_back(raxi_seqi_h);
    `uvm_info("SCRB", $sformatf("\n...PONG sequence with %s", raxi_seqi_h.convert2string()), UVM_FULL);
endfunction

function void raxi_scrb::report_phase(uvm_phase phase);
    if (fail_cnt > 0 || data_good == 0) begin
        `uvm_info("TEST_FAILED", "", UVM_NONE)
    end else begin
        `uvm_info("TEST_PASSED", "", UVM_NONE)
    end
endfunction