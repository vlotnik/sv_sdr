//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_base_mapper
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_base_mapper extends uvm_object;
    `uvm_object_utils(sdr_base_mapper)
    `uvm_object_new

    virtual function void init_plane(t_modulation mod);
    endfunction

    extern function int real_to_int(real data, real scale = 724.0);
    extern function void init_solver(t_modulation mod, real iq_scale = 724.0);
    extern function int get_plane_power(t_modulation mod, real iq_scale = 724.0);
    extern function void get_iq(ref sdr_seqi sdr_seqi_h);
    extern function void get_iq_by_symbol(input int symbol, output int i, output int q);
    extern function void get_iq_hard_fix_mod_v0(int m, ref sdr_seqi sdr_seqi_h);
    extern function void get_iq_hard_fix_mod_v1(int m, ref sdr_seqi sdr_seqi_h);
    extern function void plot_plane(t_modulation modulation, int fid);
    extern function void init_plane_arrays(t_modulation modulation, real iq_scale = 724.0);

    // settings
    int tr_frsz = 0;
    real tr_scale = 724.0;
    t_modulation tr_mod = BPSK;

    real plane[];
    t_modulation current_mod;
    localparam int solver_size = 1024;
    // scale for 12 bit
    localparam int solver_scale = 2 * (1024 / solver_size);
    int solver[*];
    int solver_dump[];

    real plane_r[];
    int plane_r_scale;

    // plane arrays
    bit[31:0] plane_solver[];
    bit[31:0] arr_plane_iq[];
    bit[31:0] arr_plane_a[];
    int arr_plane_addr_a[];
    int arr_plane_addr_i[];
    int arr_plane_addr_q[];
    bit arr_plane_addr_h[];
    bit arr_plane_addr_e[];
    bit plane_p_nr;
    int plane_gainer;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function int sdr_base_mapper::real_to_int(real data, real scale = 724.0);
    int result = 0;

    result = $rtoi($floor((scale * data) + 0.5));

    return result;
endfunction

function void sdr_base_mapper::init_solver(t_modulation mod, real iq_scale = 724.0);
    bit show_log;
    int fid_plane;
    string plane_name;
    int cnt_i;
    int cnt_q;
    int cnt_iq;
    real test_i;
    real test_q;
    int is[];
    int qs[];
    real dists[];
    real min_dist;
    int min_dist_id;
    // int addr;
    bit[19:0] addr;
    int pb_cnt;

    pb_cnt = 0;
    show_log = 0;

    plane_name = pkg_sv_sdr::get_modulation_settings(mod).name;
    $display("BUILD PLANE %s", plane_name);

    is = new[plane.size/2];
    qs = new[plane.size/2];
    dists = new[plane.size/2];
    // get arrays of ideal i/q
    for (int i = 0; i < plane.size/2; i++) begin
        is[i] = iq_scale * (plane[2 * i + 0]);
        qs[i] = iq_scale * (plane[2 * i + 1]);
    end

    // solver_dump = new[1024 * 1024];
    cnt_iq = 0;

    for (cnt_q = -512; cnt_q < 512; cnt_q++) begin
        for (cnt_i = -512; cnt_i < 512; cnt_i++) begin
            // get all distances between real and ideal points
            for (int j = 0; j < plane.size/2; j++) begin
                dists[j] = f_distance(
                      $itor(is[j])
                    , $itor(qs[j])
                    , $itor(cnt_i) * 4
                    , $itor(cnt_q) * 4
                    , show_log
                );
            end

            // find minimal distance between real and ideal points
            min_dist = dists[0];
            min_dist_id = 0;
            for (int j = 1; j < plane.size/2; j++) begin
                if (dists[j] < min_dist) begin
                    min_dist = dists[j];
                    min_dist_id = j;
                end
            end

            // addr = (cnt_q << 12) + cnt_i;
            addr = (cnt_q << 10) + cnt_i;
            // $display("addr: %b", addr);
            solver[addr] = min_dist_id;

            // solver_dump[cnt_iq] = min_dist_id;
            cnt_iq++;
            // $display("current Q: %d/%d; current I: %d/%d",
            //     cnt_q, solver_size - 1,
            //     cnt_i, solver_size - 1);
        end

        if (pb_cnt == solver_size / 100) begin
            pb_cnt = 0;
            $display("building plane: %5d/%5d values", cnt_iq, 1024 * 1024);
        end else begin
            pb_cnt++;
        end
    end

    // fid_plane = $fopen({"make_plane_", plane_name, ".user_mark"}, "wb");
    // $fwrite(fid_plane, "plane_%s = [", plane_name);
    //     for (int ii = 0; ii < solver_dump.size(); ii++) begin
    //         $fwrite(fid_plane, "%0d", solver_dump[ii]);
    //         if (ii != solver_dump.size() - 1) begin
    //             $fwrite(fid_plane, ", ");
    //         end
    //         if ((ii > 0) && (ii % 100 == 0))
    //             $fwrite(fid_plane, "... \n");
    //     end
    //     $fwrite(fid_plane, "];\n");
    //     // $fwrite(fid_plane, "plane_sq = reshape(plane_%s, [4096, 4096]);\n", plane_name);
    //     $fwrite(fid_plane, "plane_sq = reshape(plane_%s, [1024, 1024]);\n", plane_name);
    //     $fwrite(fid_plane, "plane_sq = rot90(plane_sq);\n");
    // $fclose(fid_plane);
endfunction

function int sdr_base_mapper::get_plane_power(t_modulation mod, real iq_scale = 724.0);
    int iq_abs;
    int cnt;
    real signal_avg_power_real;
    int signal_avg_power;
    int mod_type;

    cnt = 0;
    signal_avg_power = 0;
    mod_type = pkg_sv_sdr::get_modulation_settings(mod).mod_type;

    init_plane(mod);
    if (mod_type == 1)
        init_plane(QPSK);

    // OOK crunch
    if (mod_type == 2)
        init_plane(BPSK);

    for (int i = 0; i < plane.size / 2; i++) begin
        // i = plane[2 * i];
        // q = plane[2 * i + 1];
        iq_abs = $pow(plane[2 * i], 2) + $pow(plane[2 * i + 1], 2);
        signal_avg_power_real += $itor(iq_abs);
        cnt++;
    end
    signal_avg_power_real /= cnt;
    signal_avg_power_real *= $pow(iq_scale, 2);
    signal_avg_power = $rtoi(signal_avg_power_real);

    `uvm_info(get_name(),
        $sformatf("plane with %0s modulation has power %0d",
        pkg_sv_sdr::get_modulation_settings(mod).name, signal_avg_power), UVM_FULL);
    return signal_avg_power;
endfunction

function void sdr_base_mapper::get_iq(ref sdr_seqi sdr_seqi_h);
    // get settings from transaction
    tr_scale = sdr_seqi_h.tr_scale;
    tr_frsz = sdr_seqi_h.data_sym.size;
    tr_mod = sdr_seqi_h.tr_mod;

    // create arrays for I/Q
    sdr_seqi_h.data_re = new[tr_frsz];
    sdr_seqi_h.data_im = new[tr_frsz];

    if (sdr_seqi_h.tr_idle == 1) begin
        // make idle transaction
        for (int i = 0; i < sdr_seqi_h.data_sym.size(); i++) begin
            sdr_seqi_h.data_re[i] = 0;
            sdr_seqi_h.data_im[i] = 0;
        end
    end else begin
        // map data to plane
        for (int i = 0; i < sdr_seqi_h.data_sym.size(); i++) begin
            if (i == 0) begin
                init_plane(sdr_seqi_h.tr_mod);
                current_mod = sdr_seqi_h.tr_mod;
                `uvm_info(get_name(),
                    $sformatf("plane inited with %0s modulation",
                    pkg_sv_sdr::get_modulation_settings(current_mod).name), UVM_HIGH);
            end
            if (sdr_seqi_h.user_mark[i] == 0) begin
                sdr_seqi_h.data_re[i] = real_to_int(tr_scale, plane[2 * sdr_seqi_h.data_sym[i] + 0]);
                sdr_seqi_h.data_im[i] = real_to_int(tr_scale, plane[2 * sdr_seqi_h.data_sym[i] + 1]);
            end
        end

        // map preamble/pilots to plane
        for (int i = 0; i < sdr_seqi_h.data_sym.size(); i++) begin
            if (sdr_seqi_h.user_mark[i] != 0) begin
                if (sdr_seqi_h.user_mark[i] == 255) begin
                    // idle data
                    sdr_seqi_h.data_re[i] = 0;
                    sdr_seqi_h.data_im[i] = 0;
                end else begin
                    // change plane if necessary
                    if (sdr_seqi_h.user_mod[i] != current_mod) begin
                        init_plane(sdr_seqi_h.user_mod[i]);
                        current_mod = sdr_seqi_h.user_mod[i];
                        `uvm_info(get_name(),
                            $sformatf("plane inited with %0s modulation",
                            pkg_sv_sdr::get_modulation_settings(current_mod).name), UVM_FULL);
                    end
                    sdr_seqi_h.data_re[i] = real_to_int(tr_scale, plane[2 * sdr_seqi_h.data_sym[i] + 0]);
                    sdr_seqi_h.data_im[i] = real_to_int(tr_scale, plane[2 * sdr_seqi_h.data_sym[i] + 1]);
                end
            end
        end
    end
endfunction

function void sdr_base_mapper::get_iq_by_symbol(input int symbol, output int i, output int q);
    real current_scale = 724.0;
    i = real_to_int(current_scale, plane[2 * symbol + 0]);
    q = real_to_int(current_scale, plane[2 * symbol + 1]);
endfunction

function void sdr_base_mapper::get_iq_hard_fix_mod_v0(int m, ref sdr_seqi sdr_seqi_h);
    bit show_log;
    int is[];
    int qs[];
    real dists[];
    real min_dist;
    int min_dist_id;

    show_log = 0;

    is = new[plane.size/2];
    qs = new[plane.size/2];
    dists = new[plane.size/2];
    // get arrays of ideal i/q
    for (int i = 0; i < plane.size/2; i++) begin
        is[i] = sdr_seqi_h.tr_scale * (plane[2 * i + 0]);
        qs[i] = sdr_seqi_h.tr_scale * (plane[2 * i + 1]);
    end

    for (int i = 0; i < sdr_seqi_h.data_re.size(); i++) begin
        if (sdr_seqi_h.user_mark[i] == m) begin
            // get all distances between real and ideal points
            for (int j = 0; j < plane.size/2; j++) begin
                dists[j] = f_distance(
                      $itor(is[j])
                    , $itor(qs[j])
                    , $itor(sdr_seqi_h.data_re[i])
                    , $itor(sdr_seqi_h.data_im[i])
                    , show_log
                );
            end

            // find minimal distance between real and ideal points
            min_dist = dists[0];
            min_dist_id = 0;
            for (int j = 1; j < plane.size/2; j++) begin
                if (dists[j] < min_dist) begin
                    min_dist = dists[j];
                    min_dist_id = j;
                end
            end

            sdr_seqi_h.data_sym[i] = min_dist_id;
        end
    end
endfunction

function void sdr_base_mapper::get_iq_hard_fix_mod_v1(int m, ref sdr_seqi sdr_seqi_h);
    // int test_i, test_q
    int array_size;
    int test_hard;
    bit[19:0] addr;
    bit[11:0] test_i;
    bit[11:0] test_q;
    // $display("%p", solver);

    array_size = sdr_seqi_h.data_re.size();

    sdr_seqi_h.data_sym = new[array_size];

    for (int i = 0; i < array_size; i++) begin
        if (sdr_seqi_h.user_mark[i] == m) begin
            test_i = sdr_seqi_h.data_re[i];
            test_q = sdr_seqi_h.data_im[i];
            addr = (test_q[11:2] << 10) + test_i[11:2];
            // $display("addr: %b", addr);

            test_hard = solver[addr];
            sdr_seqi_h.data_sym[i] = test_hard;
            // $display("src: %6d + 1j * %6d, hard = %6d || new: %6d + 1j * %6d || address = %6d, hard = %6d",
            //     sdr_seqi_h.data_re[i], sdr_seqi_h.data_im[i], sdr_seqi_h.data_sym[i], test_i, test_q, address, test_hard);
        end
    end
endfunction

function void sdr_base_mapper::init_plane_arrays(t_modulation modulation, real iq_scale = 724.0);
    bit show_log;
    // plane settings
    string plane_name;
    bit p_nr;
    int gainer = 1;
    int size;
    real scale;

    // ideal data
    int nof_stars;
    int is[];
    int qs[];
    int as[];
    bit[31:0] all_iqs[];
    bit[31:0] all_as[];
    bit[31:0] unique_as[];
    int iqs_index_array[*];
    int as_index_array[*];
    // distances
    real dist_btw_stars;
    real min_dist_btw_stars;
    real zero_dist;
    int zero_dist_int;
    // nearest star
    real test_i_r;
    real test_q_r;
    real min_dist;
    real cur_dist;
    int min_index;
    int ptr;

    real pi;
    real phase_r;
    real sin_r;
    real cos_r;

    bit min_hit, min_err;
    bit[31:0] min_i;
    bit[31:0] min_q;
    bit[31:0] min_a;

    real scale_by_size;

    show_log = 0;
    pi = pkg_sv_sdr_math::c_pi;

    // get plane settings from pkg_sv_sdr
    plane_name = pkg_sv_sdr::get_modulation_settings(modulation).name;
    p_nr = pkg_sv_sdr::get_modulation_settings(modulation).p_nr;
    size = pkg_sv_sdr::get_modulation_settings(modulation).plane_size;
    gainer = pkg_sv_sdr::get_modulation_settings(modulation).gainer;

    $display("-------------------------");
    $display("sdr_base_mapper : got settings");
    $display("-------------------------");
    $display("plane_name = %0s", plane_name);
    $display("p_nr = %0b", p_nr);
    $display("size = %0d", size);
    $display("gainer = %0d", gainer);
    $display("-------------------------");

    size = size / 2;
    scale = iq_scale * 0.0625;

    size = 2 ** size;
    plane_solver = new[size * size + 1];
    scale_by_size = 128 / $itor(size);

    init_plane(modulation);
    nof_stars = p_nr == 0 ? plane.size/8 : plane.size/2;

    is = new[nof_stars];
    qs = new[nof_stars];
    as = new[nof_stars];
    all_iqs = new[nof_stars * 2];
    all_as = new[nof_stars];

    for (int i = 0; i < nof_stars; i++) begin
        is[i] = real_to_int(scale, plane[2 * i + 0]);
        qs[i] = real_to_int(scale, plane[2 * i + 1]);

        if (is[i] >= qs[i]) begin
            as[i] = f_ang(is[i], qs[i], 2048);
        end else begin
            as[i] = f_ang(qs[i], is[i], 2048);
            as[i] = 1024 - as[i];
        end

        is[i] = is[i] / gainer;
        qs[i] = qs[i] / gainer;

        all_iqs[2 * i]     = is[i];
        all_iqs[2 * i + 1] = qs[i];
        all_as[i] = as[i];
    end

    unique_as = all_as.unique();

    arr_plane_a = null;
    arr_plane_iq = all_iqs.unique();

    $display("unique angles : %p", unique_as);
    $display("unique IQs    : %p", arr_plane_iq);
    $display("\n");
    $display("as : %p", as);
    $display("is : %p", is);
    $display("qs : %p", qs);

    if (p_nr == 1)
        arr_plane_a = unique_as;
    else begin
        for (int ii = 0; ii < unique_as.size(); ii++) begin
            if (unique_as[ii] <= 512)
                arr_plane_a = {arr_plane_a, unique_as[ii]};
        end
    end
    // arr_plane_a = p_nr == 0 ? all_as.unique() with (item >= 512) : all_as.unique();
    arr_plane_addr_a = new[size * size];
    arr_plane_addr_i = new[size * size];
    arr_plane_addr_q = new[size * size];
    arr_plane_addr_h = new[size * size];
    arr_plane_addr_e = new[size * size];

    foreach (arr_plane_iq[ii])
        iqs_index_array[arr_plane_iq[ii]] = ii;
    foreach (arr_plane_a[ii])
        as_index_array[arr_plane_a[ii]] = ii;

    // find minimum distance between two stars
    min_dist_btw_stars = f_distance($itor(is[0]), $itor(qs[0]), $itor(is[1]), $itor(qs[1]));
    for (int i = 0; i < nof_stars; i++) begin
        for (int j = 0; j < nof_stars; j++) begin
            if (i != j) begin
                dist_btw_stars = f_distance($itor(is[i]), $itor(qs[i]), $itor(is[j]), $itor(qs[j]));
                if (dist_btw_stars < min_dist_btw_stars)
                    min_dist_btw_stars = dist_btw_stars;
            end
        end
    end
    zero_dist = min_dist_btw_stars * 0.3;
    zero_dist_int = $rtoi(zero_dist);
    if (zero_dist_int == 0)
        zero_dist_int = 1;
    $display("min distance for hit zone: %0d", zero_dist_int);

    for (int y = 0; y < size; y++) begin
        for (int x = 0; x < size; x++) begin
            if (p_nr == 0) begin
                test_i_r = $itor(x) * scale_by_size + 0.01;
                test_q_r = $itor(y) * scale_by_size + 0.01;
            end else begin
                // calculate sin/cos
                phase_r = $itor(x) * 2.0 * pi / size + 0.001;
                cos_r = $cos(phase_r);
                sin_r = $sin(phase_r);
                // calculate i/q
                test_i_r = $itor(y) * cos_r * scale_by_size;
                test_q_r = $itor(y) * sin_r * scale_by_size;
            end
            // set minimum value to first ideal point
            min_dist = f_distance($itor(is[0]), $itor(qs[0]), test_i_r, test_q_r, show_log);
            min_index = 0;
            cur_dist = min_dist;
            // check other ideal points
            for (int j = 1; j < is.size; j++) begin
                cur_dist = f_distance($itor(is[j]), $itor(qs[j]), test_i_r, test_q_r, show_log);
                if (cur_dist < min_dist) begin
                    min_dist = cur_dist;
                    min_index = j;
                end
            end

            ptr = y * size + x;
            // $display("CURRENT POINT : I = %5d, Q = %5d; IDEAL POINT : I = %5d, Q = %5d; distance = %f", x, y, is[min_index], qs[min_index], min_dist);
            if (min_dist <= zero_dist_int) begin
                min_hit = 1;
                if (is[min_index] == qs[min_index])
                    min_err = 1;
                else
                    min_err = 0;
            end else begin
                min_hit = 0;
                min_err = 0;
            end
            // make 32-bit word for plane
            plane_solver[ptr][11:0] = as[min_index];
            plane_solver[ptr][19:12] = is[min_index];
            plane_solver[ptr][27:20] = qs[min_index];
            plane_solver[ptr][28] = min_hit;
            plane_solver[ptr][29] = p_nr == 0 ? min_err : min_hit;
            // make 32-bit word
            if (p_nr == 0)
                min_a = as[min_index] <= 512 ? as[min_index] : 1024 - as[min_index];
            else
                min_a = as[min_index];
            min_i = is[min_index];
            min_q = qs[min_index];

            arr_plane_addr_a[ptr] = as_index_array[min_a];
            arr_plane_addr_i[ptr] = iqs_index_array[min_i];
            arr_plane_addr_q[ptr] = iqs_index_array[min_q];
            arr_plane_addr_h[ptr] = min_hit;
            arr_plane_addr_e[ptr] = p_nr == 0 ? min_err : min_hit;
        end
    end

    // last word, 0/1 - rectangle/polar plane
    plane_solver[size * size][0] = p_nr;
    plane_solver[size * size][2:1] = gainer - 1;
    plane_p_nr = p_nr;
    plane_gainer = gainer - 1;
endfunction

function void sdr_base_mapper::plot_plane(t_modulation modulation, int fid);
    byte bytes_wr [4];

    init_plane_arrays(modulation);

    // write plane to file
    for (int ii = 0; ii < plane_solver.size(); ii++) begin
        bytes_wr = {<<8{plane_solver[ii]}};
        foreach(bytes_wr[k]) begin
            $fwrite(fid, "%c", bytes_wr[k]);
        end
    end
endfunction