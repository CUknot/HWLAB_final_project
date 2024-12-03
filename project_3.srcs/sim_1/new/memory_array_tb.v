`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:01:32 PM
// Design Name: 
// Module Name: memory_array_tb
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


module memory_array_tb;

    // Test signals
    reg clk;
    reg reset;
    reg [6:0] data_in;
    reg data_ready;
    reg [6:0] addr;
    wire [6:0] data_out;

    // Instantiate the memory_array module
    memory_array uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_ready(data_ready),
        .addr(addr),
        .data_out(data_out)
    );

    // Generate clock
    always begin
        #5 clk = ~clk; // Clock period of 10ns
    end

    // Initial block for simulation
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data_in = 7'b0;
        data_ready = 0;
        addr = 7'b0;

        // Apply reset
        #10 reset = 0;
        
        // Test writing data into memory
        #10 data_in = 7'b1010101; data_ready = 1; addr = 7'b0000000; // Write to address 0
        #10 data_ready = 0; // Disable data_ready
        
        #10 data_in = 7'b1101101; data_ready = 1; addr = 7'b0000001; // Write to address 1
        #10 data_ready = 0; // Disable data_ready
        
        // Test address access
        #10 addr = 7'b0000000; // Read from address 0
        
        #10 addr = 7'b0000001; // Read from address 1

        // Finish simulation
        #20 $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %t | Addr: %b | Data Out: %b", $time, addr, data_out);
    end

endmodule

