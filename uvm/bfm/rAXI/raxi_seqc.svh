//--------------------------------------------------------------------------------------------------------------------------------
// name : raxi_seqc
//--------------------------------------------------------------------------------------------------------------------------------
class raxi_seqc extends uvm_sequence #(raxi_seqi);
    `uvm_object_utils(raxi_seqc)
    `uvm_object_new

    extern task pre_body();
    extern task body();

    bit const_ready = 0;
    raxi_seqi                           raxi_seqi_h;
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task raxi_seqc::pre_body();
    `uvm_object_create(raxi_seqi, raxi_seqi_h);
endtask

task raxi_seqc::body();
    forever begin
        start_item(raxi_seqi_h);
            if (const_ready == 1)
                raxi_seqi_h.ready = 1;
            else
                raxi_seqi_h.ready = $urandom_range(0, 1);
        finish_item(raxi_seqi_h);
    end
endtask