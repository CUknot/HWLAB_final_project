module memory_array (
    input wire clk,
    input wire reset,
    input wire [23:0] data_in,      // 24-bit data to write (UTF-8 encoded Thai characters)
    input wire data_ready,          // Signal to indicate data is ready
    input wire [5:0] addr,          // 6-bit address: 2 bits for row, 4 bits for column
    output wire [23:0] data_out     // 24-bit data output from memory
);

    // Memory array declaration: 4 rows, each with 16 columns (24-bit per cell)
    reg [23:0] memory_array [3:0][15:0];  // 4 rows, each with 16 columns
    reg [1:0] row;                       // Row pointer
    reg [3:0] col;                       // Column pointer
    reg data_in_progress;                // Flag to track if data is currently being written
    integer i, j;

    // Output logic: Select based on 6-bit address (2 MSBs for row, 4 LSBs for column)
    assign data_out = memory_array[addr[5:4]][addr[3:0]];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset memory and cursor
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin
                    memory_array[i][j] <= 24'h000000;  // Clear all memory
                end
            end
            row <= 0;   // Reset row pointer
            col <= 0;   // Reset column pointer
        end else begin
            if (data_ready && !data_in_progress) begin
                data_in_progress <= 1;

                case (data_in)
                    8'h7F: begin  // Backspace (DEL)
                        if (col > 0) begin
                            // Delete the previous character in the current row
                            col <= col - 1;
                            memory_array[row][col] <= 24'h000000;
                        end else if (row > 0) begin
                            // Move to the last character of the previous row
                            row <= row - 1;
                            col <= 15;
                            while (col > 0 && memory_array[row][col - 1] == 24'h000000) begin
                                col <= col - 1;
                            end
                            memory_array[row][col] <= 24'h000000;  // Clear the character
                        end
                    end
                    
                    8'h0D: begin  // Enter key
                        // Move to the next row
                        if (row < 3) begin
                            row <= row + 1;
                            col <= 0;  // Reset column to 0
                        end else begin
                            // If already on the last row, shift rows up
                            for (i = 1; i < 4; i = i + 1) begin
                                for (j = 0; j < 16; j = j + 1) begin
                                    memory_array[i - 1][j] <= memory_array[i][j];
                                end
                            end

                            // Clear the last row
                            for (j = 0; j < 16; j = j + 1) begin
                                memory_array[3][j] <= 24'h000000;
                            end

                            // Keep cursor on the last row
                            row <= 3;
                            col <= 0;
                        end
                    end

                    default: begin  // Any other character
                        memory_array[row][col] <= data_in;
                        col <= col + 1;

                        // Check if column limit is reached
                        if (col == 16) begin
                            col <= 0;  // Reset column to 0
                            row <= row + 1;  // Move to the next row

                            // Check if row limit is reached
                            if (row == 4) begin
                                // Shift all rows up
                                for (i = 1; i < 4; i = i + 1) begin
                                    for (j = 0; j < 16; j = j + 1) begin
                                        memory_array[i - 1][j] <= memory_array[i][j];
                                    end
                                end

                                // Clear the last row
                                for (j = 0; j < 16; j = j + 1) begin
                                    memory_array[3][j] <= 24'h000000;
                                end

                                row <= 3;  // Keep cursor at the last row
                                col <= 0;  // Reset column to 0
                            end
                        end
                    end
                endcase
            end else if (!data_ready && data_in_progress) begin
                data_in_progress <= 0;  // Reset flag
            end
        end
    end

endmodule
