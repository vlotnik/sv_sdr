//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_base_seqc
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_base_seqc extends uvm_sequence #(sdr_seqi);
    `uvm_object_utils(sdr_base_seqc)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    extern function void copy_item();

    // transactions
    sdr_seqi                            sdr_seqi_rx;
    sdr_seqi                            sdr_seqi_tx;

    // sequencer
    sdr_seqr                            sdr_seqr_h;

    // analysis ports
    sdr_aprt                            sdr_aprt_rx;
    sdr_aprt                            sdr_aprt_tx;

    bit random_data = 1;

    // data
    int                                 valid[][];
    bit                                 first[];
    bit                                 last[];
    bit                                 keep[];
    bit                                 data_bit[];
    int                                 data_sym[];
    int                                 data_re[];
    int                                 data_im[];
    bit[1:0]                            data_scr[];
    int                                 user_mark[];
    t_modulation                        user_mod[];
    int                                 id[];

    // settings
    int                                 tr_id = 0;
    bit                                 tr_reset = 0;
    bit                                 tr_idle = 0;
    bit                                 tr_last = 0;
    int                                 tr_modcod = 0;
    int                                 tr_modcod_n = 0;
    int                                 tr_pldsz = 1024;
    int                                 tr_nofs = 0;
    int                                 tr_frsz = 0;
    int                                 tr_pause_sz = 0;
    t_modulation                        tr_mod = BPSK;
    real                                tr_scale = 724.0;
    real                                tr_fsk_dev = 1.0;
    real                                tr_fsk_bt = 1.0;
    real                                tr_gain = 1.0;
    int                                 tr_power = 0;
    real                                tr_snr = 200;
    real                                tr_sym_f = 1.0;
    real                                tr_sys_f = 4.0;
    real                                tr_rsmp_f = 2.0;
    real                                tr_rsmp_ps = 0.0;
    real                                tr_car_f = 0.0;
    real                                tr_car_ps = 0.0;
    int                                 tr_time = 0;

    // others
    int sym_ptr = 0;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_base_seqc::pre_body();
    `uvm_object_create(sdr_seqi, sdr_seqi_rx)
endtask

task sdr_base_seqc::body();
    if (random_data == 1) begin
        data_bit = new[tr_pldsz];
        foreach (data_bit[ii]) begin
            data_bit[ii] = $urandom_range(0, 1);
        end
    end

    sdr_seqi_rx.valid                   = valid;
    sdr_seqi_rx.first                   = first;
    sdr_seqi_rx.last                    = last;
    sdr_seqi_rx.keep                    = keep;
    sdr_seqi_rx.data_bit                = data_bit;
    sdr_seqi_rx.data_sym                = data_sym;
    sdr_seqi_rx.data_re                 = data_re;
    sdr_seqi_rx.data_im                 = data_im;
    sdr_seqi_rx.data_scr                = data_scr;
    sdr_seqi_rx.user_mark               = user_mark;
    sdr_seqi_rx.user_mod                = user_mod;
    sdr_seqi_rx.id                      = id;

    sdr_seqi_rx.tr_id                   = tr_id;
    sdr_seqi_rx.tr_reset                = tr_reset;
    sdr_seqi_rx.tr_idle                 = tr_idle;
    sdr_seqi_rx.tr_last                 = tr_last;
    sdr_seqi_rx.tr_modcod               = tr_modcod;
    sdr_seqi_rx.tr_modcod_n             = tr_modcod_n;
    sdr_seqi_rx.tr_pldsz                = tr_pldsz;
    sdr_seqi_rx.tr_nofs                 = tr_nofs;
    sdr_seqi_rx.tr_frsz                 = tr_frsz;
    sdr_seqi_rx.tr_pause_sz             = tr_pause_sz;
    sdr_seqi_rx.tr_mod                  = tr_mod;
    sdr_seqi_rx.tr_scale                = tr_scale;
    sdr_seqi_rx.tr_fsk_bt               = tr_fsk_bt;
    sdr_seqi_rx.tr_fsk_dev              = tr_fsk_dev;
    sdr_seqi_rx.tr_gain                 = tr_gain;
    sdr_seqi_rx.tr_snr                  = tr_snr;
    sdr_seqi_rx.tr_sym_f                = tr_sym_f;
    sdr_seqi_rx.tr_sys_f                = tr_sys_f;
    sdr_seqi_rx.tr_rsmp_f               = tr_rsmp_f;
    sdr_seqi_rx.tr_rsmp_ps              = tr_rsmp_ps;
    sdr_seqi_rx.tr_car_f                = tr_car_f;
    sdr_seqi_rx.tr_car_ps               = tr_car_ps;
    sdr_seqi_rx.tr_time                 = tr_time;

    start_item(sdr_seqi_rx);
        `uvm_info(get_name(), $sformatf("\npong sequence with %s", sdr_seqi_rx.convert2string()), UVM_HIGH);
    finish_item(sdr_seqi_rx);
endtask

function void sdr_base_seqc::copy_item();
    `uvm_object_create(sdr_seqi, sdr_seqi_tx)
    sdr_seqi_tx.copy(sdr_seqi_rx);
endfunction