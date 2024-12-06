`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 08:42:50 PM
// Design Name: 
// Module Name: buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module memory_array (
    input wire clk,
    input wire reset,
    input wire [23:0] data_in,      // 7-bit data to write
    input wire data_ready,         // Signal to indicate data is ready
    input wire [5:0] addr,         // 6-bit address (2 bits for row, 4 bits for column)
    output wire [23:0] data_out     // 7-bit data output from memory
);

    // Memory array declaration: 4 buffers for 4 rows, each with 32 columns (total 128 locations)
    reg [23:0] memory_array [3:0][15:0];  // 4 rows, each with 32 columns
    reg data_in_progress;               // Flag to track if data is currently being written
    integer i, j ,col ,row, c;
    reg found;
    // Output logic: Reading data from the memory based on the address
    assign data_out = memory_array[addr[5:4]][addr[3:0]]; // Use the top 2 bits for row and the bottom 5 for column

    // Process the data input and manage the memory write and row shifts
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the memory to zero
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    memory_array[i][j] <= 7'b0;  // Clear all entries
                end
            end
            row <= 0;  // Reset cursor row
            col <= 0;  // Reset cursor column
            data_in_progress <= 0;
        end else begin
            if (data_ready && !data_in_progress) begin
                data_in_progress <= 1;
                case (data_in) 
                    8'h0D: begin
                        // Handle Enter key
                        if (row < 3) begin
                            row <= row + 1;
                            col <= 0;  // Reset column to 0
                        end else begin
                            // Shift lines up when at the last row
                            for (row = 1; row < 4; row = row + 1) begin
                                for (col = 0; col < 16; col = col + 1) begin
                                    memory_array[row - 1][col] <= memory_array[row][col];
                                end
                            end
                            // Clear the last row
                            for (col = 0; col < 16; col = col + 1) begin
                                memory_array[3][col] <= 7'b0;
                            end
                            // Keep the cursor at the last row and reset column
                            row <= 3;
                            col <= 0;
                        end
                    end
                    8'h7F: begin
                        // Handle backspace
                        if (col > 0) begin
                            col <= col - 1;
                            memory_array[row][col - 1] <= 7'b0;  // Clear the last character
                            
                        end else if (row > 0) begin
                            // Move to the previous row if backspace at column 0
                            found = 0;
                            row <= row - 1;
                            for (c = 16; c > 0; c = c - 1) begin
                                    if(!found && memory_array[row-1][c-1] != 24'h00000 ) begin
                                    found = 1;
                                    col <= c;
                                    end
                            end  // Move to the last column of the previous row
                        end
                    end
                    default: begin
                        memory_array[row][col] <= data_in;  // Store the key code
                        col <= col + 1;  // Move to the next column
                        
                        if (col == 15 && row < 3) begin
                            row <= row + 1;  // Move to next line
                            col <= 0;  // Start at the beginning of the line
                        end
                        else if(col == 16) begin
                                for (row = 1; row < 4; row = row + 1) begin
                                    for (col = 0; col < 16; col = col + 1) begin
                                        memory_array[row - 1][col] <= memory_array[row][col];
                                    end
                                end
                                // Clear the last row
                                for (col = 0; col < 16; col = col + 1) begin
                                    memory_array[3][col] <= 7'b0;
                                end
                                // Keep the cursor at the last row and reset column
                                row <= 3;
                                col <= 0;
                        end
                    end
                endcase
            end
            else if (!data_ready && data_in_progress)begin               
                data_in_progress <= 0;
            end
        end
    end

endmodule