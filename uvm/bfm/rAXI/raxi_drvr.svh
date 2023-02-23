//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_drvr
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_drvr #(
      DW = RAXI_DEFAULT_DW
    , UW = RAXI_DEFAULT_UW
    , IW = RAXI_DEFAULT_IW
) extends uvm_driver #(raxi_seqi);
    `uvm_component_param_utils(raxi_drvr #(DW, UW, IW))
    `uvm_component_new

    bit mode = RAXI_DRVR_MODE_RX;

    extern task run_phase(uvm_phase phase);

    virtual raxi_bfm #(
          .DW(DW)
        , .UW(UW)
        , .IW(IW)
    )                                   raxi_bfm_h;
    raxi_seqi                           raxi_seqi_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task raxi_drvr::run_phase(uvm_phase phase);
    forever begin
        @(posedge raxi_bfm_h.clk);

        if (mode == RAXI_DRVR_MODE_RX) begin
            // RX part

            while (raxi_bfm_h.ready == 0) begin
                @(posedge raxi_bfm_h.clk);
            end

            seq_item_port.get_next_item(raxi_seqi_h);

                raxi_bfm_h.reset <= raxi_seqi_h.reset;
                raxi_bfm_h.valid <= raxi_seqi_h.valid;
                raxi_bfm_h.first <= raxi_seqi_h.first;
                raxi_bfm_h.last <= raxi_seqi_h.last;
                raxi_bfm_h.keep <= raxi_seqi_h.keep;
                raxi_bfm_h.data <= {<<{raxi_seqi_h.data}};
                raxi_bfm_h.user <= {<<{raxi_seqi_h.user}};
                raxi_bfm_h.id <= {<<{raxi_seqi_h.id}};

            seq_item_port.item_done();

        end

        if (mode == RAXI_DRVR_MODE_TX) begin
            // TX part

            while (raxi_bfm_h.ready == 1 && raxi_bfm_h.valid == 0) begin
                @(posedge raxi_bfm_h.clk);
            end

            seq_item_port.get_next_item(raxi_seqi_h);

                raxi_bfm_h.ready <= raxi_seqi_h.ready;

            seq_item_port.item_done();

        end
    end
//--------------------------------------------------------------------------------------------------------------------------------
endtask