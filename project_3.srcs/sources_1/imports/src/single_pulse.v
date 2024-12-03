`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 12:33:21 AM
// Design Name: 
// Module Name: single_pulse
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

module single_pulse (
    input wire clk,             // Clock input
    input wire reset,           // Reset input
    input wire trigger_in,      // Trigger signal to generate pulse
    output reg pulse_out        // Output pulse signal
);

    reg trigger_in_d;           // Registered version of the trigger signal
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trigger_in_d <= 0;
            pulse_out <= 0;
        end else begin
            trigger_in_d <= trigger_in;
            
            // Generate a pulse on the rising edge of trigger_in
            if (trigger_in && !trigger_in_d) begin
                pulse_out <= 1;  // Pulse is high for 1 clock cycle
            end else begin
                pulse_out <= 0;  // Pulse goes low otherwise
            end
        end
    end
endmodule

