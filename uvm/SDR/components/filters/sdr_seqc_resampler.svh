//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_resampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_resampler extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_resampler)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    int filter_type = 1;
    real cutoff = 0.5;

    sdr_filter_design                   filter_design_h;
    sdr_resampler                       sdr_resampler_main;
    real fir_coefficients[];

    sdr_resampler                       sdr_resampler_oqpsk;
    real oqpsk_coefficients[];
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_resampler::pre_body();
    super.pre_body();

    filter_design_h = new();
    if (filter_type == 2)
        fir_coefficients = filter_design_h.rcosdesign(0.35, cutoff / 4096, 15 * 4096);
    else
        fir_coefficients = filter_design_h.rcosdesign_sqrt(0.35, cutoff / 4096, 15 * 4096);
    `uvm_object_create(sdr_resampler, sdr_resampler_main)
    sdr_resampler_main.set_coefficients(fir_coefficients, 15, 4096);

    if (filter_type == 2)
        oqpsk_coefficients = filter_design_h.rcosdesign(0.35, 0.25 / 4096, 15 * 4096);
    else
        oqpsk_coefficients = filter_design_h.rcosdesign_sqrt(0.35, 0.25 / 4096, 15 * 4096);
    `uvm_object_create(sdr_resampler, sdr_resampler_oqpsk)
    sdr_resampler_oqpsk.set_coefficients(oqpsk_coefficients, 15, 4096);
endtask

task sdr_seqc_resampler::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        if (sdr_seqi_tx.tr_mod == OQPSK)
            sdr_resampler_oqpsk.resample(sdr_seqi_tx);
        else
            sdr_resampler_main.resample(sdr_seqi_tx);

        if (sdr_seqi_tx.tr_reset == 1) begin
            sdr_resampler_oqpsk.reset();
            sdr_resampler_main.reset();
        end

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask