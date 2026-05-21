/*
 * == pmodKYPD ==
 * Interface with the pmodKYPD 16-button keypad (12-pin) on JA GPIO port
 *
 * Inputs:  JA[7:0]         GPIO pins from PmodKYPD input
 * 
 * Outputs: btnKYPD[15:0]   16-bit input for each button on the keypad (0 = off, 1 = on)
 */
 module pmodKYPD (
    input [7:0] JA,
    output reg btnKYPD[15:0]
 );

 // TODO

 endmodule