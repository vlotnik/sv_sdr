//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_awgn
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_awgn extends uvm_object;
    `uvm_object_utils(sdr_awgn)
    `uvm_object_new

    extern function real get_linear_snr(real snr);
    extern function real get_signal_avg_power(t_iq_int_array iq, int user_mark[]);
    extern function real get_noise_sigma(real signal_avg_power, real linear_snr);
    extern function void add_awgn(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function real sdr_awgn::get_linear_snr(real snr);
    real linear_snr;

    linear_snr = $pow(10, snr / 10);
    `uvm_info(get_name(), $sformatf("SNR, dB: %2.2f", snr), UVM_FULL);
    `uvm_info(get_name(), $sformatf("SNR, linear: %2.5f", linear_snr), UVM_FULL);

    return linear_snr;
endfunction

function real sdr_awgn::get_signal_avg_power(t_iq_int_array iq, int user_mark[]);
    real signal_avg_power;
    real iq_abs;
    real cnt;

    cnt = 0;
    foreach(iq.i[i]) begin
        if (user_mark[i] == 0) begin
        // only data is used to calculate power, no preambles, no pilots
            iq_abs = $sqrt($pow(iq.i[i], 2) + $pow(iq.q[i],2));
            signal_avg_power += $pow(iq_abs, 2);
            cnt++;
        end
    end
    signal_avg_power /= cnt;
    `uvm_info(get_name(), $sformatf("signal power: %2.2f", signal_avg_power), UVM_HIGH);

    return signal_avg_power;
endfunction

function real sdr_awgn::get_noise_sigma(real signal_avg_power, real linear_snr);
    real noise_spectral_density;
    real noise_sigma;

    noise_spectral_density = signal_avg_power / linear_snr;
    noise_sigma = $sqrt(noise_spectral_density / 2);
    `uvm_info(get_name(), $sformatf("noise sigma: %2.2f", noise_sigma), UVM_FULL);

    return noise_sigma;
endfunction

function void sdr_awgn::add_awgn(ref sdr_seqi sdr_seqi_h);
    real linear_snr;
    real signal_avg_power;
    real noise_sigma;
    int data_sz;
    int result_re[];
    int result_im[];
    real noise_re;
    real noise_im;

    linear_snr = get_linear_snr(sdr_seqi_h.tr_snr);
    signal_avg_power = $itor(sdr_seqi_h.tr_power);
    noise_sigma = get_noise_sigma(signal_avg_power, linear_snr);

    data_sz = sdr_seqi_h.data_re.size();
    result_re = new[data_sz];
    result_im = new[data_sz];

    if (sdr_seqi_h.tr_mod == OQPSK)
        noise_sigma *= $sqrt(2);

    for (int i = 0; i < data_sz; i++) begin
        noise_re = noise_sigma * $itor($dist_normal($urandom, 0, 2**24)) / 2.0**24;
        noise_im = noise_sigma * $itor($dist_normal($urandom, 0, 2**24)) / 2.0**24;
        result_re[i] = $rtoi($floor(noise_re + 0.5));
        result_im[i] = $rtoi($floor(noise_im + 0.5));
    end

    for (int i = 0; i < data_sz; i++) begin
        sdr_seqi_h.data_re[i] = sdr_seqi_h.data_re[i] + result_re[i];
        sdr_seqi_h.data_im[i] = sdr_seqi_h.data_im[i] + result_im[i];
    end
endfunction