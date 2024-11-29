module uart_rx (
    input wire clk,           // Baud rate clock
    input wire reset,         // Reset signal
    input wire rx_in,         // UART serial input
    output reg [7:0] rx_data, // Received data
    output reg rx_ready       // Data ready signal
);
    reg [3:0] bit_counter;    // Count bits (start, 8 data, stop)
    reg [7:0] rx_shift_reg;   // Shift register for received data
    reg sampling;             // Sampling in progress

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            rx_shift_reg <= 0;
            sampling <= 0;
            rx_ready <= 0;
        end else if (!sampling && !rx_in) begin
            // Detect start bit
            sampling <= 1;
            bit_counter <= 9; // 8 data bits + stop bit
            rx_ready <= 0;
        end else if (sampling) begin
            if (bit_counter > 1) begin
                rx_shift_reg <= {rx_in, rx_shift_reg[7:1]}; // Shift in bits
            end else if (bit_counter == 1) begin
                rx_ready <= 1; // Data ready after stop bit
                rx_data <= rx_shift_reg;
            end
            bit_counter <= bit_counter - 1;
            
            if (bit_counter == 0) sampling <= 0;
        end
    end
endmodule
