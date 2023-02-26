//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_fir_filter
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_fir_filter extends uvm_object;
    `uvm_object_utils(sdr_fir_filter)
    `uvm_object_new

    protected int filter_length;
    protected real coefficients[];

    protected int ring_buffer_re[];
    protected int ring_buffer_im[];
    protected int write_pointer;
    protected int read_pointer;

    int result_re[$];
    int result_im[$];

    // functions
    extern function void set_coefficients(real coefficients[]);
    extern function automatic void filt(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_fir_filter::set_coefficients(real coefficients[]);
    this.filter_length = coefficients.size();
    this.coefficients = coefficients;

    this.ring_buffer_re = new[this.filter_length];
    this.ring_buffer_im = new[this.filter_length];
endfunction

function automatic void sdr_fir_filter::filt(ref sdr_seqi sdr_seqi_h);
    int input_data_size;
    int data_pointer;
    real accum_re;
    real accum_im;

    input_data_size = sdr_seqi_h.data_re.size();
    result_re.delete();
    result_im.delete();

    while (data_pointer < input_data_size) begin
        // write data to buffer
        ring_buffer_re[write_pointer] = sdr_seqi_h.data_re[data_pointer];
        ring_buffer_im[write_pointer] = sdr_seqi_h.data_im[data_pointer];

        accum_re = 0;
        accum_im = 0;

        for (int k = 0; k < filter_length; k++) begin
            // filter product
            accum_re += coefficients[k] * ring_buffer_re[read_pointer];
            accum_im += coefficients[k] * ring_buffer_im[read_pointer];

            // read pointer
            if (read_pointer < 1)
                read_pointer = filter_length - 1;
            else
                read_pointer--;
        end

        if (write_pointer < (filter_length - 1))
            write_pointer++;
        else
            write_pointer = 0;

        read_pointer = write_pointer;

        result_re.push_back($rtoi(accum_re));
        result_im.push_back($rtoi(accum_im));

        data_pointer++;
    end

    sdr_seqi_h.data_re = result_re;
    sdr_seqi_h.data_im = result_im;
endfunction