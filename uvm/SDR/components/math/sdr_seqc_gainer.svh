//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_gainer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_gainer extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_gainer)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sdr_gainer                          sdr_gainer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_gainer::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_gainer, sdr_gainer_h)
endtask

task sdr_seqc_gainer::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        sdr_gainer_h.gain(sdr_seqi_tx);

        sdr_aprt_rx.write(sdr_seqi_rx);
        sdr_aprt_tx.write(sdr_seqi_tx);

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask