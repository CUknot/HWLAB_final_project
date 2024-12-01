`timescale 1ns / 1ps

module tb_uart_system;
    reg clk;
    reg btnC;
    reg RsRx;
    wire RsTx;
    wire rx_ready;
    wire tx_busy;
    wire [13:0] utf8_data;

    // Instantiate the UART System
    uart_system uut (
        .clk(clk),
        .btnC(btnC),
        .RsRx(RsRx),
        .RsTx(RsTx),
        .rx_ready(rx_ready),
        .tx_busy(tx_busy),
        .utf8_data(utf8_data)
    );

    // Clock generation
    always #52080 clk = ~clk; // 100 MHz clock (10 ns period)

    // Task to send a byte over RsRx
    task send_byte(input [7:0] byte);
        integer i;
        begin
            RsRx = 0; // Start bit
            #104160; // 9600 baud rate, bit duration = 104.16 µs
            for (i = 0; i < 8; i = i + 1) begin
                RsRx = byte[i];
                #104160;
            end
            RsRx = 1; // Stop bit
            #104160;
        end
    endtask

    initial begin
        // Initialize signals
        clk = 0;
        btnC = 1; // Reset
        RsRx = 1; // Idle state
        #100 btnC = 0; // Release reset

        // Send UTF-8 Thai character 'ก' = 0xE0 0xB8 0x81
        #100000;
        send_byte(8'hE0); // Send first byte
        send_byte(8'hB8); // Send second byte
        send_byte(8'h81); // Send third byte

        // Wait for processing
        #1000000;

        // End simulation
        $stop;
    end
endmodule
