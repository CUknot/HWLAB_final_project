module uart_tx (
    input wire clk,            // Baud rate clock (from clk_divider)
    input wire reset,          // Reset signal
    input wire [23:0] tx_data, // UTF-8 data to send (max 3 bytes)
    input wire tx_start,       // Start transmission signal
    output reg tx_busy,        // Busy signal
    output reg tx_out          // UART serial output
);
    reg [3:0] bit_counter;     // Count bits (start, 8 data, stop)
    reg [9:0] tx_shift_reg;    // Shift register (start + data + stop)
    reg [1:0] tx_byte_count;   // Byte count for UTF-8 sequence

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            tx_shift_reg <= 10'b1111111111; // Idle state
            tx_busy <= 0;
            tx_out <= 1;
            tx_byte_count <= 0;
        end else if (tx_start && !tx_busy) begin
            // Load start bit, first byte of data, and stop bit
            tx_shift_reg <= {1'b1, tx_data[7:0], 1'b0};
            tx_byte_count <= (tx_data[15:8] != 8'b0) ? 
                             ((tx_data[23:16] != 8'b0) ? 3 : 2) : 1;
            bit_counter <= 10;
            tx_busy <= 1;
        end else if (tx_busy) begin
            tx_out <= tx_shift_reg[0];
            tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}; // Shift bits out
            bit_counter <= bit_counter - 1;

            if (bit_counter == 0) begin
                if (tx_byte_count > 1) begin
                    // Load next byte of UTF-8 data
                    tx_byte_count <= tx_byte_count - 1;
                    tx_shift_reg <= {1'b1, 
                                     (tx_byte_count == 2) ? tx_data[15:8] : tx_data[23:16], 
                                     1'b0};
                    bit_counter <= 10;
                end else begin
                    tx_busy <= 0; // Done transmitting
                end
            end
        end
    end
endmodule
