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
    integer i, j ,col ,row, c;
    // Output logic: Reading data from the memory based on the address
    assign data_out = memory_array[addr[6:5]][addr[4:0]]; // Use the top 2 bits for row and the bottom 5 for column

    // Process the data input and manage the memory write and row shifts
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the memory to zero
          // Declare integer variables outside the loop
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    memory_array[i][j] <= 7'b0;  // Clear all entries
                end
            end
            data_in_progress <= 0;  // Reset data_in_progress flag
        end else begin
            // If data is ready and no data is currently being written
            if (data_ready && !data_in_progress) begin
                // Set the flag to indicate that we're in the process of writing data
                data_in_progress <= 1;
                
                // Find the first empty slot in the first row (row 0)
                
                for (col = 0; col < 32; col = col + 1) begin
                    if (memory_array[0][col] == 7'b0) begin
                        // Write the new data into the first empty column of the first row
                        memory_array[0][col] <= data_in;
                        break;
                    end
                end

                // If the first row is full, shift the data down to the next row
                if (memory_array[0][31] != 7'b0) begin
                    
                    // Shift rows down starting from row 3 to row 1
                    for (row = 3; row > 0; row = row - 1) begin
                        for (c = 0; c < 32; c = c + 1) begin
                            memory_array[row][c] <= memory_array[row - 1][c];
                        end
                    end
                    // After shifting, reset row 0 (the first row)
                    for (col = 0; col < 32; col = col + 1) begin
                        memory_array[0][col] <= 7'b0;  // Clear the first row
                    end
                    // Insert the data into the first column of row 0
                    memory_array[0][0] <= data_in;
                end
            end
            // If data is not ready, wait for the next cycle and reset the data_in_progress flag
            if (!data_ready && data_in_progress) begin
                // Clear the flag when the data_ready signal goes low
                data_in_progress <= 0;
            end
        end
    end

endmodule
