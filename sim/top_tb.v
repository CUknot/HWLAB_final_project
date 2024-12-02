`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg clk;          // Clock
    reg reset;        // Reset signal

    // Outputs
    wire hsync;       // Horizontal sync signal
    wire vsync;       // Vertical sync signal
    wire [11:0] rgb;  // RGB output

    // File handle for writing simulation data
    integer file;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb),
        .w_p_tick(p_tick)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period -> 100MHz
    end

    // Testbench stimulus
    initial begin
        // Open the file for writing
        file = $fopen("simulation_output.txt", "w");
        if (file == 0) begin
            $display("Error: Failed to open file for writing.");
            $stop;
        end

        // Initialize inputs
        reset = 1;   // Start with reset active
        #20;         // Wait 20ns

        reset = 0;   // Deactivate reset
        #100000000;     // Run simulation for a while

        // Close the file
        $fclose(file);
        $stop;       // Stop the simulation
    end

    // Monitor and write output to file
    reg [3:0] red, green, blue;
    always @(posedge p_tick) begin
        // Extract RGB components: Red (rgb[11:8]), Green (rgb[7:4]), Blue (rgb[3:0])
        red = rgb[11:8];
        green = rgb[7:4];
        blue = rgb[3:0];

        // Write output in the format: current_sim_time hs vs red green blue
        $fwrite(file, "%0dns: %b %b %03b %03b %03b\n", 
                $time, hsync, vsync, red, green, blue);
    end

endmodule
