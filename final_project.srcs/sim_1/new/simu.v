`timescale 1ns / 1ps

module uart_system_tb;

    // Testbench signals
    reg clk;                    // Clock signal
    reg btnC;                   // Reset button
    reg RsRx;                   // UART Receive data (from terminal)
    wire RsTx;                  // UART Transmit data (to terminal)
    wire [6:0] seg;             // 7-segment display segments
    wire dp;                    // 7-segment decimal point
    wire [3:0] an;              // 7-segment display anode signals
    wire rx_ready;              // UART Receive ready signal
    wire tx_start;              // UART Transmit start signal
    wire [15:0] utf8_data;      // Data to be transmitted/received

    // Instantiate the uart_system
    uart_system uut (
        .clk(clk),
        .btnC(btnC),
        .RsRx(RsRx),
        .RsTx(RsTx),
        .seg(seg),
        .dp(dp),
        .an(an),
        .rx_ready(rx_ready),
        .tx_start(tx_start),
        .utf8_data(utf8_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock (10ns period)
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        btnC = 1;          // Start with reset active
        RsRx = 1;          // Initially idle state for RsRx
        #100;              // Wait for initial conditions to settle

        // Deassert reset
        btnC = 0;
        #10;               // Wait for clock to settle

        // Test Case 1: Send an ASCII character (e.g., 'A') to UART
        send_uart_data(8'h41);  // 'A' in ASCII
        #20000;                 // Wait for transmission to finish

        // Test Case 2: Send a UTF-8 character (e.g., Euro sign '€' -> 0xE2 0x82 0xAC)
        send_uart_data(8'hE2);  // First byte of UTF-8 Euro symbol
        send_uart_data(8'h82);  // Second byte of UTF-8 Euro symbol
        send_uart_data(8'hAC);  // Third byte of UTF-8 Euro symbol
        #20000;                 // Wait for transmission to finish

        // End of simulation
        $stop;
    end

    // Task to send a byte of data over UART
    task send_uart_data(input [7:0] data);
        begin
            RsRx = 0;  // Start bit (active low)
            #10416;    // Wait for bit period (9600 baud)

            // Send data byte (LSB first)
            RsRx = data[0]; #10416;
            RsRx = data[1]; #10416;
            RsRx = data[2]; #10416;
            RsRx = data[3]; #10416;
            RsRx = data[4]; #10416;
            RsRx = data[5]; #10416;
            RsRx = data[6]; #10416;
            RsRx = data[7]; #10416;

            RsRx = 1;  // Stop bit (idle high)
            #10416;    // Wait for stop bit period (9600 baud)
        end
    endtask

    // Monitor output signals for debugging
    initial begin
        $monitor("Time: %0t | RsRx: %b | RsTx: %b | rx_ready: %b | tx_start: %b | utf8_data: %h | seg: %b | dp: %b | an: %b",
                 $time, RsRx, RsTx, rx_ready, tx_start, utf8_data, seg, dp, an);
    end

endmodule
