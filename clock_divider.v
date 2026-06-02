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

    // Define counters here (size them based on terminal counts)
    reg [19:0] count_fast;

    // activate on the positive edge of the master clock or when reset is pressed
    always @(posedge master_clk) begin
        // Same logic for Fast Clock (500 Hz)
        if (count_fast == 19_999) begin
            count_fast <= 0;
            clk_fast <= ~clk_fast;
        end else begin
            count_fast <= count_fast + 1;
        end
    end

endmodule