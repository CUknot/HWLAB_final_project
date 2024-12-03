`timescale 1ns/1ps

module uart_rx_tb;
    // Testbench Signals
    reg clk;         // Default 100 MHz clock
    reg reset;       // Reset signal
    reg rx_in;       // UART input signal
    wire [7:0] rx_data; // Received data
    wire rx_ready;   // Data ready signal
    wire clk_out;
    
    // Instantiate the UART Receiver
    clk_divider cdinstant(clk, clk_out);
    
    uart_rx uut (
        .clk(clk_out),
        .reset(reset),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Clock Generation (100 MHz system clock)
    always #5 clk = ~clk; // 100 MHz clock = 10 ns period

    // UART Bit Timing (calculated for 9600 baud rate)
    parameter BAUD_PERIOD = 10; // ~104.16 µs for 9600 Hz

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        rx_in = 1; // Idle state for UART (HIGH)

        // Apply Reset
        #20;
        reset = 0;

        // Manual Input Simulation: 8'hA5 (binary: 10100101)
        #100;
        rx_in = 0;  // Start bit
        #(BAUD_PERIOD); // Wait for 1 bit time

        rx_in = 1;  // Data bit 0 (LSB first)
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 1
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 2
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 3
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 4
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 5
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 6
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 7 (MSB)
        #(BAUD_PERIOD);

        rx_in = 1;  // Stop bit
        #(BAUD_PERIOD); // Wait for stop bit to complete

        // Wait for reception to complete
        #1000;

        // Manual Input Simulation: 8'h3C (binary: 00111100)
        #100;
        rx_in = 0;  // Start bit
        #(BAUD_PERIOD); // Wait for 1 bit time

        rx_in = 0;  // Data bit 0 (LSB first)
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 1
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 2
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 3
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 4
        #(BAUD_PERIOD);
        rx_in = 1;  // Data bit 5
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 6
        #(BAUD_PERIOD);
        rx_in = 0;  // Data bit 7 (MSB)
        #(BAUD_PERIOD);

        rx_in = 1;  // Stop bit
        #(BAUD_PERIOD); // Wait for stop bit to complete

        // Wait for reception to complete
        #200000;

        // End simulation
        #1000;
        $stop;
    end
endmodule
