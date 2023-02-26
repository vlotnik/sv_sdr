//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_sv_sdr
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_sv_sdr;
    `include "file_io.svh"

    typedef enum{
          BPSK
        , CBPSK
        , QPSK
        , OQPSK
        , PSK8
        , APSK16
        , QAM16
        , QAM16_POL
        , QAM16_X2
        , APSK32
        , QAM32
        , APSK64
        , QAM64
        , APSK128
        , QAM128
        , APSK256
        , QAM256
        , QAM512
        , QAM1024
        , QAM2048
        , QAM4096
        , DVBS2_BPSK
        , DVBS2_QPSK
        , DVBS2_PSK8
        , DVBS2_APSK16_2_3
        , DVBS2_APSK16_3_4
        , DVBS2_APSK16_4_5
        , DVBS2_APSK16_5_6
        , DVBS2_APSK16_8_9
        , DVBS2_APSK16_9_10
        , DVBS2_APSK32_3_4
        , DVBS2_APSK32_4_5
        , DVBS2_APSK32_5_6
        , DVBS2_APSK32_8_9
        , DVBS2_APSK32_9_10
        , DVBS2X_APSK8_L_5_9
        , DVBS2X_APSK8_L_26_45
        , DVBS2X_APSK16
        , DVBS2X_8_8APSK_90_180
        , DVBS2X_8_8APSK_96_180
        , DVBS2X_8_8APSK_100_180
        , DVBS2X_8_8APSK_18_30
        , DVBS2X_8_8APSK_20_30
        , DVBS2X_4_12APSK_26_45
        , DVBS2X_4_12APSK_3_5
        , DVBS2X_4_12APSK_28_45
        , DVBS2X_4_12APSK_23_36
        , DVBS2X_4_12APSK_25_36
        , DVBS2X_4_12APSK_13_18
        , DVBS2X_4_12APSK_140_180
        , DVBS2X_4_12APSK_154_180
        , DVBS2X_4_12APSK_7_15
        , DVBS2X_4_12APSK_8_15
        , DVBS2X_4_12APSK_32_45
        , DVBS2X_4_12_16RBAPSK_2_3
        , DVBS2X_4_12_16RBAPSK_32_45
        , DVBS2X_4_8_4_16APSK_128_180
        , DVBS2X_4_8_4_16APSK_132_180
        , DVBS2X_4_8_4_16APSK_140_180
        , DVBS2X_16_16_16_16APSK_128_180
        , DVBS2X_4_12_20_28APSK_132_180
        , DVBS2X_8_16_20_20APSK_7_9
        , DVBS2X_8_16_20_20APSK_4_5
        , DVBS2X_8_16_20_20APSK_5_6
        , DVBS2X_128APSK_135_180
        , DVBS2X_128APSK_140_180
        , DVBS2X_256APSK_116_180
        , DVBS2X_256APSK_20_30
        , DVBS2X_256APSK_124_180
        , DVBS2X_256APSK_128_180
        , DVBS2X_256APSK_22_30
        , DVBS2X_256APSK_135_180
        , FSK2
        , FSK4
        , GFSK2
        , GFSK4
        , OOK
    } t_modulation;

    typedef struct{
        string name;
        int symbol_size;
        real up_snr;
        bit p_nr;
        int plane_size;
        int mod_type;
        int gainer;
    } t_modulation_settings;

    // Function: print_logo_rainbow
    //
    // Displays rainbow logo
    function void print_logo_rainbow();
        $display("\t");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|###|###|###|   |###|###|###|   |###|###|###|###|   |###|   |   |###|###|###|   |   |   |###|###|");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|###|###|###|###|   |   |###|   |###|###|   |   |   |   |   |###|###|###|   |   |   |###|   |   |");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|###|###|   |###|   |###|   |###|###|###|   |   |   |###|###|###|###|###|   |   |   |   |   |###|");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t");
    endfunction

    // Function: print_logo_dsp
    //
    // Displays digital signal processing logo
    function void print_logo_dsp();
        $display("\t");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|   |###|###|   |   |   |   |###|###|   |   |   |   |###|###|   |   |   |   |###|###|   |   |   |");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|###|   |   |###|   |   |###|   |   |###|   |   |###|   |   |###|   |   |###|   |   |###|   |   |");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t|   |   |   |   |###|###|   |   |   |   |###|###|   |   |   |   |###|###|   |   |   |   |###|###|");
        $display("\t+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+");
        $display("\t");
    endfunction

    // Function: get_modulation_settings
    //
    // Returns settings for selected modulation
    // argument ~modulation~ containts modulation type
    function t_modulation_settings get_modulation_settings(t_modulation modulation);
        t_modulation_settings result;
        case (modulation)
            //                                                           name, symbol_size, up_snr, p_nr, plane_size, mod_type, gainer
            BPSK                                            : result = '{"BPSK"                     ,  1, 11, 1, 12, 0, 1};
            CBPSK                                           : result = '{"CBPSK"                    ,  1, 11, 1, 12, 0, 1};
            QPSK                                            : result = '{"QPSK"                     ,  2, 14, 1, 12, 0, 1};
            OQPSK                                           : result = '{"OQPSK"                    ,  2, 14, 1, 12, 0, 1};
            PSK8                                            : result = '{"PSK8"                     ,  3, 19, 1, 12, 0, 1};
            APSK16                                          : result = '{"APSK16"                   ,  4, 21, 0, 12, 0, 1};
            QAM16                                           : result = '{"QAM16"                    ,  4, 21, 0, 12, 0, 1};
            QAM16_POL                                       : result = '{"QAM16_POL"                ,  4, 21, 1, 12, 0, 1};
            QAM16_X2                                        : result = '{"QAM16_X2"                 ,  4, 21, 0, 12, 0, 2};
            APSK32                                          : result = '{"APSK32"                   ,  5, 24, 0, 12, 0, 1};
            QAM32                                           : result = '{"QAM32"                    ,  5, 24, 0, 12, 0, 1};
            APSK64                                          : result = '{"APSK64"                   ,  6, 27, 0, 12, 0, 1};
            QAM64                                           : result = '{"QAM64"                    ,  6, 27, 0, 12, 0, 1};
            QAM128                                          : result = '{"QAM128"                   ,  7, 30, 0, 16, 0, 1};
            APSK128                                         : result = '{"APSK128"                  ,  7, 30, 0, 16, 0, 1};
            APSK256                                         : result = '{"APSK256"                  ,  8, 33, 0, 16, 0, 1};
            QAM256                                          : result = '{"QAM256"                   ,  8, 33, 0, 16, 0, 1};
            QAM512                                          : result = '{"QAM512"                   ,  9, 36, 0, 16, 0, 1};
            QAM1024                                         : result = '{"QAM1024"                  , 10, 39, 0, 16, 0, 2};
            QAM2048                                         : result = '{"QAM2048"                  , 11, 40, 0, 16, 0, 2};
            QAM4096                                         : result = '{"QAM4096"                  , 12, 42, 0, 16, 0, 2};
            // DVB-S2
            DVBS2_BPSK                                      : result = '{"BPSK"                     ,  1, 11, 1, 12, 0, 1};
            DVBS2_QPSK                                      : result = '{"QPSK"                     ,  2, 14, 1, 12, 0, 1};
            DVBS2_PSK8                                      : result = '{"PSK8"                     ,  3, 19, 1, 12, 0, 1};
            DVBS2_APSK16_2_3                                : result = '{"APSK16_2_3"               ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK16_3_4                                : result = '{"APSK16_3_4"               ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK16_4_5                                : result = '{"APSK16_4_5"               ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK16_5_6                                : result = '{"APSK16_5_6"               ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK16_8_9                                : result = '{"APSK16_8_9"               ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK16_9_10                               : result = '{"APSK16_9_10"              ,  4, 23, 1, 12, 0, 1};
            DVBS2_APSK32_3_4                                : result = '{"APSK32_3_4"               ,  5, 26, 1, 12, 0, 1};
            DVBS2_APSK32_4_5                                : result = '{"APSK32_4_5"               ,  5, 26, 1, 12, 0, 1};
            DVBS2_APSK32_5_6                                : result = '{"APSK32_5_6"               ,  5, 26, 1, 12, 0, 1};
            DVBS2_APSK32_8_9                                : result = '{"APSK32_8_9"               ,  5, 26, 1, 12, 0, 1};
            DVBS2_APSK32_9_10                               : result = '{"APSK32_9_10"              ,  5, 26, 1, 12, 0, 1};
            // DVB-S2X
            DVBS2X_APSK8_L_5_9                              : result = '{"APSK8_L_5_9"              ,  3, 19, 1, 12, 0, 1};
            DVBS2X_APSK8_L_26_45                            : result = '{"APSK8_L_26_45"            ,  3, 19, 1, 12, 0, 1};
            DVBS2X_APSK16                                   : result = '{"APSK16"                   ,  4, 23, 1, 12, 0, 1};
            DVBS2X_8_8APSK_90_180                           : result = '{"8_8APSK_90_180"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_8_8APSK_96_180                           : result = '{"8_8APSK_96_180"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_8_8APSK_100_180                          : result = '{"8_8APSK_100_180"          ,  4, 23, 1, 12, 0, 1};
            DVBS2X_8_8APSK_18_30                            : result = '{"8_8APSK_18_30"            ,  4, 23, 1, 12, 0, 1};
            DVBS2X_8_8APSK_20_30                            : result = '{"8_8APSK_20_30"            ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_26_45                           : result = '{"4_12APSK_26_45"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_3_5                             : result = '{"4_12APSK_3_5"             ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_28_45                           : result = '{"4_12APSK_28_45"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_23_36                           : result = '{"4_12APSK_23_36"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_25_36                           : result = '{"4_12APSK_25_36"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_13_18                           : result = '{"4_12APSK_13_18"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_140_180                         : result = '{"4_12APSK_140_180"         ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_154_180                         : result = '{"4_12APSK_154_180"         ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_7_15                            : result = '{"4_12APSK_7_15"            ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_8_15                            : result = '{"4_12APSK_8_15"            ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12APSK_32_45                           : result = '{"4_12APSK_32_45"           ,  4, 23, 1, 12, 0, 1};
            DVBS2X_4_12_16RBAPSK_2_3                        : result = '{"4_12_16RBAPSK_2_3"        ,  5, 25, 1, 12, 0, 1};
            DVBS2X_4_12_16RBAPSK_32_45                      : result = '{"4_12_16RBAPSK_32_45"      ,  5, 25, 1, 12, 0, 1};
            DVBS2X_4_8_4_16APSK_128_180                     : result = '{"4_8_4_16APSK_128_180"     ,  5, 25, 1, 12, 0, 1};
            DVBS2X_4_8_4_16APSK_132_180                     : result = '{"4_8_4_16APSK_132_180"     ,  5, 25, 1, 12, 0, 1};
            DVBS2X_4_8_4_16APSK_140_180                     : result = '{"4_8_4_16APSK_140_180"     ,  5, 25, 1, 12, 0, 1};
            DVBS2X_16_16_16_16APSK_128_180                  : result = '{"16_16_16_16APSK_128_180"  ,  6, 27, 1, 12, 0, 1};
            DVBS2X_4_12_20_28APSK_132_180                   : result = '{"4_12_20_28APSK_132_180"   ,  6, 27, 1, 12, 0, 1};
            DVBS2X_8_16_20_20APSK_7_9                       : result = '{"8_16_20_20APSK_7_9"       ,  6, 27, 1, 12, 0, 1};
            DVBS2X_8_16_20_20APSK_4_5                       : result = '{"8_16_20_20APSK_4_5"       ,  6, 27, 1, 12, 0, 1};
            DVBS2X_8_16_20_20APSK_5_6                       : result = '{"8_16_20_20APSK_5_6"       ,  6, 27, 1, 12, 0, 1};
            DVBS2X_128APSK_135_180                          : result = '{"128APSK_135_180"          ,  7, 30, 1, 16, 0, 1};
            DVBS2X_128APSK_140_180                          : result = '{"128APSK_140_180"          ,  7, 30, 1, 16, 0, 1};
            DVBS2X_256APSK_116_180                          : result = '{"256APSK_116_180"          ,  8, 33, 1, 16, 0, 1};
            DVBS2X_256APSK_20_30                            : result = '{"256APSK_20_30"            ,  8, 33, 1, 16, 0, 1};
            DVBS2X_256APSK_124_180                          : result = '{"256APSK_124_180"          ,  8, 33, 1, 16, 0, 1};
            DVBS2X_256APSK_128_180                          : result = '{"256APSK_128_180"          ,  8, 33, 1, 16, 0, 1};
            DVBS2X_256APSK_22_30                            : result = '{"256APSK_22_30"            ,  8, 33, 1, 16, 0, 1};
            DVBS2X_256APSK_135_180                          : result = '{"256APSK_135_180"          ,  8, 33, 1, 16, 0, 1};
            // FSK
            FSK2                                            : result = '{"FSK2"                     ,  1, 11, 1, 12, 1, 1};
            FSK4                                            : result = '{"FSK4"                     ,  2, 14, 1, 12, 1, 1};
            GFSK2                                           : result = '{"GFSK2"                    ,  1, 11, 1, 12, 1, 1};
            GFSK4                                           : result = '{"GFSK4"                    ,  2, 14, 1, 12, 1, 1};
            // On-Off Keying
            OOK                                             : result = '{"OOK"                      ,  1, 11, 1, 12, 2, 1};
            default                                         : result = '{"BPSK"                     ,  1, 50, 1, 12, 0, 1};
        endcase
        return result;
    endfunction
//-------------------------------------------------------------------------------------------------------------------------------
endpackage