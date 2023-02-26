//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_fir_filter
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_fir_filter #(
      BYPASS = 0
) extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_fir_filter #(BYPASS))
    `uvm_object_new

    // functions
    extern task pre_body();
    extern task body();

    real fir_coefficients[];

    // objects
    sdr_filter_design                   filter_design_h;
    sdr_fir_filter                      sdr_fir_filter_h;
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_fir_filter::pre_body();
    super.pre_body();
    filter_design_h = new();
    fir_coefficients = filter_design_h.rcosdesign(0.35, 0.25, 32);
    `uvm_object_create(sdr_fir_filter, sdr_fir_filter_h)
    sdr_fir_filter_h.set_coefficients(fir_coefficients);
endtask

task sdr_seqc_fir_filter::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();
        start_item(sdr_seqi_tx);
            if (BYPASS == 0)
                sdr_fir_filter_h.filt(sdr_seqi_tx);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask