//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_mont
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_mont #(
      DW = 8
    , UW = 8
    , IW = 8
) extends uvm_component;
    `uvm_component_param_utils(raxi_mont #(DW, UW, IW));
    `uvm_component_new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    virtual raxi_bfm #(
          .DW(DW)
        , .UW(UW)
        , .IW(IW)
    )                                   raxi_bfm_h;

    raxi_aprt                           raxi_aprt_h;
    raxi_seqi                           raxi_seqi_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void raxi_mont::build_phase(uvm_phase phase);
    // build analysis ports
    raxi_aprt_h = new("raxi_aprt_h", this);
//--------------------------------------------------------------------------------------------------------------------------------
endfunction

task raxi_mont::run_phase(uvm_phase phase);
    forever @(posedge raxi_bfm_h.clk) begin
        `uvm_object_create(raxi_seqi, raxi_seqi_h)
        raxi_seqi_h.reset = raxi_bfm_h.reset;
        raxi_seqi_h.valid = raxi_bfm_h.valid;
        raxi_seqi_h.first = raxi_bfm_h.first;
        raxi_seqi_h.last = raxi_bfm_h.last;
        raxi_seqi_h.keep = raxi_bfm_h.keep;
        raxi_seqi_h.ready = raxi_bfm_h.ready;
        raxi_seqi_h.data = {<<{raxi_bfm_h.data}};
        raxi_seqi_h.user = {<<{raxi_bfm_h.user}};
        raxi_seqi_h.id = {<<{raxi_bfm_h.id}};
        raxi_aprt_h.write(raxi_seqi_h);

        `uvm_info(get_name(), $sformatf("\nRAXI monitor : %s", raxi_seqi_h.convert2string()), UVM_FULL);
    end
//--------------------------------------------------------------------------------------------------------------------------------
endtask