`timescale 1ns/1ps

module clk_divider_tb;

    // Testbench Signals
    reg clk_in;     // 100 MHz input clock
    reg reset;      // Reset signal
    wire clk_out;   // Divided clock output

    // Instantiate the clk_divider module
    clk_divider uut (
        .clk_in(clk_in),
        .reset(reset),
        .clk_out(clk_out)
    );

    // Clock Generation (100 MHz system clock)
    always #5 clk_in = ~clk_in; // 100 MHz clock = 10 ns period

    initial begin
        // Initialize signals
        clk_in = 0;
        reset = 1;

        // Apply Reset
        #20;          // Wait for a bit to apply reset
        reset = 0;    // Deassert reset

        // Run the simulation for a period to observe clk_out
        #5000000;     // Run for enough time (about 5ms) to observe toggling
        $stop;        // Stop simulation after observing

    end
endmodule
