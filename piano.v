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
    input sw,
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
        .sw0(sw),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .btnKYPD(btnKYPD),
        .mode(mode),
        .volume_inc(volume_inc),
        .volume_dec(volume_dec),
        .metronome_inc(metronome_inc),
        .metronome_dec(metronome_dec),
        .keypad(keypad)
    );

//    pmodAMP2 amp (
//         .i_clk(master_clk),
//         .i_sw({btnL, btnR, btnU, btnD}),

//         .o_audio(JC[0]),
//         .o_gain(JC[1]),
//         .o_shutdown_n(JC[2])
//     );

    volume vol_logic (
        .clk(master_clk),
        .volume_inc(volume_inc),
        .volume_dec(volume_dec),
        .volume(vol),
        .muted(muted),
        .led(led) //constraint file variable
    );

    display display_manager (
        .bpm(bpm),
        .mode(mode),
        .clk_fast(clk_fast),
        .seg(seg),
        .an(an)
    );

 endmodule