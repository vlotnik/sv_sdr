//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_sampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_sampler extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_sampler)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sdr_sampler                         sdr_sampler_h;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_sampler::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_sampler, sdr_sampler_h)
endtask

task sdr_seqc_sampler::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);
        copy_item();

        start_item(sdr_seqi_tx);
            sdr_sampler_h.get_sym_v(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();
    end
endtask