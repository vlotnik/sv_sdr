//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_mapper
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_mapper extends sdr_base_mapper;
    `uvm_object_utils(sdr_mapper)
    `uvm_object_new

    extern function void init_plane(t_modulation mod);
//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
function void sdr_mapper::init_plane(t_modulation mod);
    // get selected plane
    case(mod)
    `include "planes/std/iq_mapper_plane_gmsk.sv"
    `include "planes/std/iq_mapper_plane_bpsk.sv"
    `include "planes/std/iq_mapper_plane_qpsk.sv"
    `include "planes/std/iq_mapper_plane_psk8.sv"
    `include "planes/std/iq_mapper_plane_qam16.sv"
    `include "planes/std/iq_mapper_plane_qam16_x2.sv"
    `include "planes/std/iq_mapper_plane_qam32.sv"
    `include "planes/std/iq_mapper_plane_qam64.sv"
    `include "planes/std/iq_mapper_plane_qam128.sv"
    `include "planes/std/iq_mapper_plane_qam256.sv"
    `include "planes/std/iq_mapper_plane_qam512.sv"
    `include "planes/std/iq_mapper_plane_qam1024.sv"
    `include "planes/std/iq_mapper_plane_qam2048.sv"
    `include "planes/std/iq_mapper_plane_qam4096.sv"

//--------------------------------------------------------------------------------------------------------------------------------
// DVB-S2
//--------------------------------------------------------------------------------------------------------------------------------
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_bpsk.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_qpsk.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_psk8.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_2_3.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_3_4.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_4_5.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_5_6.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_8_9.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk16_9_10.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk32_3_4.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk32_4_5.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk32_5_6.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk32_8_9.sv"
    `include "planes/dvbs2/iq_mapper_plane_dvbs2_apsk32_9_10.sv"

//--------------------------------------------------------------------------------------------------------------------------------
// DVB-S2X
//--------------------------------------------------------------------------------------------------------------------------------
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_apsk8_l_5_9.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_apsk8_l_26_45.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_8apsk_90_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_8apsk_96_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_8apsk_100_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_8apsk_18_30.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_8apsk_20_30.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_26_45.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_3_5.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_28_45.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_23_36.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_25_36.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_13_18.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_140_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_154_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_7_15.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_8_15.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12apsk_32_45.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12_16rbapsk_2_3.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12_16rbapsk_32_45.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_8_4_16apsk_128_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_8_4_16apsk_132_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_8_4_16apsk_140_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_16_16_16_16apsk_128_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_4_12_20_28apsk_132_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_16_20_20apsk_7_9.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_16_20_20apsk_4_5.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_8_16_20_20apsk_5_6.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_128apsk_135_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_128apsk_140_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_116_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_20_30.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_124_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_128_180.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_22_30.sv"
    `include "planes/dvbs2x/iq_mapper_plane_dvbs2x_256apsk_135_180.sv"

//--------------------------------------------------------------------------------------------------------------------------------
// DEFAULT
//--------------------------------------------------------------------------------------------------------------------------------
    default : super.plane = {
          0.707,   0.707,               // 0
         -0.707,  -0.707                // 1
    };

    endcase
endfunction