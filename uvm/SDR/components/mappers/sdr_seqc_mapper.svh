//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_mapper
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_mapper extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_mapper)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sdr_mapper                          sdr_mapper_h;

    // settings
    int mod_type;
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_mapper::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_mapper, sdr_mapper_h)
endtask

task sdr_seqc_mapper::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        copy_item();

        mod_type = pkg_sv_sdr::get_modulation_settings(sdr_seqi_tx.tr_mod).mod_type;
        if (mod_type == 0) begin
            sdr_mapper_h.get_iq(sdr_seqi_tx);
        end
        sdr_seqi_tx.tr_power = sdr_mapper_h.get_plane_power(sdr_seqi_tx.tr_mod);

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // sdr_seqr_h
    end
endtask