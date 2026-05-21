/*
 * == Volume ==
 * Takes inputs from volume inc/dec buttons, holds the current state of the volume. Sets the pins for volume LEDs.
 *
 * Inputs:  metronome_inc   0 = do not incremnet, 1 = increment metronome (by delta_bpm) once
 *          metronome_dec   0 = do not decrement, 1 = decrement metronome (by delta_bpm) once
 *
 * Outputs: volume[3:0]     unsigned BCD, current state of volume [0,15]. 0 = no volume / muted, 15 = maximum volume
 *          led[15:0]       state of LEDs on Basys3 board. 0 = off, 1 = on for each LED
 */

module volume(
    input volume_inc,
    input volume_dec,
    output reg volume[3:0],
    output reg led[15:0]
);

// TODO

endmodule