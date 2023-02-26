//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_scrb_rxtx
//--------------------------------------------------------------------------------------------------------------------------------
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_rx_first)
`uvm_analysis_imp_decl(_tx)

class sdr_scrb_rxtx extends sdr_base_scrb;
    `uvm_component_utils(sdr_scrb_rxtx)
    `uvm_component_new

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    uvm_active_passive_enum snr_curve = UVM_PASSIVE;

    int check_frame_size = 1;
    // 0 - do not check
    // 1 - sizes must be equal
    // 2 - actual size can be greater or equal
    int check_number_of_slots = 0;
    // 0 - do not check
    // 1 - nofs must be equal
    int check_modcod = 0;
    // 0 - do not check
    // 1 - modcod must be equal
    int check_time = 0;
    // 0 - do not check
    // 1 - time must be equal

    t_modulation unique_modulation[];

    uvm_analysis_imp_rx #(sdr_seqi, sdr_scrb_rxtx) aprt_rx;
    uvm_analysis_imp_rx_first #(sdr_seqi, sdr_scrb_rxtx) aprt_rx_first;
    uvm_analysis_imp_tx #(sdr_seqi, sdr_scrb_rxtx) aprt_tx;

    sdr_seqi                            sdr_seqi_queue_i[$];
    int queue_i_ptr = 0;
    sdr_seqi                            sdr_seqi_queue_o[$];

    static sdr_mapper                   sdr_mapper_h[];
    sdr_mapper                          d_solver_h;
    sdr_mapper                          p_solver_h;

    t_modulation modulation;
    t_modulation snr_mod;
    string snr_mod_name;
    real snr_prev;
    real snr_queue[$];
    int cnt;
    // string path_output;
    int pack_n;
    int sym_error_cnt_r;
    real sym_error_rate_r;
    real sym_error_queue_r[$];
    real sym_error_rate;
    real sym_error_queue[$];
    int fid_i;
    int fid_o;
    int fid_ser;
    int snr_sym_cnt;
    int snr_sym_err;

    string path_output = "";
    // int fid_i, fid_o;

    extern function void build_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    extern virtual function void write_rx_first(sdr_seqi sdr_seqi_h);
    extern virtual function void write_rx(sdr_seqi sdr_seqi_h);
    extern virtual function void write_tx(sdr_seqi sdr_seqi_h);

    extern function void processing();
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_scrb_rxtx::build_phase(uvm_phase phase);
    // build solvers for scoreboard
    if (is_active == UVM_ACTIVE) begin
        if (sdr_mapper_h.size == 0) begin
            `uvm_info("SOLVER", $sformatf("Scoreboard has %p unique modulations", unique_modulation), UVM_HIGH)

            sdr_mapper_h = new[unique_modulation.size()];
            foreach (sdr_mapper_h[ii]) begin
                `uvm_info("SOLVER", $sformatf("Build solver for %0s modulation", unique_modulation[ii]), UVM_HIGH)
                sdr_mapper_h[ii] = sdr_mapper::type_id::create($sformatf("sdr_mapper_h_%2d", ii));
                sdr_mapper_h[ii].init_plane(unique_modulation[ii]);
                sdr_mapper_h[ii].init_solver(unique_modulation[ii]);
            end
        end
    end

    this.test_name = test_name;

    aprt_rx = new("aprt_rx", this);
    aprt_rx_first = new("aprt_rx_first", this);
    aprt_tx = new("aprt_tx", this);
endfunction

function void sdr_scrb_rxtx::write_rx_first(sdr_seqi sdr_seqi_h);
    // replace transaction time with data got from monitor
    if (sdr_seqi_queue_i.size > queue_i_ptr) begin
        sdr_seqi_queue_i[queue_i_ptr].tr_time = sdr_seqi_h.tr_time;
        queue_i_ptr++;
    end
endfunction

function void sdr_scrb_rxtx::write_rx(sdr_seqi sdr_seqi_h);
    if (sdr_seqi_h.tr_idle == 0)
        sdr_seqi_queue_i.push_back(sdr_seqi_h);
endfunction

function void sdr_scrb_rxtx::write_tx(sdr_seqi sdr_seqi_h);
    sdr_seqi_queue_o.push_back(sdr_seqi_h);
    // if (is_active == UVM_ACTIVE) begin
        processing();
    // end
endfunction

function void sdr_scrb_rxtx::processing();
    sdr_seqi                        sdr_seqi_h_i;
    sdr_seqi                        sdr_seqi_h_o;
    bit good_modcod;
    bit good_size;
    bit good_nofs;
    bit good_time;
    int sym_cnt;
    int sym_error_cnt;
    int mark_error_cnt;
    real sym_error_r;
    string fails_str = "";

    // reset counters
    sym_cnt = 0;
    sym_error_cnt = 0;
    mark_error_cnt = 0;

    if (sdr_seqi_queue_i.size == 0) begin
        `uvm_error("FAIL", "no input data\n");
        if (data_good == 1)
            fail_cnt++;
    end else begin
        // get ideal data
        sdr_seqi_h_i = sdr_seqi_queue_i.pop_front();
        if (queue_i_ptr > 0)
            queue_i_ptr--;

        modulation = sdr_seqi_h_i.tr_mod;

        if (is_active == UVM_ACTIVE) begin
            foreach(unique_modulation[i]) begin
                if (modulation == unique_modulation[i]) begin
                    `uvm_info("DATA HANDLER", $sformatf("%0d will be used for %s modulation", i, unique_modulation[i]), UVM_MEDIUM);
                    d_solver_h = sdr_mapper_h[i];
                end
            end
            // be sure that scoreboard has plane for pilots
            `uvm_info("DATA HANDLER", $sformatf("%0d will be used for %s pilots", 0, unique_modulation[0]), UVM_MEDIUM);
            p_solver_h = sdr_mapper_h[0];
        end

        sdr_seqi_h_o = sdr_seqi_queue_o.pop_front();
        sdr_seqi_h_o.tr_mod = modulation;
        sdr_seqi_h_o.data_sym = new[sdr_seqi_h_o.data_re.size()];

        if (is_active == UVM_ACTIVE) begin
            d_solver_h.get_iq_hard_fix_mod_v1(0, sdr_seqi_h_o);
            p_solver_h.get_iq_hard_fix_mod_v1(1, sdr_seqi_h_o);
        end

        case (check_frame_size)
            0 : good_size = 1;
            2 : good_size = sdr_seqi_h_i.tr_frsz <= sdr_seqi_h_o.tr_frsz ? 1'b1 : 1'b0;
            default : good_size = sdr_seqi_h_i.tr_frsz == sdr_seqi_h_o.tr_frsz ? 1'b1 : 1'b0;
        endcase

        case (check_number_of_slots)
            0 : good_nofs = 1;
            default : good_nofs = sdr_seqi_h_i.tr_nofs == sdr_seqi_h_o.tr_nofs ? 1'b1 : 1'b0;
        endcase

        case (check_time)
            0 : good_time = 1;
            default :
                // time in range [-1 ... +1]
                if (sdr_seqi_h_o.tr_time >= sdr_seqi_h_i.tr_time - 1 &&
                    sdr_seqi_h_o.tr_time <= sdr_seqi_h_i.tr_time + 1)
                    good_time = 1'b1;
                else
                    good_time = 1'b0;
        endcase

        case (check_modcod)
            0 : good_modcod = 1;
            default :
                good_modcod = sdr_seqi_h_i.tr_modcod == sdr_seqi_h_o.tr_modcod ? 1'b1 : 1'b0;
        endcase

        // if (good_size == 1'b1) begin
            for (int ii = 0; ii < sdr_seqi_h_i.tr_frsz; ii++) begin
                if (sdr_seqi_h_i.user_mark[ii] == 0) begin
                    sym_cnt++;
                    if (sdr_seqi_h_i.data_sym[ii] != sdr_seqi_h_o.data_sym[ii])
                        sym_error_cnt++;
                end
                if (sdr_seqi_h_i.user_mark[ii] != sdr_seqi_h_o.user_mark[ii])
                    mark_error_cnt++;
            end
        // end

        sym_error_r = $itor(sym_error_cnt) / sym_cnt;

        if (good_size == 0)
            fails_str = {fails_str, "\n\tWRONG frame size"};
        if (good_modcod == 0)
            fails_str = {fails_str, "\n\tWRONG modcod"};
        if (good_nofs == 0)
            fails_str = {fails_str, "\n\tWRONG number of slots"};
        if (good_time == 0)
            fails_str = {fails_str, "\n\tWRONG time"};
        if (mark_error_cnt > 0)
            fails_str = {fails_str, "\n\tWRONG marks"};

        if (good_size == 0 || good_modcod == 0 || good_nofs == 0 || good_time == 0 || mark_error_cnt > 0) begin
            `uvm_error("FAIL", $sformatf("%s", fails_str));
            if (mark_error_cnt > 0) begin
                `uvm_info("SCRB", $sformatf("\nPING... sequence with %s",   sdr_seqi_h_i.convert2string_mux(9)), UVM_NONE);
                `uvm_info("SCRB", $sformatf("\n...PONG sequence with %s\n", sdr_seqi_h_o.convert2string_mux(9)), UVM_NONE);
            end else begin
                `uvm_info("SCRB", $sformatf("\nPING... sequence with %s",   sdr_seqi_h_i.convert2string()), UVM_NONE);
                `uvm_info("SCRB", $sformatf("\n...PONG sequence with %s\n", sdr_seqi_h_o.convert2string()), UVM_NONE);
            end
            if (data_good == 1)
                fail_cnt++;
        end else begin
            if (data_good == 0) data_good = 1;

            if (is_active == UVM_ACTIVE) begin
                `uvm_info("PASS", $sformatf("SER: %2.2e", sym_error_r), UVM_MEDIUM);
            end else
                `uvm_info("PASS", "", UVM_MEDIUM);
            `uvm_info("SCRB", $sformatf("\nPING... sequence with %s",   sdr_seqi_h_i.convert2string()), UVM_NONE);
            `uvm_info("SCRB", $sformatf("\n...PONG sequence with %s\n", sdr_seqi_h_o.convert2string()), UVM_NONE);
        end


        if (snr_curve == UVM_ACTIVE) begin
            if (snr_queue.size == 0) begin
                snr_prev = sdr_seqi_h_i.tr_snr;
                snr_mod = sdr_seqi_h_i.tr_mod;
                snr_queue.push_back(snr_prev);
                pack_n = 0;
                cnt = 12;
            end else if (sdr_seqi_h_i.tr_snr != snr_prev) begin
                sym_error_rate = $itor(snr_sym_err) / (snr_sym_cnt);
                $display("snr = %2.2f", snr_prev);
                $display("err = %2.2e \n", sym_error_rate);
                snr_prev = sdr_seqi_h_i.tr_snr;
                snr_queue.push_back(snr_prev);
                sym_error_queue.push_back(sym_error_rate);
                snr_sym_cnt = 0;
                snr_sym_err = 0;
                pack_n = 0;
                cnt--;
            end

            snr_sym_cnt += sym_cnt;
            snr_sym_err += sym_error_cnt;
            pack_n++;

            `uvm_info("SCORE:", $sformatf("\nrecieved: %5d/%5d transactions with SNR = %2.2f dB, current SER = %5d/%5d = %2.2e",
                pack_n,
                10 * $pow(2, cnt),
                snr_prev,
                snr_sym_err, snr_sym_cnt,
                $itor(snr_sym_err) / (snr_sym_cnt)),
            UVM_NONE);
        end
    end
endfunction

function void sdr_scrb_rxtx::report_phase(uvm_phase phase);
    super.report_phase(phase);

    if (snr_curve == UVM_ACTIVE) begin
        snr_mod_name = pkg_sv_sdr::get_modulation_settings(snr_mod).name;
        fid_ser = $fopen({"ser_", snr_mod_name, ".user_mark"}, "wb");

        $fwrite(fid_ser, "snrs_%s = [", snr_mod_name);
        for (int ii = 0; ii < snr_queue.size(); ii++) begin
            $fwrite(fid_ser, "%2.2f", snr_queue[ii]);
            if (ii != snr_queue.size() - 1) begin
                $fwrite(fid_ser, ", ");
            end
        end
        $fwrite(fid_ser, "];\n");

        $fwrite(fid_ser, "sers_%s = [", snr_mod_name);
        for (int ii = 0; ii < sym_error_queue.size(); ii++) begin
            $write("%2.2e", sym_error_queue[ii]);
            $fwrite(fid_ser, "%2.2e", sym_error_queue[ii]);
            if (ii != sym_error_queue.size() - 1) begin
                $write(", ");
                $fwrite(fid_ser, ", ");
            end
        end
        $fwrite(fid_ser, "];\n");

        $fwrite(fid_ser, "semilogy(snrs_%s(1:length(sers_%s)), sers_%s, 'LineWidth', 2);\n",
            snr_mod_name, snr_mod_name, snr_mod_name);
        $fwrite(fid_ser, "grid on\n");
        $fclose(fid_ser);
    end
endfunction
