`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 11:01:08 PM
// Design Name: 
// Module Name: divClock
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

module divClock (
    input wire clk_in,         
    input wire reset,          
    output reg clk_out         
);

    reg [17:0] counter;        

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;      
            clk_out <= 0;      
        end else begin
            counter <= counter + 1;
            if (counter == 262143) begin
                clk_out <= ~clk_out;  
                counter <= 0;         
            end
        end
    end
endmodule

