//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_sv_sdr_math
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_sv_sdr_math;

    import pkg_sv_sdr_types::*;

    const real c_pi = 3.1415926535897932384626433832795;

    function int f_sin(int phase, int max = 2**15 - 1, int phase_w = 12);
        real phase_r;
        real sin_r;
        real sin_i;
        real sin_floor;
        int sin_int;

        phase_r = $itor(phase) * 2.0 * c_pi / $itor(2**phase_w);
        sin_r = $sin(phase_r);
        sin_i = sin_r * $itor(max);
        sin_floor = $floor(sin_i + 0.5);
        sin_int = $rtoi(sin_floor);

        return sin_int;
    endfunction

    function int f_cos(int phase, int max = 2**15-1, int phase_w = 12);
        real phase_r;
        real cos_r;
        real cos_i;
        real cos_floor;
        int cos_int;

        phase_r = $itor(phase) * 2.0 * c_pi / $itor(2**phase_w);
        cos_r = $cos(phase_r);
        cos_i = cos_r * $itor(max);
        cos_floor = $floor(cos_i + 0.5);
        cos_int = $rtoi(cos_floor);

        return cos_int;
    endfunction

    function t_iq f_complex_mult(t_iq a, t_iq b, bit conj_mult);
        t_iq c;

        if (conj_mult == 0) begin
            c.i = a.i * b.i - a.q * b.q;
            c.q = a.q * b.i + a.i * b.q;
        end else begin
            c.i = a.i * b.i + a.q * b.q;
            c.q = a.q * b.i - a.i * b.q;
        end

        return c;
    endfunction

    function int f_divide_and_round(int data, int lsb);
        real result_real;
        real result_floor;
        int result_int;

        result_real = $itor(data) / $itor(2**lsb);
        if (data >= 0)
            result_floor = $floor(result_real + 0.5);
        else
            result_floor = $ceil(result_real - 0.5);
        result_int = $rtoi(result_floor);

        return result_int;
    endfunction

    function int f_abs(int i, int q);
        real result_r;
        int result;

        result_r = $hypot($signed(q), $signed(i));
        result = $rtoi(result_r);

        return result;
    endfunction

    function int f_ang(int i, int q, int max = (2 ** 15 - 1));
        real result_r;
        real result_floor;
        int result;

        result_r = $atan2($signed(q), $signed(i)) / c_pi * max;
        // result_floor = $floor(result_r + 0.5);
        result_floor = $floor(result_r);
        result = $rtoi(result_floor);

        return result;
    endfunction

    function real f_distance(real i1, real q1, real i2, real q2, bit show_log = 0);
        real result;

        result = $sqrt($pow(i1 - i2, 2) + $pow(q1 - q2, 2));
        if (show_log == 1)
            $display("x = (%3.2f + i %3.2f), y = (%3.2f + i %3.2f), d = %3.2f", i1, q1, i2, q2, result);

        return result;
    endfunction

    function int f_get_nco_frequency(real mix_f, real sys_f);
        int result;

        result = $rtoi(mix_f * $pow(2, 32) / sys_f);

        return result;
    endfunction

    function real f_abs_real(real x);
        real result;

        result = x < 0 ? -1.0 * x : x;

        return result;
    endfunction
//-------------------------------------------------------------------------------------------------------------------------------
endpackage