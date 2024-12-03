`timescale 1ns/1ps

module uart_tx_tb;
    // Testbench Signals
    reg clk;
    reg reset;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_out;
    wire tx_busy;

    // Instantiate the Transmitter
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // Clock Generation (100 MHz system clock)
    always #5 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;
        tx_data = 8'h00;
        tx_start = 0;

        // Reset System
        #20;
        reset = 0;

        // Test Case 1: Transmit 8'hA5
        #20;
        tx_data = 8'hA5;  // Set data to transmit
        tx_start = 1;     // Pulse start signal
        #10;
        tx_start = 0;     // De-assert start

        // Wait for transmission to complete
        #200;

        // Test Case 2: Transmit 8'h3C
        tx_data = 8'h3C;
        tx_start = 1;
        #10;
        tx_start = 0;

        // Wait for transmission to complete
        #200;

        // End Simulation
        #1000;
        $stop;
    end
endmodule
