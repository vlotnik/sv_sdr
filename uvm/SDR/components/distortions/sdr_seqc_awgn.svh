//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_awgn
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_awgn extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_awgn)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sdr_awgn                            sdr_awgn_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_awgn::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_awgn, sdr_awgn_h)
endtask

task sdr_seqc_awgn::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        sdr_awgn_h.add_awgn(sdr_seqi_tx);

        sdr_aprt_rx.write(sdr_seqi_rx);
        sdr_aprt_tx.write(sdr_seqi_tx);

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask