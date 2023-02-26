//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_mixer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_mixer extends uvm_object;
    `uvm_object_utils(sdr_mixer)
    `uvm_object_new

    protected real mix_step;
    protected real mix_accum;
    protected real phase;
    protected int result_re[];
    protected int result_im[];

    extern function void reset();
    extern function void set_mix_freq(real mix_freq, real samp_freq);
    extern function automatic void mix(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_mixer::reset();
    this.mix_accum = 0.0;
endfunction

function void sdr_mixer::set_mix_freq(real mix_freq, real samp_freq);
    this.mix_step = mix_freq / samp_freq;
endfunction

function automatic void sdr_mixer::mix(ref sdr_seqi sdr_seqi_h);
    real pi;
    int iq_length;

    pi = pkg_sv_sdr_math::c_pi;

    set_mix_freq(sdr_seqi_h.tr_car_f, sdr_seqi_h.tr_sym_f);
    iq_length = sdr_seqi_h.data_re.size();
    result_re = new[iq_length];
    result_im = new[iq_length];

    for (int i = 0; i < iq_length; i++) begin
        phase = 2 * pi * mix_accum + pi * sdr_seqi_h.tr_car_ps;
        result_re[i]  = sdr_seqi_h.data_re[i] * $cos(phase) - sdr_seqi_h.data_im[i] * $sin(phase);
        result_im[i]  = sdr_seqi_h.data_re[i] * $sin(phase) + sdr_seqi_h.data_im[i] * $cos(phase);
        mix_accum += mix_step;
    end

    sdr_seqi_h.data_re = result_re;
    sdr_seqi_h.data_im = result_im;
endfunction