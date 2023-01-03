//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator_seqi
//--------------------------------------------------------------------------------------------------------------------------------
class sin_cos_generator_seqi #(
      PHASE_W = 10
) extends raxi_seqi;
    `uvm_object_param_utils(sin_cos_generator_seqi #(PHASE_W))
    `uvm_object_new

    extern function void post_randomize();

    localparam RAXI_DW = PHASE_W;
    localparam PHASE_MAX = 2**(PHASE_W) - 1;

    int phase;

    bit[PHASE_W-1:0]                    raxi_data_phase;
    bit[RAXI_DW-1:0]                    raxi_data;

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sin_cos_generator_seqi::post_randomize();
    this.valid = $urandom_range(0, 1);
    if (this.valid == 1) begin
        phase = $urandom_range(0, PHASE_MAX);
    end

    raxi_data_phase = phase;

    this.data = {<<{raxi_data_phase}};

//--------------------------------------------------------------------------------------------------------------------------------
endfunction