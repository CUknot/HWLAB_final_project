module uart_rx (
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
    reg [3:0] bit_counter; // Count bits (start, 8 data, stop)
    reg [7:0] rx_shift_reg; // Shift register for received byte
    reg [23:0] utf8_buffer; // Buffer to hold multi-byte character
    reg [1:0] utf8_byte_count; // Count bytes for UTF-8 sequence
    reg sampling ;
    reg write_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            rx_shift_reg <= 0;
            utf8_buffer <= 0;
            utf8_byte_count <= 0;
            sampling <= 0;
            rx_ready <= 0;
            write_data <= 0;
        end else if (!sampling && !rx_in) begin
            // Detect start bit
            sampling <= 1;
            bit_counter <= 9; // 8 data bits + stop bit
            rx_ready <= 0;
            rx_shift_reg <= 0;
            if (write_data) begin
                utf8_buffer <= 0;
                write_data <= 0;
                rx_data <= utf8_buffer;
                rx_ready <= 1;
                utf8_byte_count <= 0;
            end
        end else if (sampling) begin
            if (bit_counter > 1) begin
                rx_shift_reg <= {rx_in, rx_shift_reg[7:1]}; // Shift in bits
            end else if (bit_counter == 1) begin
                // End of byte
                if (utf8_byte_count == 0) begin
                    // Determine sequence start
                    if (rx_shift_reg[7:4] == 4'b1110) begin
                        utf8_byte_count = 3; // 3-byte sequence
                    end else if (rx_shift_reg[7:5] == 3'b110) begin
                        utf8_byte_count = 2; // 2-byte sequence
                    end else if (rx_shift_reg[7] == 1'b0) begin
                        utf8_byte_count = 1; // Single-byte ASCII
                    end else begin
                        utf8_byte_count = 0; // Invalid UTF-8
                    end
                    utf8_buffer <= {16'b0, rx_shift_reg };
                    
                end else begin
                    // Continuation bytes
                    if (rx_shift_reg[7:6] == 2'b10) begin
                        utf8_buffer = {utf8_buffer[15:0], rx_shift_reg};
                    end else begin
                        utf8_byte_count <= 0; // Invalid sequence
                    end
                end
                  if(utf8_byte_count == 1)begin
                    write_data<= 1;
                    end  
                utf8_byte_count = utf8_byte_count - 1;
            end
            bit_counter <= bit_counter - 1;
            if (bit_counter == 1 ) sampling <= 0;
        end else if (write_data) begin
                utf8_buffer <= 0;
                write_data <= 0;
                rx_data <= utf8_buffer;
                rx_ready <= 1;
                utf8_byte_count <= 0;
            end
    end
endmodule
