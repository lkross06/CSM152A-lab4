/*
 * == Volume ==
 * Takes inputs from volume inc/dec buttons, holds the current state of the volume. Sets the pins for volume LEDs.
 *
 * Inputs:  clk             master clock to update asynchronous inputs
 *          volume_inc      0 = do not increment, 1 = increment volume once
 *          volume_dec      0 = do not decrement, 1 = decrement volume once
 *
 * Outputs: volume[3:0]     unsigned BCD, current state of volume [0,15]. 1 = minimum volume, 16 = maximum volume
 *          muted           whether or not sound is expressed. 0 = volume > 0, 1 = muted / no volume / volume = 0
 *          led[15:0]       state of LEDs on Basys3 board. 0 = off, 1 = on for each LED. if muted = 1, led = 0
 */

module volume(
    input clk,
    input volume_inc,
    input volume_dec,
    output reg [3:0] volume, //NOTE: volume has 17 states (0, 1...16 makes 1 + 16 = 17 states). we represent "volume = 0" with muted = 1
    output reg muted,
    output reg [15:0] led
);

    reg old_inc = 0;
    reg old_dec = 0;

    //handle two async inputs trying to update the same register (volume / source of truth)
    always @(posedge clk) begin
        
        //similar to having two "always @ posedge inc/dec" blocks
        if (volume_inc && !old_inc) begin
            if (muted) begin
                muted  <= 1'b0;      //incrementing volume while muted restores audio
                volume <= 4'd0;      //starts back at the lowest audible step
            end else if (volume < 4'd15) begin
                volume <= volume + 1; //explicitly prevent overflow
            end
        end
        else if (volume_dec && !old_dec) begin
            if (!muted) begin
                if (volume == 4'd0) begin //this also explicitly prevents underflow
                    muted <= 1'b1;   //decrementing volume while at lowest audible step silences audio
                end else begin
                    volume <= volume - 1;
                end
            end
        end

        old_inc <= volume_inc;
        old_dec <= volume_dec;
    end

    //encode current volume level into LED pins
    always @(*) begin
        if (muted) begin
            led = 16'b0000_0000_0000_0000; //force all LEDs off when muted
        end else begin
            case(volume)
                4'd0:  led = 16'b0000_0000_0000_0001;
                4'd1:  led = 16'b0000_0000_0000_0011;
                4'd2:  led = 16'b0000_0000_0000_0111;
                4'd3:  led = 16'b0000_0000_0000_1111;
                4'd4:  led = 16'b0000_0000_0001_1111;
                4'd5:  led = 16'b0000_0000_0011_1111;
                4'd6:  led = 16'b0000_0000_0111_1111;
                4'd7:  led = 16'b0000_0000_1111_1111;
                4'd8:  led = 16'b0000_0001_1111_1111;
                4'd9:  led = 16'b0000_0011_1111_1111;
                4'd10: led = 16'b0000_0111_1111_1111;
                4'd11: led = 16'b0000_1111_1111_1111;
                4'd12: led = 16'b0001_1111_1111_1111;
                4'd13: led = 16'b0011_1111_1111_1111;
                4'd14: led = 16'b0111_1111_1111_1111; 
                4'd15: led = 16'b1111_1111_1111_1111;
                default: led = 16'b0000_0000_0000_0000;
            endcase
        end
    end

endmodule