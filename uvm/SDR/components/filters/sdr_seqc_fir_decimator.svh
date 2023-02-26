//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_fir_decimator
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_fir_decimator extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_fir_decimator)
    `uvm_object_new

    // functions
    extern task pre_body();
    extern task body();

    // settings
    real rolloff = 0.35;
    real cutoff = 0.5;
    int decimation = 1;
    real fir_coefficients[];

    // objects
    sdr_filter_design                   filter_design_h;
    sdr_fir_filter                      sdr_fir_filter_h;

    extern function automatic void decimate(ref sdr_seqi sdr_seqi_h);

    protected int result_re[$];
    protected int result_im[$];
    protected int ptr = 0;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_fir_decimator::pre_body();
    super.pre_body();
    filter_design_h = new();

    fir_coefficients = filter_design_h.rcosdesign_sqrt(rolloff, cutoff, 32);
    `uvm_object_create(sdr_fir_filter, sdr_fir_filter_h)
    sdr_fir_filter_h.set_coefficients(fir_coefficients);
endtask

task sdr_seqc_fir_decimator::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();
        start_item(sdr_seqi_tx);
            // sdr_fir_filter_h.filt(sdr_seqi_tx);
            decimate(sdr_seqi_tx);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask

function automatic void sdr_seqc_fir_decimator::decimate(ref sdr_seqi sdr_seqi_h);
    int old_size = sdr_seqi_h.data_re.size();

    result_re.delete();
    result_im.delete();

    for (int ii = 0; ii < old_size; ii++) begin
        if (ptr == 0) begin
            result_re.push_back(sdr_seqi_h.data_re[ii]);
            result_im.push_back(sdr_seqi_h.data_im[ii]);
        end

        if (ptr < decimation - 1)
            ptr++;
        else
            ptr = 0;
    end

    sdr_seqi_h.data_re = result_re;
    sdr_seqi_h.data_im = result_im;
endfunction