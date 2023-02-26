//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_gainer
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_gainer extends uvm_object;
    `uvm_object_utils(sdr_gainer)
    `uvm_object_new

    extern function void gain(ref sdr_seqi sdr_seqi_h);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function automatic void sdr_gainer::gain(ref sdr_seqi sdr_seqi_h);
    int data_size;

    data_size = sdr_seqi_h.data_re.size();

    for (int i = 0; i < data_size; i++) begin
        sdr_seqi_h.data_re[i] = $rtoi($itor(sdr_seqi_h.data_re[i]) * sdr_seqi_h.tr_gain);
        sdr_seqi_h.data_im[i] = $rtoi($itor(sdr_seqi_h.data_im[i]) * sdr_seqi_h.tr_gain);
    end
endfunction