//--------------------------------------------------------------------------------------------------------------------------------
// name : sdr_seqc_freader
//--------------------------------------------------------------------------------------------------------------------------------
class sdr_seqc_freader #(BW = 3) extends sdr_base_seqc;
    `uvm_object_param_utils(sdr_seqc_freader #(BW))
    `uvm_object_new

    extern task pre_body();
    extern task body();

    bit cut = 0;
    string file_path;
    sdr_base_seqc                       dsp_base_seqc_h;
    file_io #(BW) file_rd;
    bit[BW*8-1:0] file_rd_data;
    reg[367:0] riff;

    bit cut_header_wav = 0;
    reg[44*8-1:0] header_wav;
    reg[7:0] header_wav_bytes[];

    string file_wr_path;
    file_io #(BW) file_wr;

//--------------------------------------------------------------------------------------------------------------------------------
endclass

//--------------------------------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//--------------------------------------------------------------------------------------------------------------------------------
task sdr_seqc_freader::pre_body();
    super.pre_body();
    file_rd = new(file_path, "rb");
    // file_wr = new(file_wr_path, "wb");
    if (cut == 1) begin
        riff = file_rd.read_riff();
        $display("%s", file_path);
        $display("RIFF              : %c%c%c%c", riff[367:360], riff[359:352], riff[351:344], riff[343:336]);
        $display("ckID              : %0d", riff[335:304]);
        $display("WAVE              : %c%c%c%c", riff[303:296], riff[295:288], riff[287:280], riff[279:272]);
        $display("fmt               : %c%c%c", riff[271:264], riff[263:256], riff[255:248]);
        $display("ckSize            : %0d", riff[247:216]);
        $display("wFormatTag        : %0d", riff[215:200]);
        $display("nCHannels         : %0d", riff[199:184]);
        $display("nSamplesPerSec    : %0d", riff[183:152]);
        $display("nAvgBytesPerSec   : %0d", riff[151:120]);
        $display("nBlockAlign       : %0d", riff[119:104]);
        $display("wBitsPerSamples   : %0d", riff[103:88]);
        $display("cbSize            : %0d", riff[87:64]);
        $display("data              : %c%c%c%c", riff[63:56], riff[55:48], riff[47:40], riff[39:32]);
        $display("ckDataSize        : %0d", riff[31:0]);
    end

    if (cut_header_wav == 1) begin
        // header_wav = file_rd.read_header_wav();
        file_rd.read_bytes(44, header_wav_bytes);
        // file_wr.write_bytes(header_wav_bytes);
        // file_wr.write_header_wav(header_wav);
        // header_wav_bytes = {>>{header_wav}};
        $display("%p", header_wav_bytes);
        $display("%s", file_path);
        $display("ChunkID        [4]    : %c%c%c%c", header_wav_bytes[0], header_wav_bytes[1], header_wav_bytes[2], header_wav_bytes[3]);
        $display("ChunkSize      [4]    : %0d", {header_wav_bytes[7], header_wav_bytes[6], header_wav_bytes[5], header_wav_bytes[4]});
        $display("Format         [4]    : %c%c%c%c", header_wav_bytes[8], header_wav_bytes[9], header_wav_bytes[10], header_wav_bytes[11]);
        $display("Subchunk1ID    [4]    : %c%c%c%c", header_wav_bytes[12], header_wav_bytes[13], header_wav_bytes[14], header_wav_bytes[15]);
        $display("Subchunk1Size  [4]    : %0d", {header_wav_bytes[19], header_wav_bytes[18], header_wav_bytes[17], header_wav_bytes[16]});
        $display("AudioFormat    [2]    : %0d", {header_wav_bytes[21], header_wav_bytes[20]});
        $display("NumChannels    [2]    : %0d", {header_wav_bytes[23], header_wav_bytes[22]});
        $display("SampleRate     [4]    : %0d", {header_wav_bytes[27], header_wav_bytes[26], header_wav_bytes[25], header_wav_bytes[24]});
        $display("DataRate       [4]    : %0d", {header_wav_bytes[31], header_wav_bytes[30], header_wav_bytes[29], header_wav_bytes[28]});
        $display("BlockAlign     [2]    : %0d", {header_wav_bytes[33], header_wav_bytes[32]});
        $display("BitsPerSample  [2]    : %0d", {header_wav_bytes[35], header_wav_bytes[34]});
        $display("Subchunk2ID    [4]    : %c%c%c%c", header_wav_bytes[36], header_wav_bytes[37], header_wav_bytes[38], header_wav_bytes[39]);
        $display("Subchunk2Size  [4]    : %0d", {header_wav_bytes[43], header_wav_bytes[42], header_wav_bytes[41], header_wav_bytes[40]});
    end
endtask

task sdr_seqc_freader::body();
    forever begin
        file_rd_data = file_rd.read();
        sdr_seqi_rx.new_seqi(1);
        sdr_seqi_rx.valid[0] = new[1];
        sdr_seqi_rx.valid[0][0] = 1;
        sdr_seqi_rx.data_re[0] = $signed(file_rd_data[BW*8/2 - 1 : 0]);
        sdr_seqi_rx.data_im[0] = $signed(file_rd_data[BW*8-1 : BW*8/2]);

        start_item(sdr_seqi_rx);
        finish_item(sdr_seqi_rx);
    end
endtask