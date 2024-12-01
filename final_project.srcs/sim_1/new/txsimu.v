`timescale 1ns / 1ps

module tb_uart_tx;
    reg clk;               // Baud rate clock
    reg reset;             // Reset signal
    reg [7:0] tx_data;     // Data to transmit
    reg tx_start;          // Start signal for transmission
    wire tx_busy;          // Busy signal indicating ongoing transmission
    wire tx_out;           // UART output

    // Instantiate the UART Transmitter
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_out(tx_out)
    );

    // Clock generation (for baud rate)
    always #5 clk = ~clk; // 100 MHz clock (10 ns period)

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1; // Start with reset
        tx_data = 8'b0; // Clear data
        tx_start = 0;
        #100 reset = 0; // Release reset

        // Test Case 1: Send UTF-8 byte 0xE0 (first byte of 'ก')
        #100000;       // Wait 100 µs for stability
        tx_data = 8'hE0;
        tx_start = 1;  // Trigger transmission
        #10 tx_start = 0; // Deassert start

        // Wait for the transmission to complete
        wait (!tx_busy);

        // Test Case 2: Send UTF-8 byte 0xB8 (second byte of 'ก')
        #50000;        // Wait 50 µs before sending next byte
        tx_data = 8'hB8;
        tx_start = 1;  // Trigger transmission
        #10 tx_start = 0; // Deassert start

        // Wait for the transmission to complete
        wait (!tx_busy);

        // Test Case 3: Send UTF-8 byte 0x81 (third byte of 'ก')
        #50000;        // Wait 50 µs before sending next byte
        tx_data = 8'h81;
        tx_start = 1;  // Trigger transmission
        #10 tx_start = 0; // Deassert start

        // Wait for the transmission to complete
        wait (!tx_busy);

        // End simulation
        #200000;       // Wait 200 µs to observe final output
        $stop;
    end
endmodule
