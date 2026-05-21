/*
 * == Metronome ==
 * Takes inputs from metronome inc/dec buttons, holds current state of the metronome BPM [0, 255]. Generates a square wave at that BPM
 *
 * Inputs:  clk_fast        500Hz square wave clock to be divided into metronome clock
 *          metronome_inc   0 = do not incremnet, 1 = increment metronome (by delta_bpm) once
 *          metronome_dec   0 = do not decrement, 1 = decrement metronome (by delta_bpm) once
 *          delta_bpm[3:0]  unsigned BCD, amount (0 <= delta_bpm <= 15) to change your BPM by on inc/dec
 *          mode            0 = normal, 1 = metronome. inc/dec should only take effect in metronome mode
 *
 * Outputs: bpm[7:0]        beats per minute of metronome as unsigned BCD [0, 255] (for display)
 *          clk_metronome   square wave representing current metronome. METRONOME SHOULD "PULSE" ON SQUARE WAVE CHANGE (so BPM != clock frequency)
 */

module metronome(
    input clk_fast,
    input metronome_inc,
    input metronome_dec,
    input delta_bpm[3:0],
    input mode,
    output reg bpm[7:0],
    output reg clk_metronome
);

// TODO

endmodule