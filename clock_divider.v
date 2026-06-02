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
    output reg clk_fast  // 500 Hz
);

    reg [25:0] count_fast;

    always @(posedge master_clk) begin
    //count to 100,000 then reset for a 500Hz clock
    if (count_fast == 99_999) begin
        count_fast <= 0;
        clk_fast <= ~clk_fast;
    end else begin
        count_fast <= count_fast + 1;
    end
end

endmodule