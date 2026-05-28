/*
 * == Four-Digit Seven-Segment Controller Module ==
 * Takes current metronome BPM and displays it accordingly on the Basys 3 4-digit seven-segment LED display.
 *
 * Inputs:  bpm[7:0]        unsigned BCD, current metronome beats per minute [0, 255]
            mode            0 = normal (no display), 1 = metronome (display bpm). current mode of operation
            clk_fast        the clock signal for refreshing (500 Hz)
 *
 * Outputs: seg[6:0]        Represents the current state of the seven segments
            an[3:0]         Represents the "on switch" for each of the four digits
 */

module display (
    input [7:0] bpm,
    input mode,
    input clk_fast,
    output reg [6:0] seg,
    output reg [3:0] an
);

    //convert to 3 digits (trailing zeroes okay for now, handled elsewhere)
    wire [3:0] bpm_thous, bpm_hunds, bpm_tens, bpm_ones;
    reg  [3:0] current_digit;
    reg  [1:0] refresh_counter = 0;

    assign bpm_thous = (bpm / 1000) % 10;
    assign bpm_hunds = (bpm / 100) % 10;
    assign bpm_tens  = (bpm / 10) % 10;
    assign bpm_ones  = bpm % 10;

    //express current anode
    always @(*) begin
        if (!mode) begin
            //in normal operation, do not use display at all
            current_digit = 4'd0;
            an = 4'b1111; //all digits are OFF
        end else begin
            case(refresh_counter)
                2'b11: begin
                    //actiavte digit 4 (NX XX)
                    current_digit = bpm_thous;
                    an = 4'b0111;
                end
                2'b10: begin
                    //activate digit 3 (XN XX)
                    current_digit = bpm_hunds;
                    an = 4'b1011;
                end
                2'b01: begin
                    //activate digit 2 (XX NX)
                    current_digit = bpm_tens;
                    an = 4'b1101;
                end
                2'b00: begin
                    //activate digit 1 (XX XN)
                    current_digit = bpm_ones;
                    an = 4'b1110;
                end
            endcase
        end
    end

    /*
    * encode segment mapping into binary
    *
    *        a (0)
    *       -------
    *   f  |       | b
    *   (5)|  g(6) | (1)
    *       -------
    *   e  |       | c
    *   (4)|       | (2)
    *       -------
    *        d (3)
    *
    * 0 = Segment ON, 1 = Segment OFF
    * seg = [g, f, e, d, c, b, a]
    */
    always @(*) begin
        case(current_digit)
            4'd0:
                seg = 7'b1000000;
            4'd1:
                seg = 7'b1111001;
            4'd2:
                seg = 7'b0100100;
            4'd3:
                seg = 7'b0110000;
            4'd4:
                seg = 7'b0011001;
            4'd5:
                seg = 7'b0010010;
            4'd6:
                seg = 7'b0000010;
            4'd7:
                seg = 7'b1111000;
            4'd8:
                seg = 7'b0000000;
            4'd9:
                seg = 7'b0010000;
            default:
                seg = 7'b1111111;
        endcase
    end

    //move to next anode
    always @(posedge clk_fast) begin
        refresh_counter <= refresh_counter + 1;
    end

endmodule