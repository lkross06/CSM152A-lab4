module logic (
    input master_clk,                   // 100 MHz system clock (from board)
    input mode,                         // 0 = normal, 1 = metronome expressed
    input [255:0] freq_packed,          // Flattened 16x16-bit array (16 buttons * 16 bits)
    input [15:0] keypad,                // 0 = button off, 1 = button on
    input clk_metronome,                // Square wave representing metronome
    input [3:0] volume,                 // Unsigned volume 0-15
    input muted,                        // 1 = muted / no volume
    input harmony,                      // 1 = harmony mode on, 0 = off
    output reg ain,                     // Pipelined PWM audio to PmodAMP2 AIN
    output reg shdn                     // Pipelined shutdown to PmodAMP2 SHDN
);

    // ------------------------------------------------------------------------
    // UNPACK PACKED INPUT VECTOR
    // ------------------------------------------------------------------------
    wire [15:0] freq [15:0];
    assign freq[0]  = freq_packed[15:0];
    assign freq[1]  = freq_packed[31:16];
    assign freq[2]  = freq_packed[47:32];
    assign freq[3]  = freq_packed[63:48];
    assign freq[4]  = freq_packed[79:64];
    assign freq[5]  = freq_packed[95:80];
    assign freq[6]  = freq_packed[111:96];
    assign freq[7]  = freq_packed[127:112];
    assign freq[8]  = freq_packed[143:128];
    assign freq[9]  = freq_packed[159:144];
    assign freq[10] = freq_packed[175:160];
    assign freq[11] = freq_packed[191:176];
    assign freq[12] = freq_packed[207:192];
    assign freq[13] = freq_packed[223:208];
    assign freq[14] = freq_packed[239:224];
    assign freq[15] = freq_packed[255:240];

    // ------------------------------------------------------------------------
    // SINE LOOK-UP TABLE (Inferred as BRAM for optimal hardware performance)
    // ------------------------------------------------------------------------
    (* rom_style = "block" *)
    reg [7:0] sine_lut [0:255];
    initial begin
        sine_lut[0]=128;sine_lut[1]=131;sine_lut[2]=134;sine_lut[3]=137;
        sine_lut[4]=140;sine_lut[5]=143;sine_lut[6]=146;sine_lut[7]=149;
        sine_lut[8]=152;sine_lut[9]=156;sine_lut[10]=159;sine_lut[11]=162;
        sine_lut[12]=165;sine_lut[13]=168;sine_lut[14]=171;sine_lut[15]=174;
        sine_lut[16]=176;sine_lut[17]=179;sine_lut[18]=182;sine_lut[19]=185;
        sine_lut[20]=188;sine_lut[21]=190;sine_lut[22]=193;sine_lut[23]=196;
        sine_lut[24]=198;sine_lut[25]=201;sine_lut[26]=203;sine_lut[27]=206;
        sine_lut[28]=208;sine_lut[29]=211;sine_lut[30]=213;sine_lut[31]=215;
        sine_lut[32]=218;sine_lut[33]=220;sine_lut[34]=222;sine_lut[35]=224;
        sine_lut[36]=226;sine_lut[37]=228;sine_lut[38]=230;sine_lut[39]=232;
        sine_lut[40]=234;sine_lut[41]=235;sine_lut[42]=237;sine_lut[43]=239;
        sine_lut[44]=240;sine_lut[45]=242;sine_lut[46]=243;sine_lut[47]=244;
        sine_lut[48]=246;sine_lut[49]=247;sine_lut[50]=248;sine_lut[51]=249;
        sine_lut[52]=250;sine_lut[53]=251;sine_lut[54]=252;sine_lut[55]=252;
        sine_lut[56]=253;sine_lut[57]=254;sine_lut[58]=254;sine_lut[59]=255;
        sine_lut[60]=255;sine_lut[61]=255;sine_lut[62]=255;sine_lut[63]=255;
        sine_lut[64]=255;sine_lut[65]=255;sine_lut[66]=255;sine_lut[67]=255;
        sine_lut[68]=255;sine_lut[69]=254;sine_lut[70]=254;sine_lut[71]=253;
        sine_lut[72]=252;sine_lut[73]=252;sine_lut[74]=251;sine_lut[75]=250;
        sine_lut[76]=249;sine_lut[77]=248;sine_lut[78]=247;sine_lut[79]=246;
        sine_lut[80]=244;sine_lut[81]=243;sine_lut[82]=242;sine_lut[83]=240;
        sine_lut[84]=239;sine_lut[85]=237;sine_lut[86]=235;sine_lut[87]=234;
        sine_lut[88]=232;sine_lut[89]=230;sine_lut[90]=228;sine_lut[91]=226;
        sine_lut[92]=224;sine_lut[93]=222;sine_lut[94]=220;sine_lut[95]=218;
        sine_lut[96]=215;sine_lut[97]=213;sine_lut[98]=211;sine_lut[99]=208;
        sine_lut[100]=206;sine_lut[101]=203;sine_lut[102]=201;sine_lut[103]=198;
        sine_lut[104]=196;sine_lut[105]=193;sine_lut[106]=190;sine_lut[107]=188;
        sine_lut[108]=185;sine_lut[109]=182;sine_lut[110]=179;sine_lut[111]=176;
        sine_lut[112]=174;sine_lut[113]=171;sine_lut[114]=168;sine_lut[115]=165;
        sine_lut[116]=162;sine_lut[117]=159;sine_lut[118]=156;sine_lut[119]=152;
        sine_lut[120]=149;sine_lut[121]=146;sine_lut[122]=143;sine_lut[123]=140;
        sine_lut[124]=137;sine_lut[125]=134;sine_lut[126]=131;sine_lut[127]=128;
        sine_lut[128]=124;sine_lut[129]=121;sine_lut[130]=118;sine_lut[131]=115;
        sine_lut[132]=112;sine_lut[133]=109;sine_lut[134]=106;sine_lut[135]=103;
        sine_lut[136]=99;sine_lut[137]=96;sine_lut[138]=93;sine_lut[139]=90;
        sine_lut[140]=87;sine_lut[141]=84;sine_lut[142]=81;sine_lut[143]=79;
        sine_lut[144]=76;sine_lut[145]=73;sine_lut[146]=70;sine_lut[147]=67;
        sine_lut[148]=65;sine_lut[149]=62;sine_lut[150]=60;sine_lut[151]=57;
        sine_lut[152]=55;sine_lut[153]=52;sine_lut[154]=50;sine_lut[155]=48;
        sine_lut[156]=45;sine_lut[157]=43;sine_lut[158]=41;sine_lut[159]=39;
        sine_lut[160]=37;sine_lut[161]=35;sine_lut[162]=33;sine_lut[163]=31;
        sine_lut[164]=29;sine_lut[165]=28;sine_lut[166]=26;sine_lut[167]=24;
        sine_lut[168]=23;sine_lut[169]=21;sine_lut[170]=20;sine_lut[171]=18;
        sine_lut[172]=17;sine_lut[173]=15;sine_lut[174]=14;sine_lut[175]=13;
        sine_lut[176]=11;sine_lut[177]=10;sine_lut[178]=9;sine_lut[179]=8;
        sine_lut[180]=7;sine_lut[181]=6;sine_lut[182]=5;sine_lut[183]=4;
        sine_lut[184]=3;sine_lut[185]=3;sine_lut[186]=2;sine_lut[187]=1;
        sine_lut[188]=1;sine_lut[189]=0;sine_lut[190]=0;sine_lut[191]=0;
        sine_lut[192]=0;sine_lut[193]=0;sine_lut[194]=0;sine_lut[195]=0;
        sine_lut[196]=0;sine_lut[197]=0;sine_lut[198]=0;sine_lut[199]=0;
        sine_lut[200]=1;sine_lut[201]=1;sine_lut[202]=2;sine_lut[203]=3;
        sine_lut[204]=3;sine_lut[205]=4;sine_lut[206]=5;sine_lut[207]=6;
        sine_lut[208]=7;sine_lut[209]=8;sine_lut[210]=9;sine_lut[211]=10;
        sine_lut[212]=11;sine_lut[213]=13;sine_lut[214]=14;sine_lut[215]=15;
        sine_lut[216]=17;sine_lut[217]=18;sine_lut[218]=20;sine_lut[219]=21;
        sine_lut[220]=23;sine_lut[221]=24;sine_lut[222]=26;sine_lut[223]=28;
        sine_lut[224]=29;sine_lut[225]=31;sine_lut[226]=33;sine_lut[227]=35;
        sine_lut[228]=37;sine_lut[229]=39;sine_lut[230]=41;sine_lut[231]=43;
        sine_lut[232]=45;sine_lut[233]=48;sine_lut[234]=50;sine_lut[235]=52;
        sine_lut[236]=55;sine_lut[237]=57;sine_lut[238]=60;sine_lut[239]=62;
        sine_lut[240]=65;sine_lut[241]=67;sine_lut[242]=70;sine_lut[243]=73;
        sine_lut[244]=76;sine_lut[245]=79;sine_lut[246]=81;sine_lut[247]=84;
        sine_lut[248]=87;sine_lut[249]=90;sine_lut[250]=93;sine_lut[251]=96;
        sine_lut[252]=99;sine_lut[253]=103;sine_lut[254]=106;sine_lut[255]=109;
    end

    // ------------------------------------------------------------------------
    // SAMPLE RATE TICK GENERATOR (100 MHz / 2267 ≈ 44.1 kHz standard audio)
    // ------------------------------------------------------------------------
    reg [11:0] sample_cnt  = 12'd0;
    reg        sample_tick = 1'b0;
    always @(posedge master_clk) begin
        sample_tick <= 1'b0;
        if (sample_cnt == 12'd2266) begin
            sample_cnt  <= 12'd0;
            sample_tick <= 1'b1;
        end else begin
            sample_cnt <= sample_cnt + 12'd1;
        end
    end

    // ------------------------------------------------------------------------
    // 1. DUAL DDS PHASE ACCUMULATORS
    // ------------------------------------------------------------------------
    // Formula matching the reference tone generator: Step = round(Freq * 2^32 / 44100)
    // For 440Hz, 440 * 97391.56 = 42,852,289 (Very close to the reference's 42,812,006)
    // Multiplier approximation constant = 97392
    reg [31:0] phase_acc [15:0];
    
    integer i;
    always @(posedge master_clk) begin
        for (i = 0; i < 16; i = i + 1) begin
            if (keypad[i]) begin
                if (sample_tick)
                    phase_acc[i] <= phase_acc[i] + (freq[i] * 97392);
            end else begin
                phase_acc[i] <= 32'd0; // Quiet midpoint reset
            end
        end
    end

    // ------------------------------------------------------------------------
    // 2. PARALLEL BRAM SINE LOOKUPS
    // ------------------------------------------------------------------------
    reg [7:0] individual_samples [15:0];
    integer m;
    always @(posedge master_clk) begin
        if (sample_tick) begin
            for (m = 0; m < 16; m = m + 1) begin
                if (keypad[m])
                    individual_samples[m] <= sine_lut[phase_acc[m][31:24]];
                else
                    individual_samples[m] <= 8'd128; // Midpoint equilibrium (no DC click)
            end
        end
    end

    // ------------------------------------------------------------------------
    // 3. POLYPHONIC MIXER WITH METRONOME INTEGRATION
    // ------------------------------------------------------------------------
    reg [11:0] mixed_audio_sum; // Fits max potential of 16 blended 8-bit channels
    
    // Metronome Click generator
    reg last_metronome;
    reg [20:0] metro_click_duration;
    always @(posedge master_clk) begin
        last_metronome <= clk_metronome;
        if (clk_metronome != last_metronome) begin
            metro_click_duration <= 20'hFFFFF;
        end else if (metro_click_duration > 0) begin
            metro_click_duration <= metro_click_duration - 1;
        end
    end

    integer j;
    always @(*) begin
        mixed_audio_sum = 12'd0;
        // Average accumulation
        for (j = 0; j < 16; j = j + 1) begin
            mixed_audio_sum = mixed_audio_sum + individual_samples[j];
        end
        
        // Incorporate Metronome Click if mode is selected
        if (mode == 1 && metro_click_duration > 0) begin
            // Inject sharp pulse transient 
            mixed_audio_sum = mixed_audio_sum + (metro_click_duration[10] ? 12'd255 : 12'd0);
        end
    end

    // Normalization step down to 8-bit sample depth
    wire [7:0] final_sample = mixed_audio_sum[11:4];

    // ------------------------------------------------------------------------
    // 4. VOLUME SCALING & PIPELINED PWM ENGINE (From Reference Blueprint)
    // ------------------------------------------------------------------------
    reg [11:0] scaled_amplitude;
    reg [7:0]  pwm_cnt = 8'd0;
    reg        pwm_d1  = 1'b0;

    always @(posedge master_clk) begin
        // Volume adjustment
        if (muted) begin
            scaled_amplitude <= 12'd0;
        end else begin
            // 8-bit sample * 4-bit volume = max 12-bit payload range
            scaled_amplitude <= final_sample * volume;
        end

        // PWM Generation Pipeline
        pwm_cnt <= pwm_cnt + 8'd1;
        
        // Stage 1: Register Comparison
        pwm_d1  <= (pwm_cnt < scaled_amplitude[11:4]); 
        
        // Stage 2: Structural Clean-pin Drive
        ain     <= pwm_d1;
        
        // Shutdown pin follows keypad engagement
        shdn    <= ((keypad != 16'd0) || (mode == 1)) && !muted;
    end

endmodule