/*
 * == Clock Divider ==
 * Divide 100 MHz master clock into slower clocks as needed
 *
 * Inputs:  master_clk      100 MHz hardware clock square wave from pin V5
 *
 * Outputs: clk_fast        500 Hz square wave for debouncing inputs
 */

module clock_divider(
    input master_clk,    // 100 MHz from pin V5
    output reg clk_fast, // 500 Hz
);

// TODO

endmodule