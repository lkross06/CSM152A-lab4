`timescale 1ns / 1ps

module pmodAMP2_tb;

    //$dumpfile("audio_test.vcd"); // Names the output wave file
    //$dumpvars(0, audio_gen_tb);   // Dumps all variables in the testbench
    // Inputs
    reg i_clk;
    reg [3:0] i_sw;

    // Outputs
    wire o_shutdown_n;
    wire o_gain;
    wire o_audio;

    // Instantiate the Unit Under Test (UUT)
    pmodAMP2 uut (
        .i_clk(i_clk),
        .i_sw(i_sw),
        .o_shutdown_n(o_shutdown_n),
        .o_gain(o_gain),
        .o_audio(o_audio)
    );

    // 100 MHz Clock Generator (Period is 10ns -> toggles every 5ns)
    always begin
        #5 i_clk = ~i_clk;
    end

    initial begin
        // Initialize Inputs
        i_clk = 0;
        i_sw = 4'b0000; // Start muted

        // Wait 100 ns for global reset stabilization
        #100;
        
        // Turn on the 440 Hz (A4) switch
        $display("Testing A4 (440Hz) tone...");
        i_sw = 4'b0001;
        
        // Run simulation for 3 milliseconds to capture a few complete audio cycles
        // (A 440Hz wave repeats roughly every 2.27 milliseconds)
        #3000000; 

        // Change to Middle C switch
        $display("Testing Middle C (261.6Hz) tone...");
        i_sw = 4'b1000;
        #3000000;

        // Turn off switches (Mute)
        $display("Testing Mute...");
        i_sw = 4'b0000;
        #50000;

        $display("Simulation finished.");
        $finish;
    end
      
endmodule