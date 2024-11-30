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
    reg clk;
    reg reset;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;
    wire tx_out;

    reg rx_in;
    wire [7:0] rx_data;
    wire rx_ready;

    // Instantiate TX and RX
    uart_tx_utf8 tx_inst (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_out(tx_out)
    );

    uart_rx_utf8 rx_inst (
        .clk(clk),
        .reset(reset),
        .rx_in(tx_out),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Generate Clock
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        tx_data = 8'h00;
        tx_start = 0;
        #20;
        reset = 0;

        // Send Thai character "ก" (UTF-8: E0 B8 81)
        #10 tx_data = 8'hE0; tx_start = 1; #10 tx_start = 0;
        wait (!tx_busy);  // Wait for previous byte to finish
        #10 tx_data = 8'hB8; tx_start = 1; #10 tx_start = 0;
        wait (!tx_busy);
        #10 tx_data = 8'h81; tx_start = 1; #10 tx_start = 0;

        // Wait for reception to complete
        #1000;
        $stop;
    end
endmodule