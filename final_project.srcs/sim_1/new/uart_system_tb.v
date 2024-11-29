`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 08:19:53 PM
// Design Name: 
// Module Name: uart_system_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_system_tb;
    reg clk_100mhz;             // 100 MHz clock
    reg reset;                  // Reset signal
    reg [7:0] tx_data;          // Data to transmit
    reg tx_start;               // Start transmission
    reg rx_in;                  // Serial input for RX
    wire tx_out;                // Serial output from TX
    wire [7:0] rx_data;         // Received data
    wire rx_ready;              // Data ready signal

    // Instantiate the UART system
    uart_system uut (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Clock generation (100 MHz)
    always #5 clk_100mhz = ~clk_100mhz;

    initial begin
        // Initialize inputs
        clk_100mhz = 0;
        reset = 1;
        tx_data = 8'b0;
        tx_start = 1;
        #10 tx_start = 0;
        rx_in = 1;              // Idle state for UART

        // Reset the system
        #20 reset = 0;

        // Transmit a byte (0xA5)
        #40 tx_data = 8'hA5;
        tx_start = 1;
        #10 tx_start = 0;

        // Simulate RX receiving the same byte
        #100000 rx_in = 0;      // Start bit
        #104160 rx_in = 1;      // Bit 0
        #104160 rx_in = 0;      // Bit 1
        #104160 rx_in = 1;      // Bit 2
        #104160 rx_in = 0;      // Bit 3
        #104160 rx_in = 1;      // Bit 4
        #104160 rx_in = 0;      // Bit 5
        #104160 rx_in = 1;      // Bit 6
        #104160 rx_in = 0;      // Bit 7
        #104160 rx_in = 1;      // Stop bit
        #104160 rx_in = 1;      // Idle state

        // Wait for RX to process
        #200000;

        $stop; // End simulation
    end
endmodule
