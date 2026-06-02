/*
 * == Clean Inputs ==
 * Take raw button / switch inputs and debounce + stabilize them
 *
 * Inputs:  clk_fast        500 Hz (lower freq for debouncing) clock input
 *          sw              switch input for mode switch
 *          btnL            left button input for decrease volume
 *          btnR            right button input for increase volume
 *          btnU            up button input for increase metronome
 *          btnD            down button input for decrease metronome
 *          btnKYPD[15:0]   16-bit input for each button on the keypad (0 = off, 1 = on)
 *
 * Outputs: mode            0 = normal, 1 = metronome. current mode of operation
 *          keypad[15:0]    0 = button off, 1 = button on for each button on the keypad
 *          volume_inc      0 = do not increment, 1 = increment volume once
 *          volume_dec      0 = do not decrement, 1 = decrement volume once
 *          metronome_inc   0 = do not incremnet, 1 = increment metronome (by delta_bpm) once
 *          metronome_dec   0 = do not decrement, 1 = decrement metronome (by delta_bpm) once
 */

module clean_inputs(
    input clk_fast,
    input sw0,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input [15:0] btnKYPD,
    output reg mode,
    output reg volume_dec,
    output reg volume_inc,
    output reg metronome_inc,
    output reg metronome_dec,
    output reg keypad[15:0]
);

    // Synchronizer flip-flops to bring asynchronous button inputs into the clk_fast domain
    reg [4:0] sync0 = 5'b0;
    reg [4:0] sync1 = 5'b0;

    // Shift registers to hold the history of each button's state for debouncing
    reg [3:0] shift_L   = 4'b0;
    reg [3:0] shift_R   = 4'b0;
    reg [3:0] shift_U   = 4'b0;
    reg [3:0] shift_D   = 4'b0;
    reg [3:0] shift_sw0 = 4'b0;

    // Debounced and stable button states
    reg db_L   = 1'b0;
    reg db_R   = 1'b0;
    reg db_U   = 1'b0;
    reg db_D   = 1'b0;
    reg db_sw0 = 1'b0;

    // everything but the keypad
    always @(posedge clk_fast) begin
        // Dual flip-flop synchronizer
        sync0 <= {sw0, btnD, btnU, btnR, btnL};
        sync1 <= sync0;

        // update shift registers to poll each 2ms (500 Hz)
        shift_L   <= {shift_L[2:0],   sync1[0]};
        shift_R   <= {shift_R[2:0],   sync1[1]};
        shift_U   <= {shift_U[2:0],   sync1[2]};
        shift_D   <= {shift_D[2:0],   sync1[3]};
        shift_sw0 <= {shift_sw0[2:0], sync1[4]};

        // If history is all 1s -> Button is firmly pressed. All 0s -> Released.
        if (shift_L == 4'b1111)   db_L <= 1'b1; else if (shift_L == 4'b0000)   db_L <= 1'b0;
        if (shift_R == 4'b1111)   db_R <= 1'b1; else if (shift_R == 4'b0000)   db_R <= 1'b0;
        if (shift_U == 4'b1111)   db_U <= 1'b1; else if (shift_U == 4'b0000)   db_U <= 1'b0;
        if (shift_D == 4'b1111)   db_D <= 1'b1; else if (shift_D == 4'b0000)   db_D <= 1'b0;
        if (shift_sw0 == 4'b1111) db_sw0 <= 1'b1; else if (shift_sw0 == 4'b0000) db_sw0 <= 1'b0;
    
        // Update outputs based on debounced button states
        volume_dec    <= db_L;
        volume_inc    <= db_R;
        metronome_inc <= db_U;
        metronome_dec <= db_D;
        mode <= db_sw0;
    end

    // loop variable for the keypad
    integer  i;
    reg [15:0] kypd_sync0 = 16'b0;
    reg [15:0] kypd_sync1 = 16'b0;
    
    // Array of 4-bit shifters for all 16 keys
    // 4 bits = 8ms of history at 500Hz sampling rate
    // in words theres 4 bits of history for each of the 16 buttons
    reg [3:0] kypd_shift [15:0];

    // initialize the array
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            kypd_shift[i] = 4'b0;
        end
    end

    always @(posedge clk_fast) begin
        // same dual flip-flop synchronizer
        kypd_sync0 <= btnKYPD;
        kypd_sync1 <= kypd_sync0;

        // Debounce every button independently using a loop
        for (i = 0; i < 16; i = i + 1) begin
            kypd_shift[i] <= {kypd_shift[i][2:0], kypd_sync1[i]};
            
            if (kypd_shift[i] == 4'b1111) begin
                keypad[i] <= 1'b1;
            end else if (kypd_shift[i] == 4'b0000) begin
                keypad[i] <= 1'b0;
            end
        end
    end

    
endmodule

