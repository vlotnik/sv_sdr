//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_sampler
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_sampler extends uvm_object;
    `uvm_object_utils(sdr_sampler)
    `uvm_object_new

    extern function void init(real symbol_frequency, real system_frequency);
    extern function void get_sym_v(ref sdr_seqi sdr_seqi_h);

    protected real symbol_frequency;
    protected real system_frequency;
    protected real symbol_frequency_accumulator;
    protected int sym_v_length;
    protected t_int_array_of_queue valid_queue;
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_sampler::init(real symbol_frequency, real system_frequency);
    real lb;
    real rb;

    this.symbol_frequency = symbol_frequency;
    this.symbol_frequency_accumulator = symbol_frequency;
    this.system_frequency = system_frequency;

    if (symbol_frequency >= system_frequency) begin
        sym_v_length = $pow(2, 0);
    end else begin
        for (int i = 1; i < 10; i++) begin
            lb = system_frequency / $pow(2, i);
            rb = system_frequency / $pow(2, i - 1);
            if ((symbol_frequency >= lb) && (symbol_frequency < rb)) begin
                sym_v_length = $pow(2, i);
                break;
            end
        end
    end
endfunction

function void sdr_sampler::get_sym_v(ref sdr_seqi sdr_seqi_h);
    init(sdr_seqi_h.tr_sym_f, sdr_seqi_h.tr_sys_f);

    valid_queue = new[sdr_seqi_h.data_re.size()];
    foreach(valid_queue[i]) begin
        for (int j = (sym_v_length - 1); j >= 0; j--) begin
            if ((system_frequency - symbol_frequency_accumulator) > 0) begin
                valid_queue[i].push_front(0);
                symbol_frequency_accumulator += symbol_frequency;
            end else begin
                valid_queue[i].push_front(1);
                symbol_frequency_accumulator += symbol_frequency;
                symbol_frequency_accumulator -= system_frequency;
                break;
            end
        end
    end

    sdr_seqi_h.valid = valid_queue;
endfunction