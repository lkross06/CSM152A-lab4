/*
 * == Logic ==
 * Translates inputs to the current "sound wave" that should be sent to the audio amplifier's analog pin.
 *
 * Inputs:  mode            0 = normal (metronome not expressed), 1 = metronome (metronome expressed). current mode of operation
 *          freq[XXXXX:0][15:0]     frequency (Hz) / pitch / note that each of the 16 keypad buttons represent. supplied by configuration file
 *          keypad[15:0]    0 = button off, 1 = button on for each button on the keypad
 *          clk_metronome   square wave representing current metronome. change in square wave = one metronome pulse
 *          volume[3:0]     unsigned BCD, current state of volume [0,15]. 0 = no volume / muted, 15 = maximum volume
 *
 * Outputs: ain             analog signal to be sent to pmodAMP2 (e.g. the "sound wave")
 */
 module logic (
    input mode,
    input [XXXXX:0][15:0] freq,
    input [15:0] keypad,
    input clk_metronome,
    input [3:0] volume,
    output reg ain
 );

// TODO

//NOTE: not sure how big freq[][] should be.. or if there's a better way to store

endmodule
