module pmodAMP2 (
    input        i_clk,        // 100 MHz Master Clock
    input  [3:0] i_sw,         // Switches to change frequency
    output       o_shutdown_n,
    output       o_gain,
    output reg   o_audio       
);
    
    assign o_shutdown_n = 1'b1;
    assign o_gain = 1'b1; 
    
    parameter COUNTER_WIDTH = 32;
    localparam MSB = COUNTER_WIDTH-1;

    reg [COUNTER_WIDTH-1:0] step_size;
    reg [COUNTER_WIDTH-1:0] phase;

    // Formula used for 100 MHz clock: (Desired_Freq * 2^32) / 100,000,000
    always @(posedge i_clk) begin
        casez(i_sw)
            4'b1???: step_size <= 32'd11213;  // 261.6 Hz (Middle C)
            4'b01??: step_size <= 32'd12591;  // 293.7 Hz (D4)
            4'b001?: step_size <= 32'd14135;  // 329.6 Hz (E4)
            4'b0001: step_size <= 32'd18898;  // 440.0 Hz (A4)
            default: step_size <= 32'd0;      // Mute
        endcase
    end

    // Phase Accumulator
    always @(posedge i_clk) begin
        phase <= phase + step_size;
    end

    // Output Square Wave
    always @(posedge i_clk) begin
        o_audio <= phase[MSB];
    end

endmodule