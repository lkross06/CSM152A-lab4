/*
 * == Clean Inputs ==
 * Take raw button / switch inputs and debounce + stabilize them
 *
 * Inputs:  clk_fast        500 Hz (lower freq for debouncing) clock input
 *          sw              switch input for mode switch
 *          btnL            left button input for decrease volume
 *          btnR            right button input for increase volume
 *          btnU            up button input for increase metronome
 *          btnD            down button input for decrease metronome
 *          btnKYPD[15:0]   16-bit input for each button on the keypad (0 = off, 1 = on)
 *
 * Outputs: mode            0 = normal, 1 = metronome. current mode of operation
 *          keypad[15:0]    0 = button off, 1 = button on for each button on the keypad
 *          volume_inc      0 = do not increment, 1 = increment volume once
 *          volume_dec      0 = do not decrement, 1 = decrement volume once
 *          metronome_inc   0 = do not incremnet, 1 = increment metronome (by delta_bpm) once
 *          metronome_dec   0 = do not decrement, 1 = decrement metronome (by delta_bpm) once
 */

module clean_inputs(
    input clk_fast,
    input sw0,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input [15:0] btnKYPD,
    output reg keypad[15:0],
    output reg volume_inc,
    output reg volume_dec,
    output reg metronome_inc,
    output reg metronome_dec
);

// TODO: @lemmons153 will need your help with this part

endmodule

