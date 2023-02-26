//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_spmod
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_spmod extends sdr_base_seqc;
    `uvm_object_utils(sdr_seqc_spmod)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    int fsk_sps = 4;
    int fsk_sps_prev = 0;
    int symsz;
    int mod_type;

    protected int oqpsk_re[];
    protected int oqpsk_im[];
    protected bit oqpsk_first[];
    protected bit oqpsk_last[];

    protected real fsk_phase = 0;
    protected bit fsk_keep[];
    protected int fsk_re[];
    protected int fsk_im[];
    protected int fsk_user_mark[];
    protected real fsk_angle[];

    sdr_gauss_filter                    filt_h;

    extern function automatic void fskmod_init_angles(sdr_seqi sdr_seqi_h);
    extern function automatic void gauss_filt(real bt);
    extern function automatic void fskmod(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_spmod::pre_body();
    super.pre_body();

    `uvm_object_create(sdr_gauss_filter, filt_h)
endtask

task sdr_seqc_spmod::body();
    forever begin
        sdr_seqr_h.get_next_item(sdr_seqi_rx);                                  // get_next_item

        tr_mod = sdr_seqi_rx.tr_mod;
        tr_fsk_dev = sdr_seqi_rx.tr_fsk_dev;
        tr_fsk_bt = sdr_seqi_rx.tr_fsk_bt;
        symsz = pkg_sv_sdr::get_modulation_settings(tr_mod).symbol_size;
        mod_type = pkg_sv_sdr::get_modulation_settings(tr_mod).mod_type;

        copy_item();

        if (sdr_seqi_tx.tr_mod == OQPSK) begin
            oqpsk_re = new[2 * sdr_seqi_tx.data_sym.size];
            oqpsk_im = new[2 * sdr_seqi_tx.data_sym.size];
            oqpsk_first = new[2 * sdr_seqi_tx.data_sym.size];
            oqpsk_last = new[2 * sdr_seqi_tx.data_sym.size];

            for (int ii = 0; ii < sdr_seqi_tx.data_sym.size; ii++) begin
                oqpsk_re[2 * ii] = 2 * sdr_seqi_tx.data_re[ii];
                oqpsk_re[2 * ii + 1] = 0; //sdr_seqi_tx.data_re[ii];

                oqpsk_im[2 * ii] = 0; //sdr_seqi_tx.data_re[ii];
                oqpsk_im[2 * ii + 1] = 2 * sdr_seqi_tx.data_im[ii];

                oqpsk_first[2 * ii + 0] = sdr_seqi_tx.first[ii];
                oqpsk_first[2 * ii + 1] = sdr_seqi_tx.first[ii];
                oqpsk_last[2 * ii + 0] = sdr_seqi_tx.last[ii];
                oqpsk_last[2 * ii + 1] = sdr_seqi_tx.last[ii];
            end

            sdr_seqi_tx.data_re = oqpsk_re;
            sdr_seqi_tx.data_im = oqpsk_im;
            sdr_seqi_tx.first = oqpsk_first;
            sdr_seqi_tx.last = oqpsk_last;
            sdr_seqi_tx.tr_sym_f = sdr_seqi_tx.tr_sym_f * 2;
        end

        if (mod_type == 1) begin
            if (tr_fsk_dev <= 1.0)
                fsk_sps = 4;
            else
                fsk_sps = 16;
            sdr_seqi_tx.tr_sym_f = sdr_seqi_tx.tr_sym_f * fsk_sps;
        end

        if (sdr_seqi_tx.tr_mod == FSK2 || sdr_seqi_tx.tr_mod == FSK4) begin
            fskmod_init_angles(sdr_seqi_tx);
            fskmod(sdr_seqi_tx);
        end

        if (sdr_seqi_tx.tr_mod == GFSK2 || sdr_seqi_tx.tr_mod == GFSK4) begin
            fskmod_init_angles(sdr_seqi_tx);
            gauss_filt(tr_fsk_bt);
            fskmod(sdr_seqi_tx);
        end

        start_item(sdr_seqi_tx);
            `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_tx.convert2string_mux(3)), UVM_HIGH);
        finish_item(sdr_seqi_tx);

        sdr_seqr_h.item_done();                                                 // item_done
    end
endtask

function automatic void sdr_seqc_spmod::fskmod_init_angles(sdr_seqi sdr_seqi_h);
    real pi = pkg_sv_sdr_math::c_pi;
    real fsk_step = 0;
    int iq_length;

    iq_length = sdr_seqi_h.data_sym.size();
    this.fsk_angle = new[iq_length * fsk_sps];

    if (sdr_seqi_h.tr_idle == 0) begin
        for (int ii = 0; ii < iq_length; ii++) begin
            if (this.symsz == 1) begin
                //        |     |
                //        |     |
                // _______|__|__|_______
                //        0     1
                case (sdr_seqi_h.data_sym[ii])
                    0 : fsk_step = (- pi) / fsk_sps;
                    1 : fsk_step = (  pi) / fsk_sps;
                endcase
            end

            if (this.symsz == 2) begin
                //   |    |     |    |
                //   |    |     |    |
                // __|____|__|__|____|__
                //   0    1     2    3
                case (sdr_seqi_h.data_sym[ii])
                    0 : fsk_step = (- 3 * pi) / fsk_sps;
                    1 : fsk_step = (-     pi) / fsk_sps;
                    2 : fsk_step = (      pi) / fsk_sps;
                    3 : fsk_step = (  3 * pi) / fsk_sps;
                endcase
            end

            for (int jj = 0; jj < fsk_sps; jj++) begin
                if (sdr_seqi_h.user_mark[ii] != 255) begin
                    fsk_phase += fsk_step * sdr_seqi_h.tr_fsk_dev;
                    this.fsk_angle[fsk_sps * ii + jj] = fsk_phase;
                end
            end
        end
    end

    // $display("FSK ANGLES: %p", this.fsk_angle);
endfunction

function automatic void sdr_seqc_spmod::gauss_filt(real bt);
    // new SPS = new coefficients
    if (fsk_sps_prev != fsk_sps) begin
        filt_h.set_coefficients(bt, 4.0, fsk_sps);
        fsk_sps_prev = fsk_sps;
    end

    filt_h.filt(fsk_angle);

    // $display("FSK ANGLES: %p", this.fsk_angle);
endfunction

function automatic void sdr_seqc_spmod::fskmod(ref sdr_seqi sdr_seqi_h);
    int iq_length;
    int shift = 3;

    iq_length = sdr_seqi_h.data_sym.size();
    fsk_keep = new[iq_length * fsk_sps];
    fsk_re = new[iq_length * fsk_sps];
    fsk_im = new[iq_length * fsk_sps];
    fsk_user_mark = new[iq_length * fsk_sps];

    if (sdr_seqi_h.tr_idle == 0) begin
        for (int ii = 0; ii < iq_length; ii++) begin
            for (int jj = 0; jj < fsk_sps; jj++) begin
                if (jj == 0 || jj == fsk_sps / 2)
                    // symbols and half symbols
                    fsk_user_mark[fsk_sps * ii + jj + shift] = 1;
                if (jj == 0)
                    // symbols
                    fsk_keep[fsk_sps * ii + jj + shift] = 1;

                if (sdr_seqi_h.user_mark[ii] == 255) begin
                    fsk_re[fsk_sps * ii + jj] = 0;
                    fsk_im[fsk_sps * ii + jj] = 0;
                end else begin
                    fsk_re[fsk_sps * ii + jj]  = 512 * $cos(this.fsk_angle[fsk_sps * ii + jj]);
                    fsk_im[fsk_sps * ii + jj]  = 512 * $sin(this.fsk_angle[fsk_sps * ii + jj]);
                end
            end
        end
    end

    sdr_seqi_h.keep = fsk_keep;
    sdr_seqi_h.data_re = fsk_re;
    sdr_seqi_h.data_im = fsk_im;
    sdr_seqi_h.user_mark = fsk_user_mark;
endfunction