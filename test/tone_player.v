// =============================================================================
// tone_player.v  (timing-fixed revision)
// Basys3 + PmodAMP2 — Play a 440 Hz sine tone when center button is pressed
//
// Timing fixes vs previous version:
//   1. sample_cnt widened to 12 bits (exact constant 2266 used, no divide)
//   2. Two-FF synchroniser added on the async button input
//   3. Sine LUT forced into BRAM with (* rom_style="block" *) — removes the
//      large LUT fanout from the timing-critical PWM comparator path
//   4. PWM output pipelined into two registered stages so the comparator
//      result never drives an output pin directly across the package delay
//   5. shdn and ain are now 'reg' outputs driven from FFs, not wires
//   6. XDC uses set_false_path on all output ports so Vivado won't flag
//      the board trace delay as a timing violation
// =============================================================================

module tone_player (
    input  wire clk,     // 100 MHz system clock (W5)
    input  wire btnc,    // Center button, active HIGH (U18)
    output reg  ain,     // PWM audio → PmodAMP2 AIN  (JA1 = J1)
    output wire gain,    // Gain select → PmodAMP2 GAIN (JA2 = L2)
    output reg  shdn     // Shutdown    → PmodAMP2 SHDN (JA4 = J2)
);

    // -----------------------------------------------------------------------
    // DDS increment for 440 Hz:  round(440 * 2^32 / 44100) = 42_812_006
    // -----------------------------------------------------------------------
    localparam [31:0] PHASE_INC = 32'd42_812_006;

    // -----------------------------------------------------------------------
    // Sine look-up table — 256 x 8-bit, inferred as BRAM
    // Values = round(127.5 * (1 + sin(2*pi*i/256))), i = 0..255
    // -----------------------------------------------------------------------
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

    // -----------------------------------------------------------------------
    // Two-FF synchroniser for async button input
    // -----------------------------------------------------------------------
    reg btn_s0 = 0, btn_s1 = 0;
    always @(posedge clk) begin
        btn_s0 <= btnc;
        btn_s1 <= btn_s0;
    end

    // -----------------------------------------------------------------------
    // Debounce — 5 ms hold required before state change
    // 5 ms * 100 MHz = 500,000 cycles  → 20-bit counter
    // -----------------------------------------------------------------------
    reg [19:0] db_cnt   = 20'd0;
    reg        btn_clean = 1'b0;

    always @(posedge clk) begin
        if (btn_s1 != btn_clean) begin
            if (db_cnt == 20'd499_999) begin
                btn_clean <= btn_s1;
                db_cnt    <= 20'd0;
            end else begin
                db_cnt <= db_cnt + 20'd1;
            end
        end else begin
            db_cnt <= 20'd0;
        end
    end

    // -----------------------------------------------------------------------
    // Sample-rate tick:  100 MHz / 2267 ≈ 44,130 Hz  (~44.1 kHz)
    // 12-bit counter holds 0-2266 (max 4095, fits fine)
    // -----------------------------------------------------------------------
    reg [11:0] sample_cnt  = 12'd0;
    reg        sample_tick = 1'b0;

    always @(posedge clk) begin
        sample_tick <= 1'b0;
        if (sample_cnt == 12'd2266) begin
            sample_cnt  <= 12'd0;
            sample_tick <= 1'b1;
        end else begin
            sample_cnt <= sample_cnt + 12'd1;
        end
    end

    // -----------------------------------------------------------------------
    // DDS phase accumulator
    // -----------------------------------------------------------------------
    reg [31:0] phase_acc = 32'd0;

    always @(posedge clk) begin
        if (!btn_clean)
            phase_acc <= 32'd0;
        else if (sample_tick)
            phase_acc <= phase_acc + PHASE_INC;
    end

    // -----------------------------------------------------------------------
    // BRAM read — registered (1-cycle latency, inaudible at 44 kHz)
    // When silent: hold at midpoint (128 = 50 % duty = DC offset free)
    // -----------------------------------------------------------------------
    reg [7:0] sample = 8'd128;

    always @(posedge clk) begin
        if (!btn_clean)
            sample <= 8'd128;
        else if (sample_tick)
            sample <= sine_lut[phase_acc[31:24]];
    end

    // -----------------------------------------------------------------------
    // PWM generator — pipelined into two FF stages
    //
    //   Stage 0: free-running 8-bit counter  (pwm_cnt)
    //   Stage 1: registered compare result   (pwm_d1)
    //   Stage 2: output register             (ain)
    //
    // PWM carrier = 100 MHz / 256 = 390,625 Hz  (well above hearing)
    // Two-cycle pipeline latency = 20 ns → completely inaudible
    // -----------------------------------------------------------------------
    reg [7:0] pwm_cnt = 8'd0;
    reg       pwm_d1  = 1'b0;

    always @(posedge clk) begin
        pwm_cnt <= pwm_cnt + 8'd1;          // stage 0
        pwm_d1  <= (pwm_cnt < sample);      // stage 1: compare
        ain     <= pwm_d1;                  // stage 2: to pin
    end

    // -----------------------------------------------------------------------
    // SHDN — registered output, enable amp only while button held
    // GAIN — constant, driven from a constant-1 LUT (no timing path)
    // -----------------------------------------------------------------------
    always @(posedge clk)
        shdn <= btn_clean;

    assign gain = 1'b1;   // 6 dB gain; change to 0 for unity gain

endmodule
