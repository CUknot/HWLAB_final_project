`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 09:48:59 PM
// Design Name: 
// Module Name: Display_system
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

module Display_system(
    input wire clk,        
    input wire btnC,   
    input wire btnU, 
    input wire [7:0] sw,                    
    input wire RsRx,             
    output wire RsTx,
    output Hsync,       // to VGA connector
    output Vsync,       // to VGA connector
    output [11:0] rgb,   // to DAC, to VGA connector
    output [6:0] seg,      
    output dp,             
    output [3:0]an   
    );
    
    wire clk_uart; // Baud rate clock (9600 Hz)
    wire clkDiv;
    reg [23:0] tx_utf8_data;  
    wire [23:0] rx_utf8_data; 
    reg tx_start;
    wire rx_ready;
    wire [6:0] num0, num1, num2, num3;
    wire btnU_singlepulser;
    wire [7:0] d,notd,d2,notd2,sw_singlepulser;
    assign reset = btnC;
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
    
    // Synchronizer
    genvar n;
    generate for(n=0;n<8;n=n+1) begin
        dFlipflop dFF2(d2[n],notd2[n],sw[n],clk_uart);
        dFlipflop dFF(d[n],notd[n],d2[n],clk_uart);
    end endgenerate
    
    single_pulse single_pulse_inst(
        .clk(clk_uart),             
        .reset(reset),         
        .trigger_in(rx_ready),     
        .pulse_out(rx_ready_singlepulser)      
    );

    single_pulse single_pulse_inst2(
        .clk(clk_uart),             
        .reset(reset),         
        .trigger_in(btnU),     
        .pulse_out(btnU_singlepulser)      
    );
    
    // Instantiate UART Transmitter
    uart_tx tx_inst (
        .clk(clk_uart),
        .reset(reset),
        .tx_data(tx_utf8_data),
        .tx_start(tx_start),
        .tx_busy(),               
        .tx_out(RsTx)
    );

    // Instantiate UART Receiver
    uart_rx rx_inst (
        .clk(clk_uart),
        .reset(reset),
        .rx_in(RsRx),
        .rx_data(rx_utf8_data),
        .rx_ready(rx_ready)
    );
    
    
    hexTo7Segment hexTo7Segment_inst0(
        .segments(num0),
        .hex(tx_utf8_data[3:0])
    );
    
     hexTo7Segment hexTo7Segment_inst1(
        .segments(num1),
        .hex(tx_utf8_data[7:4])
    );
    
        hexTo7Segment hexTo7Segment_inst2(
        .segments(num2),
        .hex(tx_utf8_data[11:8])
    );
    
        hexTo7Segment hexTo7Segment_inst3(
        .segments(num3),
        .hex(tx_utf8_data[15:12])
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
    
    
    always @(posedge clk_uart) begin
        if(btnU_singlepulser) begin 
            tx_utf8_data <= d;  
            tx_start <= 1; 
        end else if(rx_ready_singlepulser) begin 
            tx_utf8_data <= rx_utf8_data; 
            tx_start <= rx_ready_singlepulser; 
        end else tx_start <= rx_ready_singlepulser; 
    end
    

    // signals
    wire [9:0] w_x, w_y;
    wire w_video_on;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    // VGA Controller
    vga_controller vga(.clk_100MHz(clk), .reset(btnC), .hsync(Hsync), .vsync(Vsync),
                       .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    // Text Generation Circuit
    display cdisplay(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y),
     .tx_data(tx_utf8_data),
     .tx_start(tx_start),
     .rgb(rgb_next),
     .reset(btnC));
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
endmodule
