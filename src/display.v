`timescale 1ns / 1ps
// Reference book: "FPGA Prototyping by Verilog Examples"
//                    "Xilinx Spartan-3 Version"
// Authored by: Pong P. Chu
// Published by: Wiley, 2008
// Adapted for use on Basys 3 FPGA with Xilinx Artix-7
// by: David J. Marion aka FPGA Dude

module display(
    input clk,
    input video_on,
    input [9:0] x, y,
    input [23:0] tx_data,
    input  tx_start,
    input reset,
    output reg [11:0] rgb
    );
    
    // signal declarations
    wire [27:0] rom_addr;           // 11-bit text ROM address
    wire [23:0] ascii_char;          // 7-bit ASCII character code
    wire [3:0] char_row;            // 4-bit row of ASCII character
    wire [2:0] bit_addr;            // column number of ROM data
    wire [7:0] rom_dataA;            // 8-bit row data from text ROM
    wire [7:0] rom_dataT;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;     // ROM bit and status signal
    wire [23:0] data_out;
    
    // instantiate ASCII ROM
    ascii_rom rom1(.clk(clk), .addr(rom_addr[10:0]), .data(rom_dataA));
    thai_rom rom2(.clk(clk), .addr(rom_addr), .data(rom_dataT));
    
    memory_array memory(
    .clk(clk),
    .reset(reset),
    .data_in(tx_data),      
    .data_ready(tx_start),        
    .addr({y[5:4],x[6:3]}),         
    .data_out(data_out)  
    )  ;
    
    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = ascii_char[23:20] == 4'b1110 ?rom_dataT[~bit_addr]:rom_dataA[~bit_addr] ;     // reverse bit order
    
    assign ascii_char = data_out;   // 7-bit ascii code
//    assign ascii_char = data_out;   // 7-bit ascii code
    assign char_row = y[3:0];               // row number of ascii character rom
    assign bit_addr = x[2:0];               // column number of ascii character rom
    // "on" region in center of screen
    assign ascii_bit_on = ((x >= 256 && x < 384) && (y >= 192 && y < 256)) ? ascii_bit : 1'b0;
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // blank
        else
            if(ascii_bit_on)
                if (x[3])rgb = 12'h00F;  // blue letters
                else rgb = 12'h00E;  // blue letters
            else
                rgb = 12'hFFF;  // white background
   
endmodule
