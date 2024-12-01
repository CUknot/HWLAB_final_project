module uart_rx2 (
    input wire clk,              // Baud rate clock
    input wire reset,            // Reset signal
    input wire rx_in,            // UART serial input
    output reg [23:0] rx_data,   // Received UTF-8 data (max 3 bytes)
    output reg rx_ready         // Data ready signal
//    output reg [3:0] bit_counter, // Count bits (start, 8 data, stop)
//    output reg [7:0] rx_shift_reg, // Shift register for received byte
//    output reg [23:0] utf8_buffer, // Buffer to hold multi-byte character
//    output reg [1:0] utf8_byte_count, // Count bytes for UTF-8 sequence
//    output reg sampling,          // Sampling in progress
//    output reg write_data
);
    reg [3:0] bit_counter;        // Count bits (start, 8 data, stop)
    reg [7:0] rx_shift_reg;       // Shift register for received byte
    reg [23:0] utf8_buffer;       // Buffer to hold multi-byte character
    reg [1:0] utf8_byte_count;    // Count bytes for UTF-8 sequence
    reg sampling;                 // Sampling in progress
    reg write_data;               // Trigger data write to output

    // State machine to handle UART byte reception and UTF-8 sequence detection
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers on reset signal
            bit_counter <= 0;
            rx_shift_reg <= 0;
            utf8_buffer <= 0;
            utf8_byte_count <= 0;
            sampling <= 0;
            rx_ready <= 0;
            write_data <= 0;
        end else if (!sampling && !rx_in) begin
            // Detect the start of the UART frame (start bit)
            sampling <= 1;
            bit_counter <= 9; // 8 data bits + stop bit
            rx_ready <= 0;
            rx_shift_reg <= 0;
        end else if (sampling) begin
            if (bit_counter > 1) begin
                // Shift in bits from the UART input
                rx_shift_reg <= {rx_in, rx_shift_reg[7:1]}; 
            end else if (bit_counter == 1) begin
                // Process the last bit (stop bit)
                if (utf8_byte_count == 0) begin
                    // Start of a new UTF-8 sequence, analyze the first byte
                    if (rx_shift_reg[7:4] == 4'b1110) begin
                        utf8_byte_count <= 3; // 3-byte UTF-8 sequence
                    end else if (rx_shift_reg[7:5] == 3'b110) begin
                        utf8_byte_count <= 2; // 2-byte UTF-8 sequence
                    end else if (rx_shift_reg[7] == 1'b0) begin
                        utf8_byte_count <= 1; // 1-byte UTF-8 (ASCII)
                    end else begin
                        utf8_byte_count <= 0; // Invalid UTF-8
                    end
                    // Store the first byte in the buffer
                    utf8_buffer <= {8'b0, rx_shift_reg};
                end else begin
                    // Continuation byte(s)
                    if (rx_shift_reg[7:6] == 2'b10) begin
                        // Valid continuation byte, shift it into the buffer
                        utf8_buffer <= {utf8_buffer[15:0], rx_shift_reg};
                    end else begin
                        utf8_byte_count <= 0; // Invalid UTF-8 sequence
                    end
                end
                
                // Decrement byte count
                utf8_byte_count <= utf8_byte_count - 1;

                // If all expected bytes are received, signal data is ready
                if (utf8_byte_count == 0) begin
                    write_data <= 1;
                end
            end
            bit_counter <= bit_counter - 1;
            if (bit_counter == 1) begin
                // Stop sampling after the last bit (stop bit)
                sampling <= 0;
            end
        end else if (write_data) begin
            // Output the full UTF-8 data once all bytes are received
            rx_data <= utf8_buffer;
            rx_ready <= 1;
            write_data <= 0;
            utf8_byte_count <= 0;
            utf8_buffer <= 0; // Reset the buffer for the next sequence
        end
    end
endmodule
