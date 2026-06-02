/*
 * == Metronome ==
 * Takes inputs from metronome inc/dec buttons, holds current state of the metronome BPM [0, 255]. Generates a square wave at that BPM
 *
 * Inputs:  clk_fast        500Hz square wave clock to be divided into metronome clock
 *          metronome_inc   0 = do not incremnet, 1 = increment metronome (by delta_bpm) once
 *          metronome_dec   0 = do not decrement, 1 = decrement metronome (by delta_bpm) once
 *          delta_bpm[3:0]  unsigned BCD, amount (0 <= delta_bpm <= 15) to change your BPM by on inc/dec
 *          mode            0 = normal, 1 = metronome. inc/dec should only take effect in metronome mode
 *
 * Outputs: bpm[7:0]        beats per minute of metronome as unsigned BCD [0, 255] (for display)
 *          clk_metronome   square wave representing current metronome. METRONOME SHOULD "PULSE" ON SQUARE WAVE CHANGE (so BPM != clock frequency)
 */

module metronome(
    input clk_fast,
    input metronome_inc,
    input metronome_dec,
    input [3:0] delta_bpm,        
    input mode,
    output reg [7:0] bpm,         
    output reg clk_metronome
);

    // Default configuration, the first time mode is switched bpm = 120
    initial begin
        bpm = 8'd120;             
        clk_metronome = 1'b0;
    end

    // bpm increment logic (boundaries [1, 255])
    // bpm caps at 255 and at 1 no overflow allowed
    always @(posedge clk_fast) begin
        if (mode == 1'b1) begin   // Changes only allowed when in metronome mode
            if (metronome_inc) begin
                // Check for addition overflow
                if ((8'd255 - bpm) < delta_bpm) begin
                    bpm <= 8'd255; // Cap at max
                end else begin
                    bpm <= bpm + delta_bpm;
                end
            end else if (metronome_dec) begin
                // Check for subtraction overflow
                if ((bpm - 8'd1) < delta_bpm) begin
                    bpm <= 8'd1;   // Cap at min
                end else begin
                    bpm <= bpm - delta_bpm;
                end
            end
        end
    end

    // Clock cycles per minute = 500 Hz * 60 seconds = 30,000 cycles.
    // Total cycles for one beat = 30,000 / BPM.
    
    reg [15:0] cycle_counter = 16'b0;
    wire [15:0] target_cycles;
    
    assign target_cycles = (16'd30000 / bpm);

    always @(posedge clk_fast) begin
        if (mode == 1'b0) begin
            cycle_counter <= 16'b0;
            clk_metronome <= 1'b0;
        end else begin
            if (cycle_counter >= (target_cycles - 1'b1)) begin
                cycle_counter <= 16'b0;
            end else begin
                cycle_counter <= cycle_counter + 1'b1;
            end

            // Generates a quick ~40ms tone burst (20 clk_fast cycles) right 
            // at the start of each metronome interval. 
            if (cycle_counter < 16'd20) begin
                clk_metronome <= ~clk_metronome; 
            end else begin
                clk_metronome <= 1'b0; // quiet
            end
        end
    end

endmodule