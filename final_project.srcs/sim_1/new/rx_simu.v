`timescale 1ns / 1ps

module tb_uart_rx;
    reg clk;
    reg reset;
    reg rx_in;              // UART input
    wire [23:0] rx_data;    // Received UTF-8 data
    wire rx_ready;          // Data ready signal

    // Instantiate the UART Receiver
    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Clock generation (for baud rate)
    always #52080 clk = ~clk; // 100 MHz clock (10 ns period)

    // Task to simulate UART transmission
    task send_byte(input [7:0] byte);
        integer i;
        begin
            rx_in = 0; // Start bit
            #104160;   // 9600 baud rate: 104.16 µs per bit
            for (i = 0; i < 8; i = i + 1) begin
                rx_in = byte[i];
                #104160; // Data bits
            end
            rx_in = 1; // Stop bit
            #104160;   // Stop bit time
        end
    endtask

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1; // Start with reset
        rx_in = 1; // Idle state for UART (line high)
        #100 reset = 0; // Release reset

        // Test Case 1: Send UTF-8 Thai character 'ก' (0xE0 0xB8 0x81)
        #100000; // Wait 100 µs for stability
        send_byte(8'h41); // First byte of UTF-8
//        send_byte(8'hB8); // Second byte of UTF-8
//        send_byte(8'h81); // Third byte of UTF-8

        // Wait for processing
        #2000000; // 2 ms to allow the receiver to process all bytes

        // End simulation
        $stop;
    end
endmodule
