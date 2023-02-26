//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_buffer
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_buffer extends uvm_sequence #(sdr_seqi);
    `uvm_object_utils(sdr_seqc_buffer)
    `uvm_object_new

    sdr_seqr                            sdr_seqr_h;
    sdr_seqi                            sdr_seqi_rx;
    sdr_seqi                            sdr_seqi_tx;

    bit no_more_data;
    int size_of_nar = 0;
    int ptr_id = 0;
    int ptr_data;
    int ptr_valid;
    int seqi_sz;

    extern task pre_body();
    extern task body();

    extern function void parse_item();
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_buffer::pre_body();
    no_more_data = 0;
    ptr_data = 0;
    ptr_valid = 0;
    seqi_sz = 0;

    `uvm_object_create(sdr_seqi, sdr_seqi_tx)
endtask

task sdr_seqc_buffer::body();
    forever begin
        if (ptr_data == 0) begin
            if (no_more_data == 0) begin
                sdr_seqr_h.get_next_item(sdr_seqi_rx);                          // get_next_item
                if (sdr_seqi_rx.tr_last == 1) begin
                    $display("GOT LAST TRANSACTION");
                    no_more_data = 1;
                end
                ptr_data++;
                if (sdr_seqi_rx.data_re.size > 0)
                    seqi_sz = sdr_seqi_rx.data_re.size;
                else
                    seqi_sz = sdr_seqi_rx.tr_frsz;
            end
        end

        parse_item();
        start_item(sdr_seqi_tx);
        finish_item(sdr_seqi_tx);

        if (ptr_data >= (seqi_sz+1) && ptr_valid >= sdr_seqi_rx.valid[seqi_sz].size - 1) begin
            sdr_seqr_h.item_done();                                             // item_done
            ptr_data = 0;
            ptr_valid = 0;
        end
    end
endtask

function void sdr_seqc_buffer::parse_item();
    sdr_seqi_tx.new_seqi(1);
    sdr_seqi_tx.valid[0] = new[1];
    sdr_seqi_tx.valid[0][0] = sdr_seqi_rx.valid[ptr_data-1][ptr_valid];
    sdr_seqi_tx.first[0] = sdr_seqi_rx.first[ptr_data-1];
    sdr_seqi_tx.last[0] = sdr_seqi_rx.last[ptr_data-1];
    sdr_seqi_tx.keep[0] = sdr_seqi_rx.keep[ptr_data-1];
    sdr_seqi_tx.data_sym[0] = sdr_seqi_rx.data_sym[ptr_data-1];
    sdr_seqi_tx.data_re[0] = sdr_seqi_rx.data_re[ptr_data-1];
    sdr_seqi_tx.data_im[0] = sdr_seqi_rx.data_im[ptr_data-1];
    sdr_seqi_tx.data_scr[0] = sdr_seqi_rx.data_scr[ptr_data-1];
    sdr_seqi_tx.user_mark[0] = sdr_seqi_rx.user_mark[ptr_data-1];
    sdr_seqi_tx.user_mod[0] = sdr_seqi_rx.user_mod[ptr_data-1];
    sdr_seqi_tx.id[0] = ptr_id;
    sdr_seqi_tx.tr_modcod = sdr_seqi_rx.tr_modcod;
    if (ptr_valid == sdr_seqi_rx.valid[ptr_data-1].size - 1) begin
        ptr_data++;
        ptr_valid = 0;
    end else
        ptr_valid++;
endfunction