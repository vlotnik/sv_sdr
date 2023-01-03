//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator_cvrb
//--------------------------------------------------------------------------------------------------------------------------------
class sin_cos_generator_cvrb #(
      PHASE_W = 12
) extends uvm_subscriber #(raxi_seqi);
    `uvm_component_param_utils(sin_cos_generator_cvrb #(PHASE_W))

    localparam                          RAXI_DW_RX = PHASE_W;
    localparam                          PHASE_MAX = 2**(PHASE_W) - 1;

    extern function new(string name, uvm_component parent);
    extern function void report_phase(uvm_phase phase);

    int cp_phase;

    covergroup cg_phase with function sample(int phase);
        coverpoint cp_phase {
            bins phase[] = {[0:PHASE_MAX-1]};
        }
    endgroup

    extern function void write(raxi_seqi t);
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function sin_cos_generator_cvrb::new(string name, uvm_component parent);
    super.new(name, parent);
    cg_phase = new();
endfunction

function void sin_cos_generator_cvrb::report_phase(uvm_phase phase);
    // `uvm_info("MODCODS COVERAGE:", $sformatf("%0d%%", cg_modcod.get_coverage()), UVM_HIGH)
endfunction

function void sin_cos_generator_cvrb::write(raxi_seqi t);
    bit[RAXI_DW_RX-1:0] raxi_rx_data;

    bit[PHASE_W-1:0] rx_phase;

    raxi_rx_data = {<<{t.data}};

    // parse rx
    rx_phase = raxi_rx_data;
    cp_phase = rx_phase;

    cg_phase.sample(cp_phase);
endfunction