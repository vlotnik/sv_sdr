//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_agnt
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_agnt #(
      DW = 8
    , UW = 8
    , IW = 8
) extends uvm_agent;
    `uvm_component_param_utils(raxi_agnt #(DW, UW, IW))
    `uvm_component_new

    // functions
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    // settings
    bit driver_mode = RX_MODE;
    uvm_active_passive_enum driver_is_active = UVM_ACTIVE;
    uvm_active_passive_enum monitor_is_active = UVM_ACTIVE;

    // interface
    virtual raxi_bfm #(
          .DW(DW)
        , .UW(UW)
        , .IW(IW)
    )                                   raxi_bfm_h;

    // sequencer
    raxi_seqr                           raxi_seqr_h;

    // driver
    raxi_drvr #(
          .DW(DW)
        , .UW(UW)
        , .IW(IW)
    )                                   raxi_drvr_h;

    // analysis port
    raxi_aprt                           raxi_aprt_h;

    // monitor
    raxi_mont #(
          .DW(DW)
        , .UW(UW)
        , .IW(IW)
    )                                   raxi_mont_h;

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void raxi_agnt::build_phase(uvm_phase phase);
    // driver is active
    if (this.driver_is_active == UVM_ACTIVE) begin
        `uvm_component_create(uvm_sequencer #(raxi_seqi), raxi_seqr_h)
        `uvm_component_create(raxi_drvr #(DW, UW, IW), raxi_drvr_h)
        raxi_drvr_h.mode = this.driver_mode;
    end

    // monitor is active
    if (this.monitor_is_active == UVM_ACTIVE) begin
        `uvm_component_create(raxi_mont #(DW, UW, IW), raxi_mont_h)
        raxi_aprt_h = new("raxi_aprt_h", this);
    end
//--------------------------------------------------------------------------------------------------------------------------------
endfunction

function void raxi_agnt::connect_phase(uvm_phase phase);
    // connect driver
    if (this.driver_is_active == UVM_ACTIVE) begin
        raxi_drvr_h.raxi_bfm_h = this.raxi_bfm_h;
        raxi_drvr_h.seq_item_port.connect(raxi_seqr_h.seq_item_export);
    end

    // connect monitor
    if (this.monitor_is_active == UVM_ACTIVE) begin
        raxi_mont_h.raxi_bfm_h = this.raxi_bfm_h;
        raxi_mont_h.raxi_aprt_h.connect(raxi_aprt_h);
    end
//--------------------------------------------------------------------------------------------------------------------------------
endfunction
