/*
 * == Four-Digit Seven-Segment Controller Module ==
 * Takes current metronome BPM and displays it accordingly on the Basys 3 4-digit seven-segment LED display.
 *
 * Inputs:  bpm[7:0]        unsigned BCD, current metronome beats per minute [0, 255]
            mode            0 = normal (no display), 1 = metronome (display bpm). current mode of operation
            clk_fast        the clock signal for refreshing (500 Hz)
 *
 * Outputs: seg[6:0]        Represents the current state of the seven segments
            an[3:0]         Represents the "on switch" for each of the four digits
 */

module display (
    input [7:0] bpm,
    input mode,
    input clk_fast,
    output reg seg[6:0],
    output reg an[3:0]
);

// TODO: @lkross06

// NOTE: with 0-255 we never actually use the fourth (left-most) digit. that anode can stay 0 or not be mapped at all

endmodule