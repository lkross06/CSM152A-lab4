/*
 * == pmodAMP2 ==
 * Interface with the pmodAMP2 audio amplifier (6-pin) on JC GPIO port
 *
 * Inputs:  ain             analog signal (e.g. "sound wave") to amplify
 * 
 * Outputs: JC[3:0]         GPIO pins from PmodKYPD input (top row only, pins 1-4. pins 5-6 are VCC/GND)
 */
module pmodAMP2 (
    input ain,
    output reg JC[3:0]
);

// TODO: @ElizaldeJoseCS

// NOTE: might be as simple as "assign JC[x] = ain;" not really sure

endmodule