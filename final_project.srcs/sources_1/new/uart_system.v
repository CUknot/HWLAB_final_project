`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 08:18:41 PM
// Design Name: 
// Module Name: uart_system
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


module uart_system (
    input wire clk,        
    input wire btnC,             
    //input wire [7:0] tx_data,     
    input wire RsRx,             
    output wire RsTx,         
    //output wire rx_ready          
    output [6:0] seg,      
    output dp,             
    output [3:0]an
);
    wire clk_uart; // Baud rate clock (9600 Hz)
    wire clkDiv;
    wire [23:0] utf8_data; 
    wire tx_busy;        
    wire [0:6] num0;
    wire tx_start;
    wire rx_ready;
    wire [6:0] num0, num1, num2, num3;
    // Instantiate Clock Divider
    clk_divider clk_div_inst (
        .clk_in(clk),
        .reset(btnC),
        .clk_out(clk_uart)
    );

    divClock divClock_inst (
        .clk_in(clk),
        .reset(btnC),
        .clk_out(clkDiv)
    );
    
    single_pulse single_pulse_inst(
        .clk(clk_uart),             
        .reset(reset),         
        .trigger_in(rx_ready),     
        .pulse_out(rx_ready_singlepulser)      
);
    
    // Instantiate UART Transmitter
    uart_tx tx_inst (
        .clk(clk_uart),
        .reset(reset),
        .tx_data(utf8_data),
        .tx_start(rx_ready_singlepulser),
        .tx_busy(tx_busy),               
        .tx_out(RsTx)
    );

    // Instantiate UART Receiver
    uart_rx rx_inst (
        .clk(clk_uart),
        .reset(reset),
        .rx_in(RsRx),
        .rx_data(utf8_data),
        .rx_ready(rx_ready)
    );
    
    
    hexTo7Segment hexTo7Segment_inst0(
        .segments(num0),
        .hex(utf8_data[3:0])
    );
    
     hexTo7Segment hexTo7Segment_inst1(
        .segments(num1),
        .hex(utf8_data[7:4])
    );
    
        hexTo7Segment hexTo7Segment_inst2(
        .segments(num2),
        .hex(utf8_data[11:8])
    );
    
        hexTo7Segment hexTo7Segment_inst3(
        .segments(num3),
        .hex(utf8_data[15:12])
    );
    
    
        quadSevenSeg display (
        .seg(seg),
        .dp(dp),
        .an(an),
        .num0(num0),  // Right-most character
        .num1(num1),
        .num2(num2),
        .num3(num3),  // Left-most character
        .clk(clkDiv)    
    );
    
    
    //always @(posedge clk_uart) RsTx = RsRx;
endmodule