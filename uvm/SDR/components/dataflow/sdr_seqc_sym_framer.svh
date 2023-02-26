//-------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_sym_framer
//-------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_sym_framer extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_sym_framer)
    `uvm_object_new

    extern task body();

    // create symbol array
    int symsz = 1;
    int digit = 0;

    // settings
    bit bit_order = 0;
//-------------------------------------------------------------------------------------------------------------------------------
endclass

//-------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//-------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_sym_framer::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        // get settings from input transaction
        this.tr_mod = sdr_seqi_rx.tr_mod;
        this.tr_pldsz = sdr_seqi_rx.tr_pldsz;
        // calculate other settings
        symsz = pkg_sv_sdr::get_modulation_settings(tr_mod).symbol_size;
        this.tr_frsz = this.tr_pldsz % symsz == 0 ? this.tr_pldsz / symsz : this.tr_pldsz / symsz + 1;

        copy_item();
        // create new transaction

        // create array of symbols
        sdr_seqi_tx.data_sym = new[tr_frsz];
        sdr_seqi_tx.first = new[tr_frsz];
        sdr_seqi_tx.last = new[tr_frsz];
        sym_ptr = 0;
        for (int ptr = 0; ptr < tr_pldsz; ptr++) begin
            sym_ptr = ptr / symsz;
            if (bit_order == 0)
                // MSB first
                digit = (symsz - 1) - ptr % symsz;
            else
                // LSB first
                digit = ptr % symsz;
            sdr_seqi_tx.data_sym[sym_ptr] += sdr_seqi_tx.data_bit[ptr] << digit;
        end

        // create array of valids
        sdr_seqi_tx.valid = new[sdr_seqi_tx.data_sym.size()];
        for (int ii = 0; ii < sdr_seqi_tx.data_sym.size(); ii++) begin
            sdr_seqi_tx.valid[ii] = new[1];
            sdr_seqi_tx.valid[ii][0] = 1;
        end

        sdr_seqi_tx.first[0] = 1;
        sdr_seqi_tx.last[tr_frsz - 1] = 1;
        sdr_seqi_tx.tr_frsz = tr_frsz;

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string()), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask