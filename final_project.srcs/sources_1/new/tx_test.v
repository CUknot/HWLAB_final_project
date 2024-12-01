module uart_tx2 (
    input wire clk,        // Baud rate clock (from clk_divider)
    input wire reset,      // Reset signal
    input wire [23:0] tx_data, // UTF-8 data to send (max 3 bytes)
    input wire tx_start,   // Start transmission signal
    output reg tx_busy,    // Busy signal
    output reg tx_out      // UART serial output
);
    reg [3:0] bit_counter;    // Count bits (start, 8 data, stop)
    reg [9:0] tx_shift_reg;   // Shift register (start + data + stop)
    reg [1:0] tx_byte_count;  // Byte count for UTF-8 sequence

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            tx_shift_reg <= 10'b1111111111;  // Idle state (high)
            tx_busy <= 0;
            tx_out <= 1;  // Idle state is high
            tx_byte_count <= 0;
        end else if (tx_start && !tx_busy) begin
            // Start transmission: load the first byte and prepare for shifting
            tx_shift_reg <= {1'b0, tx_data[23:16], 1'b1};  // Start bit (0), first byte, stop bit (1)
            tx_byte_count <= (tx_data[15:8] != 8'b0) ? (tx_data[7:0] != 8'b0 ? 3 : 2) : 1;
            bit_counter <= 10;  // 10 bits: 1 start, 8 data, 1 stop
            tx_busy <= 1;
        end else if (tx_busy) begin
            tx_out <= tx_shift_reg[0];  // Output the LSB of tx_shift_reg
            tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};  // Shift bits to the right, inserting idle (1) bit
            bit_counter <= bit_counter - 1;

            if (bit_counter == 0) begin
                if (tx_byte_count > 1) begin
                    // Load the next byte of UTF-8 data
                    tx_byte_count <= tx_byte_count - 1;
                    case (tx_byte_count)
                        2: tx_shift_reg <= {1'b0, tx_data[15:8], 1'b1};  // Start bit (0), second byte, stop bit (1)
                        3: tx_shift_reg <= {1'b0, tx_data[7:0], 1'b1};  // Start bit (0), third byte, stop bit (1)
                    endcase
                    bit_counter <= 10;  // Reset bit counter for next byte
                end else begin
                    tx_busy <= 0;  // Done transmitting
                end
            end
        end
    end
endmodule
