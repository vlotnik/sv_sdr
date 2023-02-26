//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_resampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_resampler extends uvm_object;
    `uvm_object_utils(sdr_resampler);
    `uvm_object_new

    protected int filter_length;
    protected int num_of_phases;
    protected real coefficients[][];
    protected real ratio;
    protected real ratio_accumulator;

    protected int ring_buffer_hard[];
    protected int ring_buffer_re[];
    protected int ring_buffer_im[];
    protected bit ring_buffer_first[];
    protected bit ring_buffer_last[];
    protected int write_pointer;
    protected int read_pointer;
    protected real ram_addr;
    protected int next_sample;

    int result_re[$];
    int result_im[$];
    bit result_first[$];
    bit result_last[$];

    extern function void reset();
    extern function void set_coefficients(real coefficients[], int filter_length, int num_of_phases);
    extern function void set_resampler_ratio(real i_frequency, real o_frequency);
    extern function int add_ratio();
    extern function automatic void resample(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_resampler::reset();
    this.ring_buffer_hard = new[filter_length * 2];
    this.ring_buffer_re = new[filter_length];
    this.ring_buffer_im = new[filter_length];
    this.ring_buffer_first = new[filter_length];
    this.ring_buffer_last = new[filter_length];

    this.ratio_accumulator = - 0.5;
endfunction

function void sdr_resampler::set_coefficients(real coefficients[], int filter_length, int num_of_phases);
    this.filter_length = filter_length;
    this.num_of_phases = num_of_phases;
    this.coefficients = new[num_of_phases];
    for (int i = 0; i < num_of_phases; i++) begin
        this.coefficients[i] = new[filter_length];
        for (int j = 0; j < filter_length; j++) begin
            this.coefficients[i][j] = coefficients[num_of_phases * j + i];
        end
    end

    reset();
endfunction

function void sdr_resampler::set_resampler_ratio(real i_frequency, real o_frequency);
    this.ratio = i_frequency / o_frequency;
    // this.ratio_accumulator = - 0.5;
    // $display("i_frequency: %f, o_frequency: %f", i_frequency, o_frequency);
endfunction

function int sdr_resampler::add_ratio();
    real eps;

    eps = $sqrt($pow(2, -52));
    if ((ratio_accumulator) < (0.5 - eps)) begin
        ratio_accumulator += ratio;
        if (ratio_accumulator > (0.5 - eps)) begin
            ratio_accumulator = ratio_accumulator - 1.0;
            return 1; // next sample
        end else begin
            return 0;
        end
    end else begin
        ratio_accumulator = ratio_accumulator - 1.0;
        return 1; // next sample
    end
endfunction

function automatic void sdr_resampler::resample(ref sdr_seqi sdr_seqi_h);
    real accum_re;
    real accum_im;
    bit accum_first;
    bit accum_last;
    int input_length;
    int data_pointer;

    set_resampler_ratio(sdr_seqi_h.tr_sym_f, sdr_seqi_h.tr_rsmp_f);
    sdr_seqi_h.tr_sym_f = sdr_seqi_h.tr_rsmp_f;
    input_length = sdr_seqi_h.data_re.size();
    // $display("size before resample: %d", sdr_seqi_h.data_re.size());
    // $display("SOF AFTER: %p", sdr_seqi_h.iq.i);

    result_re.delete();
    result_im.delete();
    result_first.delete();
    result_last.delete();

    while (data_pointer < input_length) begin
        // write data to buffer
        ring_buffer_re[write_pointer] = sdr_seqi_h.data_re[data_pointer];
        ring_buffer_im[write_pointer] = sdr_seqi_h.data_im[data_pointer];
        ring_buffer_first[write_pointer] = sdr_seqi_h.first[data_pointer];
        ring_buffer_last[write_pointer] = sdr_seqi_h.last[data_pointer];
        // $display("SOF: %p", ring_buffer_first);
        // `uvm_info(get_name(), $sformatf("iq_ptr: %d, wr_ptr: %d", data_pointer, write_pointer), UVM_HIGH);

        // $display("ratioAccum %1.20f, Phase number: %d, write_pointer: %d, IQsoftPtr: %d", ratio_accumulator, next_sample, write_pointer, data_pointer);
        accum_re = 0.0;
        accum_im = 0.0;

        ram_addr = ratio_accumulator + 0.5 + sdr_seqi_h.tr_rsmp_ps;
        // $display(ram_addr);

        for (int k = 0; k < filter_length; k++) begin
            // filter product
            accum_re += coefficients[$rtoi(ram_addr * 4096)][k] * ring_buffer_re[read_pointer];
            accum_im += coefficients[$rtoi(ram_addr * 4096)][k] * ring_buffer_im[read_pointer];
            if (k == filter_length / 2) accum_first = ring_buffer_first[read_pointer];
            if (k == filter_length / 2) accum_last = ring_buffer_last[read_pointer];
            // $display("k = %2d, coef = %f", k, coefficients[$rtoi((ratio_accumulator + 0.5) * 4096)][k]);
            // read pointer
            if (read_pointer < 1)
                read_pointer = filter_length - 1;
            else
                read_pointer--;

            // `uvm_info(get_name(), $sformatf("iq_ptr: %d, wr_ptr: %d, rd_ptr: %d", data_pointer, write_pointer, read_pointer), UVM_HIGH);
        // debug
        //$display("%1.15f", coefficients[$rtoi((ratioAccum + 0.5) * 4096)][k]);
        //$display("read pointer: %d, write pointer %d, iterator %d , I %d, Q %d, I accum %f, Coef %1.10f"
        //        ,read_pointer, write_pointer, k, ring_buffer_re[read_pointer], ring_buffer_im[read_pointer], accum_re, coefficients[$rtoi((ratioAccum + 0.5) * 4096)][k]);
        end

        next_sample = add_ratio();

        if (next_sample == 1) begin
            data_pointer++;
            if (write_pointer < (filter_length - 1))
                write_pointer++;
            else
                write_pointer = 0;
        end
        read_pointer = write_pointer;

        result_re.push_back($rtoi(accum_re * 4096));
        result_im.push_back($rtoi(accum_im * 4096));
        result_first.push_back(accum_first);
        result_last.push_back(accum_last);
        // $display("SOF AFTER: %p", result_first);
    end

    if (result_re.size() == 2 * sdr_seqi_h.data_re.size()) begin
        // $display("2x sym");
        sdr_seqi_h.keep = new[2 * sdr_seqi_h.data_re.size()];
        // mark symbols
        for (int ii = 0; ii < sdr_seqi_h.data_re.size(); ii++)
            sdr_seqi_h.keep[2 * ii + 1] = 1;
    end

    sdr_seqi_h.data_re = result_re;
    sdr_seqi_h.data_im = result_im;
    sdr_seqi_h.first = result_first;
    sdr_seqi_h.last = result_last;

    sdr_seqi_h.valid = new[sdr_seqi_h.data_re.size()];
    for (int ii = 0; ii < sdr_seqi_h.data_re.size(); ii++) begin
        sdr_seqi_h.valid[ii] = new[1];
        sdr_seqi_h.valid[ii][0] = 1;
    end
    // $display("SOF AFTER: %p", sdr_seqi_h.iq.i);
    // $display("SOF AFTER: %p", sdr_seqi_h.first);
    // $display("size after resample: %d", sdr_seqi_h.data_re.size());
endfunction