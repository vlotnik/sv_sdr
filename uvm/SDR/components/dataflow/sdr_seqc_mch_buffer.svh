//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_mch_buffer
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_mch_buffer #(
      NOFCH = 1
    , NOFTR = 0
) extends uvm_sequence #(sdr_seqi);
    `uvm_object_param_utils(sdr_seqc_mch_buffer #(NOFCH, NOFTR))
    `uvm_object_new

    sdr_seqr                            sdr_seqr_h[NOFCH];
    sdr_seqi                            sdr_seqi_rx[NOFCH];
    sdr_seqi                            sdr_seqi_tx;

    bit[NOFCH-1:0] no_more_data;
    int size_of_nar = 0;
    int ptr_id = 0;
    int ptr_data[NOFCH];
    int ptr_valid[NOFCH];
    int seqi_sz[NOFCH];
    int tr_ptr;

    extern task pre_body();
    extern task body();

    extern function void parse_item();
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_mch_buffer::pre_body();
    for (int ii = 0; ii < NOFCH; ii++) begin
        no_more_data[ii] = 0;
        ptr_data[ii] = 0;
        ptr_valid[ii] = 0;
        seqi_sz[ii] = 0;
        tr_ptr = 0;
    end

    `uvm_object_create(sdr_seqi, sdr_seqi_tx)
endtask

task sdr_seqc_mch_buffer::body();
    forever begin
        if (ptr_data[ptr_id] == 0) begin
            if (no_more_data[ptr_id] == 0) begin
                sdr_seqr_h[ptr_id].get_next_item(sdr_seqi_rx[ptr_id]);          // get_next_item
                if (tr_ptr == 0)
                    tr_ptr = NOFTR;
                if (sdr_seqi_rx[ptr_id].tr_last == 1) begin
                    $display("GOT LAST TRANSACTION FOR CHANNEL %0d", ptr_id);
                    no_more_data[ptr_id] = 1;
                    tr_ptr = NOFTR > 0 ? 1 : 0;
                end
                ptr_data[ptr_id]++;
                if (sdr_seqi_rx[ptr_id].data_re.size > 0)
                    seqi_sz[ptr_id] = sdr_seqi_rx[ptr_id].data_re.size;
                else
                    seqi_sz[ptr_id] = sdr_seqi_rx[ptr_id].tr_frsz;
            end
        end

        parse_item();
        start_item(sdr_seqi_tx);
        finish_item(sdr_seqi_tx);

        if (ptr_data[ptr_id] >= (seqi_sz[ptr_id]+1) && ptr_valid[ptr_id] >= sdr_seqi_rx[ptr_id].valid[seqi_sz[ptr_id]].size - 1) begin
            sdr_seqr_h[ptr_id].item_done();                                     // item_done
            ptr_data[ptr_id] = 0;
            ptr_valid[ptr_id] = 0;
            if (tr_ptr > 0)
                tr_ptr--;
        end

        if (tr_ptr == 0) begin
            ptr_id++;
            ptr_id = ptr_id == NOFCH ? 0 : ptr_id;
        end
    end
endtask

function void sdr_seqc_mch_buffer::parse_item();
    sdr_seqi_tx.new_seqi(1);
    sdr_seqi_tx.valid[0] = new[1];
    sdr_seqi_tx.valid[0][0] = sdr_seqi_rx[ptr_id].valid[ptr_data[ptr_id]-1][ptr_valid[ptr_id]];
    sdr_seqi_tx.first[0] = sdr_seqi_rx[ptr_id].first[ptr_data[ptr_id]-1];
    sdr_seqi_tx.last[0] = sdr_seqi_rx[ptr_id].last[ptr_data[ptr_id]-1];
    sdr_seqi_tx.keep[0] = sdr_seqi_rx[ptr_id].keep[ptr_data[ptr_id]-1];
    sdr_seqi_tx.data_sym[0] = sdr_seqi_rx[ptr_id].data_sym[ptr_data[ptr_id]-1];
    sdr_seqi_tx.data_re[0] = sdr_seqi_rx[ptr_id].data_re[ptr_data[ptr_id]-1];
    sdr_seqi_tx.data_im[0] = sdr_seqi_rx[ptr_id].data_im[ptr_data[ptr_id]-1];
    sdr_seqi_tx.data_scr[0] = sdr_seqi_rx[ptr_id].data_scr[ptr_data[ptr_id]-1];
    sdr_seqi_tx.user_mark[0] = sdr_seqi_rx[ptr_id].user_mark[ptr_data[ptr_id]-1];
    sdr_seqi_tx.user_mod[0] = sdr_seqi_rx[ptr_id].user_mod[ptr_data[ptr_id]-1];
    sdr_seqi_tx.id[0] = ptr_id;
    sdr_seqi_tx.tr_modcod = sdr_seqi_rx[ptr_id].tr_modcod;
    sdr_seqi_tx.tr_nofs = sdr_seqi_rx[ptr_id].tr_nofs;
    sdr_seqi_tx.tr_frsz = sdr_seqi_rx[ptr_id].tr_frsz;
    if (ptr_valid[ptr_id] == sdr_seqi_rx[ptr_id].valid[ptr_data[ptr_id]-1].size - 1) begin
        ptr_data[ptr_id]++;
        ptr_valid[ptr_id] = 0;
    end else
        ptr_valid[ptr_id]++;
endfunction