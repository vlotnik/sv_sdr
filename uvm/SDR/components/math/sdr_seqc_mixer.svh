//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_mixer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_mixer extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_mixer)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sdr_mixer                           sdr_mixer_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_mixer::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_mixer, sdr_mixer_h)
endtask

task sdr_seqc_mixer::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        sdr_mixer_h.mix(sdr_seqi_tx);
        if (sdr_seqi_tx.tr_reset == 1)
            sdr_mixer_h.reset();

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask