/*
 * == pmodKYPD ==
 * Interface with the pmodKYPD 16-button keypad (12-pin) on JA GPIO port
 *
 * Inputs:  clk_fast        500Hz clock refresh rate for scanning + multiplexing on each row
 *          JA[7:0]         GPIO pins from PmodKYPD input (see pinout below)
 *
 * Outputs: btnKYPD[15:0]   16-bit input for each button on the keypad (0 = off, 1 = on)
 */
module pmodKYPD (
    input clk_fast,
    inout [7:0] JA, //we treat rows as inputs but columns as outputs (since we write to them to drive them HIGH/LOW)
    output reg [15:0] btnKYPD
);

    //THIS IMPLEMENTATION IS ADAPTED FROM DILIGENT EXAMPLE CODE FOR THE PMODKYPD DEVICE
    //https://digilent.com/reference/pmod/pmodkypd/start#example_projects

    /*
     * PmodKYPD Pinout
     *
     * If a row pin reads LOW, at least one button in that row is pressed
     * If a column pin reads LOW, at least one button in that column is pressed
     * * WIRE     PIN     SIGNAL
     * ============================
     * JA[0]    1       Column 4
     * JA[1]    2       Column 3
     * JA[2]    3       Column 2
     * JA[3]    4       Column 1
     * JA[4]    7       Row 4
     * JA[5]    8       Row 3
     * JA[6]    9       Row 2
     * JA[7]    10      Row 1
     *
     *      C1  C2  C3  C4
     * R1   1   2   3   A
     * R2   4   5   6   B
     * R3   7   8   9   C
     * R4   0   F   E   D
     *
     */
   
    //We use a similar method to the seven-segment display where we cycle through each column, driving them low and checking the rows
    //  The columns are analogous to the anodes of each digit, and the rows are analogous to the segments of each digit
    //  However, since the pull-down lines are shared, buttons inputs may affect others-- we assign a up-to-down priority to the buttons to solve this
    //  Not ideal but no great workarounds for this device
    reg [1:0] step = 2'b00;
    reg [3:0] col_drive;

    assign JA[3:0] = col_drive;
    assign JA[7:4] = 4'bzzzz;

    //refresh column first
    always @(negedge clk_fast) begin
        step <= step + 1'b1;

        //cycle through and drive columns LOW one-by-one to check rows
        case (step)
            2'b00: col_drive <= 4'b0111;
            2'b01: col_drive <= 4'b1011;
            2'b10: col_drive <= 4'b1101;
            2'b11: col_drive <= 4'b1110;
        endcase
    end

    //wait 1ms for columns to settle, then check each row
    always @(posedge clk_fast) begin
        case (step)
            2'b01: begin //C1
                //if multiple rows are low, use fixed priority to handle (the actual order is arbitrary)
                btnKYPD[0]  <= ~JA[7];                                          //1
                btnKYPD[4]  <= ~JA[7] ? 1'b0 : ~JA[6];                          //4
                btnKYPD[7]  <= (~JA[7] || ~JA[6]) ? 1'b0 : ~JA[5];              //7
                btnKYPD[12] <= (~JA[7] || ~JA[6] || ~JA[5]) ? 1'b0 : ~JA[4];    //0
            end
           
            2'b10: begin //C2
                btnKYPD[1]  <= ~JA[7];                                          //2
                btnKYPD[5]  <= ~JA[7] ? 1'b0 : ~JA[6];                          //5
                btnKYPD[8]  <= (~JA[7] || ~JA[6]) ? 1'b0 : ~JA[5];              //8
                btnKYPD[13] <= (~JA[7] || ~JA[6] || ~JA[5]) ? 1'b0 : ~JA[4];    //F
            end
           
            2'b11: begin //C3
                btnKYPD[2]  <= ~JA[7];                                          //3
                btnKYPD[6]  <= ~JA[7] ? 1'b0 : ~JA[6];                          //6
                btnKYPD[9]  <= (~JA[7] || ~JA[6]) ? 1'b0 : ~JA[5];              //9
                btnKYPD[14] <= (~JA[7] || ~JA[6] || ~JA[5]) ? 1'b0 : ~JA[4];    //E
            end
           
            2'b00: begin //C4
                btnKYPD[3]  <= ~JA[7];                                          //A
                btnKYPD[10] <= ~JA[7] ? 1'b0 : ~JA[6];                          //B
                btnKYPD[11] <= (~JA[7] || ~JA[6]) ? 1'b0 : ~JA[5];              //C
                btnKYPD[15] <= (~JA[7] || ~JA[6] || ~JA[5]) ? 1'b0 : ~JA[4];    //D
            end
        endcase
    end

   

endmodule