
    
    module audio_gen (
    input        i_clk,        // 100 MHz Master Clock
    input  [3:0] i_sw,         // Switches to change frequency
    output       o_shutdown_n,
    output       o_gain,
    output reg   o_audio       // Changed to reg because we drive it in an always block
);
    
    parameter [7:0] THRESHOLD = (8'h88);
	reg	[31:0]	counter;
	assign o_shutdown_n = 1'b1;
    assign o_gain = 1'b1; 
    parameter	COUNTER_WIDTH = 32;
	localparam	MSB = COUNTER_WIDTH-1;
	parameter STEP_SIZE = (1<<(COUNTER_WIDTH)) * 440/(10000000); //100 MHz master clock

	// Reg to hold our dynamic step size (tuning word)
    reg [COUNTER_WIDTH-1:0] step_size;
    reg [COUNTER_WIDTH-1:0] phase;

    // Switch logic: Assigns a specific STEP_SIZE depending on the switch pressed
    // Formula used: (Desired_Freq * 2^32) / 50,000,000
    always @(posedge i_clk) begin
        casez(i_sw)
            4'b1???: step_size <= 32'd22426;  // 261.6 Hz (Middle C)
            4'b01??: step_size <= 32'd25181;  // 293.7 Hz (D4)
            4'b001?: step_size <= 32'd28269;  // 329.6 Hz (E4)
            4'b0001: step_size <= 32'd37795;  // 440.0 Hz (A4)
            default: step_size <= 32'd0;      // Mute
        endcase
    end

    // Phase Accumulator
    always @(posedge i_clk) begin
        phase <= phase + step_size;
    end

    // Output the Most Significant Bit to create a perfect square wave
    always @(posedge i_clk) begin
        o_audio <= phase[MSB];
    end

endmodule