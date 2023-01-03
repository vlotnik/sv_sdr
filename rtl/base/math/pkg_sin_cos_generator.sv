//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_sin_cos_generator
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_sin_cos_generator;

    const int LATENCY = 2;
    const real PI = 3.1415926535897932384626433832795;

    function int f_sin(int phase, int max = 2**15 - 1, int phase_w = 12);
        real phase_r;
        real sin_r;
        real sin_i;
        real sin_floor;
        int sin_int;

        phase_r = $itor(phase) * 2.0 * PI / $itor(2**phase_w);
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

        phase_r = $itor(phase) * 2.0 * PI / $itor(2**phase_w);
        cos_r = $cos(phase_r);
        cos_i = cos_r * $itor(max);
        cos_floor = $floor(cos_i + 0.5);
        cos_int = $rtoi(cos_floor);

        return cos_int;
    endfunction

//--------------------------------------------------------------------------------------------------------------------------------
endpackage