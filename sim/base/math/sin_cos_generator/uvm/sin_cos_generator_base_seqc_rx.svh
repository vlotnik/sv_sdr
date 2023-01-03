//--------------------------------------------------------------------------------------------------------------------------------
// name : sin_cos_generator_base_seqc_rx
//--------------------------------------------------------------------------------------------------------------------------------
class sin_cos_generator_base_seqc_rx #(
      PHASE_W
) extends uvm_sequence #(sin_cos_generator_seqi);
    `uvm_object_param_utils(sin_cos_generator_base_seqc_rx #(PHASE_W))
    `uvm_object_new

    extern task pre_body();
    extern task body();

    sin_cos_generator_seqi #(
          .PHASE_W(PHASE_W)
    )                                   sincos_seqi_h;

    int coverage_stat = 0;

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sin_cos_generator_base_seqc_rx::pre_body();
    `uvm_object_create(sin_cos_generator_seqi #(PHASE_W), sincos_seqi_h)
endtask

task sin_cos_generator_base_seqc_rx::body();
    // while (coverage_stat < 100) begin
    repeat (100) begin
        start_item(sincos_seqi_h);
            assert(sincos_seqi_h.randomize());
        finish_item(sincos_seqi_h);

        coverage_stat = $get_coverage();
        $display("current coverage = %d", coverage_stat);
    end
endtask