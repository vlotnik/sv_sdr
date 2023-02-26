//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_iq_scrambler
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_iq_scrambler extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_iq_scrambler)
    `uvm_object_new

    extern task pre_body();
    extern task body();
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_iq_scrambler::pre_body();
    super.pre_body();
endtask

task sdr_seqc_iq_scrambler::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        for (int ii = 0; ii < sdr_seqi_tx.data_re.size; ii++) begin
            case (sdr_seqi_tx.data_scr[ii])
                2'b00 : begin
                    sdr_seqi_tx.data_re[ii] = sdr_seqi_rx.data_re[ii];
                    sdr_seqi_tx.data_im[ii] = sdr_seqi_rx.data_im[ii];
                end
                2'b01 : begin
                    sdr_seqi_tx.data_re[ii] = -sdr_seqi_rx.data_im[ii];
                    sdr_seqi_tx.data_im[ii] = sdr_seqi_rx.data_re[ii];
                end
                2'b10 : begin
                    sdr_seqi_tx.data_re[ii] = -sdr_seqi_rx.data_re[ii];
                    sdr_seqi_tx.data_im[ii] = -sdr_seqi_rx.data_im[ii];
                end
                2'b11 : begin
                    sdr_seqi_tx.data_re[ii] = sdr_seqi_rx.data_im[ii];
                    sdr_seqi_tx.data_im[ii] = -sdr_seqi_rx.data_re[ii];
                end
            endcase
        end

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask