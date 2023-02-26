//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_summator
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_summator #(
      NOFCH = 1
) extends uvm_sequence #(sdr_seqi);
    `uvm_object_param_utils(sdr_seqc_summator #(NOFCH))
    `uvm_object_new

    // settings
    bit[NOFCH-1:0] no_more_data;
    int size_of_nar = 0;
    int ptr_data[NOFCH];
    int seqi_sz[NOFCH];
    int tr_ptr;

    real tr_gain = 1.0;

    // distortion
    real dist_re = 0.0;
    real dist_im = 0.0;
    real amp = 0.0;
    real ort = 0.0;
    int zsc_re = 0.0;
    int zsc_im = 0.0;

    // functions
    extern function void parse_item();
    extern task pre_body();
    extern task body();

    // objects
    sdr_seqr                            sdr_seqr_h[NOFCH];
    sdr_seqi                            sdr_seqi_rx[NOFCH];
    sdr_seqi                            sdr_seqi_tx;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_seqc_summator::parse_item();
    sdr_seqi_tx.new_seqi(1);
    sdr_seqi_tx.tr_gain = this.tr_gain;
    sdr_seqi_tx.tr_last = sdr_seqi_rx[0].tr_last;
    sdr_seqi_tx.valid[0] = new[1];
    sdr_seqi_tx.valid[0][0] = 1;

    sdr_seqi_tx.data_re[0] = 0;
    sdr_seqi_tx.data_im[0] = 0;
    sdr_seqi_tx.first[0] = sdr_seqi_rx[0].first[ptr_data[0]-1];
    sdr_seqi_tx.last[0] = sdr_seqi_rx[0].last[ptr_data[0]-1];

    for (int ch = 0; ch < NOFCH; ch++) begin
        sdr_seqi_tx.data_re[0] += sdr_seqi_rx[ch].data_re[ptr_data[ch]-1];
        sdr_seqi_tx.data_im[0] += sdr_seqi_rx[ch].data_im[ptr_data[ch]-1];
        ptr_data[ch]++;
    end

    dist_re = $itor(sdr_seqi_tx.data_re[0]);
    dist_im = $itor(sdr_seqi_tx.data_im[0]);

    // add amplitude imbalance
    dist_re = dist_re * (1.0 + amp);
    // add non orthogonality
    dist_re = dist_re + (dist_im * $sin(ort));

    sdr_seqi_tx.data_re[0] = $rtoi(dist_re);

    // add zero shift
    sdr_seqi_tx.data_re[0] += zsc_re;
    sdr_seqi_tx.data_im[0] += zsc_im;
endfunction

task sdr_seqc_summator::pre_body();
    for (int ii = 0; ii < NOFCH; ii++) begin
        no_more_data[ii] = 0;
        ptr_data[ii] = 0;
        seqi_sz[ii] = 0;
        tr_ptr = 0;
    end

    `uvm_object_create(sdr_seqi, sdr_seqi_tx)
endtask

task sdr_seqc_summator::body();
    forever begin
        for (int ch = 0; ch < NOFCH; ch++) begin
            if (ptr_data[ch] == 0) begin
                if (no_more_data[ch] == 0) begin
                    sdr_seqr_h[ch].get_next_item(sdr_seqi_rx[ch]);              // get_next_item
                    ptr_data[ch]++;
                    seqi_sz[ch] = sdr_seqi_rx[ch].data_re.size;
                end
            end
        end

        parse_item();

        start_item(sdr_seqi_tx);
        finish_item(sdr_seqi_tx);

        for (int ch = 0; ch < NOFCH; ch++) begin
            if (ptr_data[ch] >= (seqi_sz[ch]+1)) begin
                if (no_more_data[ch] == 0) begin
                    sdr_seqr_h[ch].item_done();                                 // item_done
                    ptr_data[ch] = 0;

                    if (sdr_seqi_rx[ch].tr_last == 1) begin
                        $display("GOT LAST TRANSACTION FOR CHANNEL %0d", ch);
                        no_more_data[ch] = 1;
                    end
                end
            end
        end
    end
endtask