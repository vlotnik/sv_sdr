//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqi
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqi extends uvm_sequence_item;
    `uvm_object_utils(sdr_seqi);

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
    int                                 tr_pldsz = 0;
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
    real                                tr_sys_f = 1.0;
    real                                tr_rsmp_f = 2.0;
    real                                tr_rsmp_ps = 0.0;
    real                                tr_car_f = 0.0;
    real                                tr_car_ps = 0.0;
    int                                 tr_time = 0;

    extern function void new_seqi(int size);
    extern function void do_copy(uvm_object rhs);

    extern function void write_sym2file(integer fid);
    extern function void write_to_file(integer fid, bit reverse = 0);

    extern function string convert2string();
    extern function string convert2string_mux(int dmps = 0);
    extern function string convert2string_full();
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_seqi::new_seqi(int size);
    tr_frsz                             = size;
    valid                               = new[size];
    first                               = new[size];
    last                                = new[size];
    keep                                = new[size];
    data_sym                            = new[size];
    data_re                             = new[size];
    data_im                             = new[size];
    data_scr                            = new[size];
    user_mark                           = new[size];
    user_mod                            = new[size];
    id                                  = new[size];
endfunction

function void sdr_seqi::write_sym2file(integer fid);
    byte sym_byte;

    foreach(data_sym[i]) begin
        sym_byte = data_sym[i];
        $fwrite(fid, "%c", sym_byte);
    end
endfunction

function void sdr_seqi::write_to_file(integer fid, bit reverse = 0);
    // each symbol will be stored as 64-bit data:
    //  _______________________________________________
    // |byte0|byte1|byte2|byte3|byte4|byte5|byte6|byte7|
    // |___________I___________|___________Q___________|

    byte ibytes_wr[4];
    byte qbytes_wr[4];
    byte bytes_wr[4];

    foreach(data_re[i]) begin
        if (reverse == 1) begin
            ibytes_wr = {<<8{data_re[i]}};
            qbytes_wr = {<<8{data_im[i]}};
            bytes_wr = {ibytes_wr[0], ibytes_wr[1], qbytes_wr[0], qbytes_wr[1]};
        end else begin
            ibytes_wr = {<<{data_re[i]}};
            qbytes_wr = {<<{data_im[i]}};
            bytes_wr = {ibytes_wr[0], ibytes_wr[1], qbytes_wr[0], qbytes_wr[1]};
        end

        foreach(bytes_wr[k]) begin
            $fwrite(fid, "%c", bytes_wr[k]);
        end
    end
endfunction

function void sdr_seqi::do_copy(uvm_object rhs);
    sdr_seqi                        that;

    if (! $cast(that, rhs)) begin
        `uvm_fatal(get_name(), "Type cast error");
    end

    super.do_copy(rhs);
    this.valid                          = that.valid;
    this.first                          = that.first;
    this.last                           = that.last;
    this.keep                           = that.keep;
    this.data_bit                       = that.data_bit;
    this.data_sym                       = that.data_sym;
    this.data_re                        = that.data_re;
    this.data_im                        = that.data_im;
    this.data_scr                       = that.data_scr;
    this.user_mark                      = that.user_mark;
    this.user_mod                       = that.user_mod;
    this.id                             = that.id;
    this.tr_id                          = that.tr_id;
    this.tr_reset                       = that.tr_reset;
    this.tr_idle                        = that.tr_idle;
    this.tr_last                        = that.tr_last;
    this.tr_modcod                      = that.tr_modcod;
    this.tr_modcod_n                    = that.tr_modcod_n;
    this.tr_pldsz                       = that.tr_pldsz;
    this.tr_nofs                        = that.tr_nofs;
    this.tr_frsz                        = that.tr_frsz;
    this.tr_pause_sz                    = that.tr_pause_sz;
    this.tr_mod                         = that.tr_mod;
    this.tr_scale                       = that.tr_scale;
    this.tr_fsk_dev                     = that.tr_fsk_dev;
    this.tr_fsk_bt                      = that.tr_fsk_bt;
    this.tr_gain                        = that.tr_gain;
    this.tr_power                       = that.tr_power;
    this.tr_snr                         = that.tr_snr;
    this.tr_sym_f                       = that.tr_sym_f;
    this.tr_rsmp_f                      = that.tr_rsmp_f;
    this.tr_sys_f                       = that.tr_sys_f;
    this.tr_car_f                       = that.tr_car_f;
    this.tr_car_ps                      = that.tr_car_ps;
    this.tr_time                        = that.tr_time;
endfunction

function string sdr_seqi::convert2string();
    string result;

    result = "";
    if (tr_idle == 1)
        result = {result, $sformatf("idle = %b", tr_idle)};
    if (tr_last == 1)
        result = {result, $sformatf(", last = %b", tr_last)};
    result = {result, $sformatf(", time = %0d", tr_time)};
    result = {result, $sformatf(", id = %0d", tr_id)};
    if (tr_modcod_n == tr_modcod)
        result = {result, $sformatf(", modcod = %0d", tr_modcod)};
    else
        result = {result, $sformatf(", modcod = %0d -> %0d", tr_modcod, tr_modcod_n)};
    result = {result, $sformatf(", payload = %0d bit", tr_pldsz)};
    result = {result, $sformatf(", modulation = %0s", tr_mod)};
    result = {result, $sformatf(", scale = %0.3f", tr_scale)};
    if (tr_mod == FSK2 || tr_mod == FSK4)
        result = {result, $sformatf(", deviation = %0.2f", tr_fsk_dev)};
    if (tr_mod == GFSK2 || tr_mod == GFSK4) begin
        result = {result, $sformatf(", deviation = %0.2f", tr_fsk_dev)};
        result = {result, $sformatf(", bt = %0.2f", tr_fsk_bt)};
    end
    result = {result, $sformatf(", number of slots = %0d", tr_nofs)};
    result = {result, $sformatf(", frame size = %0d", tr_frsz)};
    result = {result, $sformatf(", frame power = %0d", tr_power)};
    result = {result, $sformatf(", SNR = %0.2f dB", tr_snr)};
    result = {result, $sformatf(", sys freq = %0.6f", tr_sys_f)};
    result = {result, $sformatf(", sym freq = %0.6f", tr_sym_f)};
    result = {result, $sformatf(", car freq = %0.6f", tr_car_f)};

    return result;
endfunction

function string sdr_seqi::convert2string_mux(int dmps = 0);
    string result;

    result = convert2string();
    case (dmps)
        0 : result = {result, $sformatf("\nvalid = %p", valid)};
        1 : result = {result, $sformatf("\nfirst = %p", first)};
        2 : result = {result, $sformatf("\nlast = %p", last)};
        3 : result = {result, $sformatf("\nkeep = %p", keep)};
        4 : result = {result, $sformatf("\ndata_bit = %p", data_bit)};
        5 : result = {result, $sformatf("\ndata_sym = %p", data_sym)};
        6 : result = {result, $sformatf("\ndata_re = %p", data_re)};
        7 : result = {result, $sformatf("\ndata_im = %p", data_im)};
        8 : result = {result, $sformatf("\ndata_scr = %p", data_scr)};
        9 : result = {result, $sformatf("\nuser_mark = %p", user_mark)};
        10 : result = {result, $sformatf("\nuser_mod = %p", user_mod)};
        11 : result = {result, $sformatf("\nid = %p", id)};
        default : result = {result, $sformatf("\data_bit = %p", data_bit)};
    endcase

    return result;
endfunction

function string sdr_seqi::convert2string_full();
    string result;

    result = convert2string();
    result = {result, $sformatf("\nvalid = %p", valid)};
    result = {result, $sformatf("\nfirst = %p", first)};
    result = {result, $sformatf("\nlast = %p", last)};
    result = {result, $sformatf("\nkeep = %p", keep)};
    result = {result, $sformatf("\ndata_bit = %p", data_bit)};
    result = {result, $sformatf("\ndata_sym = %p", data_sym)};
    result = {result, $sformatf("\ndata_re = %p", data_re)};
    result = {result, $sformatf("\ndata_im = %p", data_im)};
    result = {result, $sformatf("\ndata_scr = %p", data_scr)};
    result = {result, $sformatf("\nuser_mark = %p", user_mark)};
    result = {result, $sformatf("\nuser_mod = %p", user_mod)};
    result = {result, $sformatf("\nid = %p", id)};

    return result;
endfunction