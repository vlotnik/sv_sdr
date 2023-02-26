//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_gauss_filter
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_gauss_filter extends uvm_object;
    `uvm_object_utils(sdr_gauss_filter);
    `uvm_object_new

    protected int filter_length;
    protected real h[];

    extern function void set_coefficients(real bt, real span = 3, int sps = 2);
    extern function void filt(ref t_real_array);

    protected real ring_buffer[];
    protected int write_pointer;
    protected int read_pointer;

    real result[$];
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_gauss_filter::set_coefficients(real bt, real span = 3, int sps = 2);
    real t[];
    real pi = pkg_sv_sdr_math::c_pi;
    real alpha;
    real summ = 0;

    this.filter_length = span * sps + 1;
    alpha = $sqrt($ln(2) / 2) / bt;
    t = new[filter_length];
    h = new[filter_length];

    for (int ii = 0; ii < filter_length; ii++) begin
        t[ii] = -span/2 + ii * (span / $itor(filter_length - 1));
        h[ii] = ($sqrt(pi) / alpha) * $exp(-$pow((t[ii] * pi / alpha), 2));
        summ += h[ii];
    end

    for (int ii = 0; ii < filter_length; ii++) begin
        h[ii] /= summ;
    end

    this.ring_buffer = new[this.filter_length];

    $display("GAUSS FILTER:");
    $display("bt = %0.2f, span = %0.2f, sps = %3d", bt, span, sps);
    $display("coefs = %p", h);
endfunction

function void sdr_gauss_filter::filt(ref t_real_array data);
    int input_length;
    int ptr;
    real accum;

    input_length = data.size();
    result.delete();

    while (ptr < input_length) begin
        // write data to buffer
        ring_buffer[write_pointer] = data[ptr];

        accum = 0;

        for (int k = 0; k < filter_length; k++) begin
            // filter product
            accum += h[k] * ring_buffer[read_pointer];

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

        result.push_back(accum);

        ptr++;
    end

    data = result;
endfunction