//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_base_scrb
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_base_scrb extends uvm_scoreboard;
    `uvm_component_utils(sdr_base_scrb)
    `uvm_component_new

    // report settings
    int id = 0;
    bit data_good = 0;
    int fail_cnt = 0;
    string test_name = "test";
    int fid_result;

    extern function void report_phase(uvm_phase phase);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_base_scrb::report_phase(uvm_phase phase);
    if (fail_cnt > 0 || data_good == 0) begin
        `uvm_info("TEST_FAILED", "", UVM_NONE)
    end else begin
        `uvm_info("TEST_PASSED", "", UVM_NONE)
    end
endfunction