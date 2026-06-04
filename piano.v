/*
 * == Piano ==
 * Top-level module, handles GPIO pinouts. Reads configuration file with delta_bpm and frequency per keypad button
 *
 * Inputs:  master_clk      100 MHz hardware clock square wave
 *          sw              switch input
 *          btnL            left button input
 *          btnR            right button input
 *          btnU            up button input
 *          btnD            down button input
 *          JA[7:0]         GPIO pins from PmodKYPD input
 * 
 * Outputs: led[15:0]       current state of 16 user-controlled LEDs (0 = off, 1 = on)
 *          JC[3:0]         GPIO pins for PmodAMP2 output
 *          seg[6:0]        current state of the seven segments for the LED display
 *          an[3:0]         "on switch" for each of the four used digits (0 = on, 1 = off)
 */
 module piano (
    input master_clk,
    input [1:0] sw,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    inout [7:0] JA,
    output [15:0] led,
    output [3:0] JC,
    output [6:0] seg,
    output [3:0] an
 );

    wire clk_fast; // 500 Hz clock for debouncing buttons/switches
    wire [15:0] btnKYPD;

    wire mode;
    wire harmony;
    wire volume_dec;
    wire volume_inc;
    wire metronome_inc;
    wire metronome_dec;
    wire [15:0] keypad;

    wire [4:0] vol;
    wire muted;
    wire [3:0] delta_bpm = 4'd5; //TODO: make this come from a file
    wire [7:0] bpm;
    wire clk_metronome;

    clock_divider clk_div (
        .master_clk(master_clk),
        .clk_fast(clk_fast)
    );

    pmodKYPD kypd (
        .clk_fast(clk_fast),
        .JA(JA),
        .btnKYPD(btnKYPD)
    );

    clean_inputs ci (
        .clk_fast(clk_fast),
        .sw0(sw[0]),
        .sw1(sw[1]),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .btnKYPD(btnKYPD),
        .mode(mode),
        .harmony(harmony),
        .volume_inc(volume_inc),
        .volume_dec(volume_dec),
        .metronome_inc(metronome_inc),
        .metronome_dec(metronome_dec),
        .keypad(keypad)
    );


    volume vol_logic (
        .clk(master_clk),
        .volume_inc(volume_inc),
        .volume_dec(volume_dec),
        .volume(vol),
        .muted(muted),
        .led(led) //constraint file variable
    );

    metronome met (
        .clk_fast(clk_fast),
        .metronome_inc(metronome_inc),
        .metronome_dec(metronome_dec),
        .delta_bpm(delta_bpm),
        .mode(mode),
        .bpm(bpm),
        .clk_metronome(clk_metronome)
    );

    display display_manager (
        .bpm(bpm),
        .mode(mode),
        .clk_fast(clk_fast),
        .seg(seg),
        .an(an)
    );

    // ------------------------------------------------------------------------
    // Configuration Frequencies (16 notes * 16-bits = 256 bits)
    // You can adjust these integer values to match any musical scale you like.
    // Standard Equal Temperament Tunings (e.g., C4 = 262, E4 = 330, A4 = 440)
    // ------------------------------------------------------------------------
    wire [255:0] target_frequencies = {
        16'd523, // Button 15 (C5)
        16'd494, // Button 14 (B4)
        16'd440, // Button 13 (A4)
        16'd392, // Button 12 (G4)
        16'd349, // Button 11 (F4)
        16'd330, // Button 10 (E4)
        16'd294, // Button 9  (D4)
        16'd262, // Button 8  (C4)
        16'd247, // Button 7  (B3)
        16'd220, // Button 6  (A3)
        16'd196, // Button 5  (G3)
        16'd175, // Button 4  (F3)
        16'd165, // Button 3  (E3)
        16'd147, // Button 2  (D3)
        16'd131, // Button 1  (C3)
        16'd110  // Button 0  (A2)
    };

    // ------------------------------------------------------------------------
    // Instantiate Audio Engine & PmodAMP2 Driver
    // ------------------------------------------------------------------------
    wire pwm_audio_out;
    wire amp_shutdown;

    logic audio_engine (
        .master_clk(master_clk),
        .mode(mode),
        .harmony(harmony),
        .freq_packed(target_frequencies),
        .keypad(keypad),
        .clk_metronome(clk_metronome),
        .volume(vol[3:0]), // Downsizing 5-bit volume wire to 4-bit module input
        .muted(muted),
        .ain(pwm_audio_out),
        .shdn(amp_shutdown)
    );

    // ------------------------------------------------------------------------
    // Map Output Pins to PmodAMP2 Pin Header JC
    // ------------------------------------------------------------------------
    assign JC[0] = pwm_audio_out; // JA1/JC1 pin -> AIN
    assign JC[1] = 1'b1;          // JA2/JC2 pin -> GAIN (1'b1 = +6dB, 1'b0 = 0dB)
    assign JC[2] = 1'b0;          // Unused NC pin
    assign JC[3] = amp_shutdown;  // JA4/JC4 pin -> SHDN

 endmodule