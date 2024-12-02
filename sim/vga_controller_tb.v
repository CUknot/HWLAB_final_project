`timescale 1ns / 1ps

module vga_controller_tb;

// Inputs
reg clk_100MHz;
reg reset;

// Outputs
wire video_on;
wire hsync;
wire vsync;
wire p_tick;
wire [9:0] x;
wire [9:0] y;

// Instantiate the Unit Under Test (UUT)
vga_controller uut (
    .clk_100MHz(clk_100MHz),
    .reset(reset),
    .video_on(video_on),
    .hsync(hsync),
    .vsync(vsync),
    .p_tick(p_tick),
    .x(x),
    .y(y)
);

// Clock generation
initial begin
    clk_100MHz = 0;
    forever #5 clk_100MHz = ~clk_100MHz; // 100 MHz clock (10 ns period)
end

// Reset logic
initial begin
    reset = 1;
    #20 reset = 0; // Release reset after 20 ns
end

// Simulation control
initial begin
    // Open output file for logging
    $dumpfile("vga_controller_tb.vcd");
    $dumpvars(0, vga_controller_tb);

    // Run the simulation for a limited time
    #5000000; // Run for 5ms (5000000 ns)
    $stop;    // Stop simulation
end

// Monitor key signals
initial begin
    $monitor("%t: hsync=%b vsync=%b x=%d y=%d video_on=%b", 
             $time, hsync, vsync, x, y, video_on);
end

endmodule
