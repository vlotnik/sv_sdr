//--------------------------------------------------------------------------------------------------------------------------------
// name : pkg_vrf_dsp_components
//--------------------------------------------------------------------------------------------------------------------------------
package pkg_vrf_dsp_components;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "common_macros.svh"

    import pkg_sv_sdr_types::*;
    import pkg_sv_sdr::*;
    import pkg_sv_sdr_math::*;

    // base components
    `include "./components/base/sdr_seqi.svh"
    typedef uvm_sequencer #(sdr_seqi) sdr_seqr;
    typedef uvm_analysis_port #(sdr_seqi) sdr_aprt;
    `include "./components/base/sdr_base_seqc.svh"
    `include "./components/base/sdr_base_layr.svh"

    // file IO
    `include "./components/file/sdr_seqc_freader.svh"

    // dataflow
    `include "./components/dataflow/sdr_sampler.svh"
    `include "./components/dataflow/sdr_seqc_sampler.svh"
    `include "./components/dataflow/sdr_layr_sampler.svh"

    `include "./components/dataflow/sdr_seqc_sym_framer.svh"
    `include "./components/dataflow/sdr_layr_sym_framer.svh"

    `include "./components/dataflow/sdr_seqc_buffer.svh"
    `include "./components/dataflow/sdr_layr_buffer.svh"

    `include "./components/dataflow/sdr_seqc_mch_buffer.svh"
    `include "./components/dataflow/sdr_layr_mch_buffer.svh"

    // filters
    `include "./components/filters/sdr_filter_design.svh"

    `include "./components/filters/sdr_resampler.svh"
    `include "./components/filters/sdr_seqc_resampler.svh"
    `include "./components/filters/sdr_layr_resampler.svh"

    `include "./components/filters/sdr_fir_filter.svh"
    `include "./components/filters/sdr_seqc_fir_filter.svh"
    `include "./components/filters/sdr_layr_fir_filter.svh"
    `include "./components/filters/sdr_seqc_fir_decimator.svh"
    `include "./components/filters/sdr_layr_fir_decimator.svh"

    `include "./components/filters/sdr_gauss_filter.svh"

    // math
    `include "./components/math/sdr_mixer.svh"
    `include "./components/math/sdr_seqc_mixer.svh"
    `include "./components/math/sdr_layr_mixer.svh"

    `include "./components/math/sdr_gainer.svh"
    `include "./components/math/sdr_seqc_gainer.svh"
    `include "./components/math/sdr_layr_gainer.svh"

    `include "./components/math/sdr_seqc_iq_scrambler.svh"
    `include "./components/math/sdr_layr_iq_scrambler.svh"

    `include "./components/math/sdr_seqc_summator.svh"
    `include "./components/math/sdr_layr_summator.svh"

    `include "./components/math/sdr_seqc_spmod.svh"
    `include "./components/math/sdr_layr_spmod.svh"

    // mappers
    `include "./components/mappers/sdr_base_mapper.svh"
    `include "./components/mappers/sdr_mapper.svh"
    `include "./components/mappers/sdr_seqc_mapper.svh"
    `include "./components/mappers/sdr_layr_mapper.svh"

    // distortions
    `include "./components/distortions/sdr_awgn.svh"
    `include "./components/distortions/sdr_seqc_awgn.svh"
    `include "./components/distortions/sdr_layr_awgn.svh"

    // scoreboards
    `include "./components/scoreboards/sdr_base_scrb.svh"
    `include "./components/scoreboards/sdr_scrb_rxtx.svh"
//--------------------------------------------------------------------------------------------------------------------------------
endpackage