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
    wire [7:0] rx_data;
    wire [0:6] num0;
    wire tx_start;
    wire rx_ready;
    
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
        .tx_data(rx_data),
        .tx_start(rx_ready_singlepulser),
        .tx_busy(),               
        .tx_out(RsTx)
    );

    // Instantiate UART Receiver
    uart_rx rx_inst (
        .clk(clk_uart),
        .reset(reset),
        .rx_in(RsRx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
    
    siekoo_rom siekoo_rom_inst(rx_data, num0);
    
    quadSevenSeg display (
        .seg(seg),
        .dp(dp),
        .an(an),
        .num0(~num0),  // Right-most character
        .num1(8'hFF),
        .num2(8'hFF),
        .num3(8'hFF),  // Left-most character
        .clk(clkDiv)    
    );
    
    //always @(posedge clk_uart) RsTx = RsRx;
endmodule

