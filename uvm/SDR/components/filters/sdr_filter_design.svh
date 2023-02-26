//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_filter_design
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_filter_design;
    // funcitons
    extern function t_real_array rcosdesign(real rolloff, real cutoff, int order);
    extern function t_real_array rcosdesign_sqrt(real rolloff, real cutoff, int order);
    extern function real sinc_v(real x);
    extern function t_real_array firls_v(real cutoff, int order);
    extern function t_real_array gaussdesign(real bt, real span = 3, int sps = 2);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function t_real_array sdr_filter_design::rcosdesign(real rolloff, real cutoff, int order);
    real pi;
    real epsilon;
    real t[];
    real b[];
    real fs;
    real fc;
    real x;

    pi = pkg_sv_sdr_math::c_pi;
    epsilon = $pow (2, -52);
    t = new[order];
    b = new[order];
    fs = 2.0;
    fc = cutoff * fs;

    // check rolloff, cutoff
    if ((rolloff <= 0) && (rolloff > 1.0))
        $write("rolloff factor must be in the [0, 1) range");
    if ((cutoff <= 0) && (cutoff >= 1.0))
        $write("cutoff factor must be in the [0, 1] range");

    for (int i = 0; i < order ; i++) begin
        t[i] = ((-(order - 1.0) / 2.0) + i) / fs;
    end

    for (int i = 0; i < order; i++) begin
        if((f_abs_real(f_abs_real(4.0 * rolloff * fc * t[i]) - 1.0)) > $sqrt(epsilon)) begin
            x = 2.0 * pi * fc * t[i];
            b[i] = ($sin(x) / x) / fs * $cos(x * rolloff) / (1.0 - $pow((2 * x * rolloff / pi), 2.0));
        end
        else begin
            b[i] = rolloff / (2 * fs) * $sin(pi / (2 * rolloff));
        end
        b[i] = 2 * fc * b[i];
    end

    return b;
endfunction

function t_real_array sdr_filter_design::rcosdesign_sqrt(real rolloff, real cutoff, int order);
    real pi;
    real epsilon;
    real t[];
    real b[];
    real fs;
    real fc;
    real x;

    pi = pkg_sv_sdr_math::c_pi;
    epsilon = $pow (2, -52);
    t = new[order];
    b = new[order];
    fs = 2.0;
    fc = cutoff * fs;

    // check rolloff, cutoff
    if ((rolloff <= 0) && (rolloff > 1.0))
        $write("rolloff factor must be in the [0, 1) range");
    if ((cutoff <= 0) && (cutoff >= 1.0))
        $write("cutoff factor must be in the [0, 1] range");

    for (int i = 0; i < order ; i++) begin
        t[i] = ((-(order - 1.0) / 2.0) + i) / fs;
    end

    for (int i = 0; i < order; i++) begin
        b[i] = - 4 * rolloff / fs * (
            $cos((1 + rolloff) * 2 * pi * fc * t[i]) +
            $sin((1 - rolloff) * 2 * pi * fc * t[i]) / (8 * rolloff * fc * t[i])
            ) / (pi * $sqrt(1 / (2 * fc)) * ($pow((8 * rolloff * fc * t[i]), 2) - 1));
        b[i] = $sqrt(2 * fc) * b[i];
    end

    return b;
endfunction

function real sdr_filter_design::sinc_v(real x);
    real pi = pkg_sv_sdr_math::c_pi;
    if (x == 0)
        return 1.0;
    else begin
        return $sin(pi * x) / (pi * x);
    end
endfunction

function t_real_array sdr_filter_design::firls_v(real cutoff, int order);
    real pass_band = 0.6 * cutoff;
    real stop_band = 1.2 * cutoff;
    real f[4];
    int num_el = order / 2;

    real b[];
    real k[];
    real bs[];
    real a[];
    real h[];

    real i1[][];
    real i2[][];
    real g[][];
    real l[][];

    real sm = 0.0;
    f[0] = 0.0;
    f[1] = pass_band;
    f[2] = stop_band;
    f[3] = 0.5;

    b = new[num_el];
    k = new[num_el];
    bs = new[num_el];
    a = new[num_el];
    h = new[order];
    i1 = new[num_el];
    i2 = new[num_el];
    g = new[num_el];
    l = new[num_el];

    for (int i = 0; i < num_el; i++) begin
        i1[i] = new[num_el];
        i2[i] = new[num_el];
        g[i] = new[num_el];
        l[i] = new[num_el];
    end

    for (int i = 0; i < num_el; i++)
        k[i] = 0.5 + $itor(i);

    for (int i = 0; i < num_el; i++)
        b[i] = f[1] * sinc_v(2 * k[i] * f[1]);

    for (int i = 0; i < num_el; i++)
        for (int j = 0; j < num_el; j++) begin
            i1[i][j] = i + j + 1;
            i2[i][j] = i - j;
        end

    for (int s = 0; s < 3; s += 2)
        for (int i = 0; i < num_el; i++)
            for (int j = 0; j < num_el; j++)
                g[i][j] = g[i][j] + 0.5 * (
                    f[s + 1] * (
                        sinc_v(2 * i1[i][j] * f[s + 1]) +
                        sinc_v(2 * i2[i][j] * f[s + 1])
                    ) -
                    f[s] * (
                        sinc_v(2 * i1[i][j] * f[s]) +
                        sinc_v(2 * i2[i][j] * f[s])
                    )
                );

    // Cholesky factorization
    for (int i = 0; i < num_el; i++)
        for (int j = 0; j <= i; j++) begin
            sm = 0;
            for (int k = 0; k < j; k++)
                sm += l[i][k] * l[j][k];
            if (i == j) begin
                l[i][j] = $sqrt(g[i][i] - sm);
            end else begin
                l[i][j] = (g[i][j] - sm) / l[j][j];
            end
        end

    // Backward Substitution
    for (int i = 0; i < num_el; i++) begin
        sm = 0;
        for (int j = 0; j < i; j++)
            sm += l[i][j] * bs[j];
        bs[i] = (b[i] - sm) / l[i][i];
    end

    for (int i = num_el - 1; i >= 0; i--) begin
        sm = 0;
        for (int j = num_el - 1; j > i; j--) sm += l[j][i] * a[j];
        a[i] = (bs[i] - sm) / l[i][i];
    end

    for (int i = 0; i < num_el; i++) h[i] = 0.5 * a[num_el - i - 1];

    for (int i = 0; i < num_el; i++) h[i + num_el] = 0.5 * a[i];

    $display("=============================================");
    $display("calculate FIRLS filter");
    $display("cutoff:               %8.4f", cutoff);
    $display("pass_band:            %8.4f", pass_band);
    $display("stop_band:            %8.4f", stop_band);
    // $display("k: %p:", k);
    // $display("b: %p:", b);
    // $display("i1: %p:", i1);
    // $display("i2: %p:", i2);
    // $display("g: %p:", g);
    // $display("l: %p:", l);
    $display("h: %p:", h);
    $display("=============================================");
    $display("\n");

    return h;
endfunction

function t_real_array sdr_filter_design::gaussdesign(real bt, real span = 3, int sps = 2);
    real h[];
    real t[];
    real pi = pkg_sv_sdr_math::c_pi;
    real alpha;
    real summ = 0;
    int filter_length = 0;

    filter_length = span * sps + 1;
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

    return h;
endfunction