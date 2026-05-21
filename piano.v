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
 *          an[3:0]         "on switch" for each of the three used digits (0 = on, 1 = off)
 */
 module piano (
    input master_clk,
    input sw,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input [7:0] JA,
    output [15:0] led,
    output [3:0] JC,
    output [6:0] seg,
    output [2:0] an,
 );

 // TODO

 endmodule