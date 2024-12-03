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
    input wire [6:0] data_in,      // 7-bit data to write
    input wire data_ready,         // Signal to indicate data is ready
    input wire [6:0] addr,         // 7-bit address (2 bits for row, 5 bits for column)
    output wire [6:0] data_out     // 7-bit data output from memory
);

    // Memory array declaration: 4 buffers for 4 rows, each with 32 columns (total 128 locations)
    reg [6:0] memory_array [3:0][31:0];  // 4 rows, each with 32 columns
    reg data_in_progress;               // Flag to track if data is currently being written
    integer i, j ,col ,row, c ,found;
    // Output logic: Reading data from the memory based on the address
    assign data_out = memory_array[addr[6:5]][addr[4:0]]; // Use the top 2 bits for row and the bottom 5 for column

    // Process the data input and manage the memory write and row shifts
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
//            // Reset the memory to zero
//            for (i = 0; i < 4; i = i + 1) begin
//                for (j = 0; j < 32; j = j + 1) begin
//                    memory_array[i][j] <= 7'b0;  // Clear all entries
//                end
//            end
for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 32; j = j + 1) begin
                // Store the string "KRERK PIROMSOPA"
                if (i == 0) begin
                    case (j)
                        0: memory_array[i][j] <= 8'h4B;  // 'K'
                        1: memory_array[i][j] <= 8'h52;  // 'R'
                        2: memory_array[i][j] <= 8'h45;  // 'E'
                        3: memory_array[i][j] <= 8'h52;  // 'R'
                        4: memory_array[i][j] <= 8'h4B;  // 'K'
                        5: memory_array[i][j] <= 8'h20;  // ' ' (space)
                        6: memory_array[i][j] <= 8'h50;  // 'P'
                        7: memory_array[i][j] <= 8'h49;  // 'I'
                        8: memory_array[i][j] <= 8'h52;  // 'R'
                        9: memory_array[i][j] <= 8'h4F;  // 'O'
                        10: memory_array[i][j] <= 8'h4D; // 'M'
                        11: memory_array[i][j] <= 8'h53; // 'S'
                        12: memory_array[i][j] <= 8'h4F; // 'O'
                        13: memory_array[i][j] <= 8'h50; // 'P'
                        14: memory_array[i][j] <= 8'h41; // 'A'
                        default: memory_array[i][j] <= 8'h00;  // Empty spaces for remaining elements
                    endcase
                end
                else begin
                    memory_array[i][j] <= 8'h00;  // Clear other memory locations
                end
            end
        end
            row <= 0;  // Reset cursor row
            col <= 15;  // Reset cursor column
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
                                for (col = 0; col < 32; col = col + 1) begin
                                    memory_array[row - 1][col] <= memory_array[row][col];
                                end
                            end
                            // Clear the last row
                            for (col = 0; col < 32; col = col + 1) begin
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
                            col <= col - 2;
                            memory_array[row][col] <= 7'b0;  // Clear the last character
                        end else if (row > 0) begin
                            // Move to the previous row if backspace at column 0
                            row <= row - 1;
                            for (c = 31; c > 0; c = c - 1) begin
                                    if(memory_array[row + 1][col-1] != 8'h00 ) col <= c ;
                                end  // Move to the last column of the previous row
                        end
                    end
                    default: begin
                        if (col < 31) begin
                            memory_array[row][col] <= data_in;  // Store the key code
                            col <= col + 1;  // Move to the next column
                        end else if (row < 3) begin
                            row <= row + 1;  // Move to next line
                            col <= 0;  // Start at the beginning of the line
                            memory_array[row][col] <= data_in;  // Store the key code
                            col <= col + 1;  // Move to the next column
                        end
                        else begin
                                for (row = 1; row < 4; row = row + 1) begin
                                    for (col = 0; col < 32; col = col + 1) begin
                                        memory_array[row - 1][col] <= memory_array[row][col];
                                    end
                                end
                                // Clear the last row
                                for (col = 0; col < 32; col = col + 1) begin
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
