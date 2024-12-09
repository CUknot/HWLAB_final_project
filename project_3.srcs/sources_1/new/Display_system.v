`timescale 1ns / 1ps

module Display_system(
    input wire clk,        
    input wire btnC,   
    input wire btnU, 
    input wire [7:0] sw,                    
    input wire RsRx,
    inout wire [1:0] JB,             
    output wire RsTx,   // Transmit to external device
    output Hsync,       // VGA horizontal sync
    output Vsync,       // VGA vertical sync
    output [11:0] rgb,  // VGA color output
    output [6:0] seg,   // 7-segment display
    output dp,          // Decimal point
    output [3:0] an     // 7-segment display anode control
    );

    wire clk_uart;          // Baud rate clock (9600 Hz)
    wire clkDiv;            // Clock divider
    reg [23:0] tx_utf8_data;    // Data to RsTx
    reg [23:0] tx_utf8_data2;   // Data to JB[0]
    wire [23:0] rx_utf8_data, rx_utf8_data2; 
    reg tx_start_RsRx, tx_start_JB;
    wire rx_ready, rx_ready2;
    wire btnU_singlepulser;
    wire rx_ready_singlepulser, rx_ready_singlepulser2;
    wire [7:0] d, notd, d2, notd2;
    wire [6:0] num0, num1, num2, num3;

    assign reset = btnC;

    // Clock Divider
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

    // Synchronizer for switches
    genvar n;
    generate for (n = 0; n < 8; n = n + 1) begin
        dFlipflop dFF2(d2[n], notd2[n], sw[n], clk_uart);
        dFlipflop dFF(d[n], notd[n], d2[n], clk_uart);
    end endgenerate

    // Single Pulse Modules
    single_pulse single_pulse_btnU (
        .clk(clk_uart),
        .reset(reset),
        .trigger_in(btnU),
        .pulse_out(btnU_singlepulser)
    );

    single_pulse single_pulse_rx (
        .clk(clk_uart),
        .reset(reset),
        .trigger_in(rx_ready),
        .pulse_out(rx_ready_singlepulser)
    );

    single_pulse single_pulse_rx2 (
        .clk(clk_uart),
        .reset(reset),
        .trigger_in(rx_ready2),
        .pulse_out(rx_ready_singlepulser2)
    );

    // UART Transmitter for RsTx
    uart_tx tx_inst_RsRx (
        .clk(clk_uart),
        .reset(reset),
        .tx_data(tx_utf8_data),
        .tx_start(tx_start_RsRx),
        .tx_busy(),                
        .tx_out(RsTx)
    );

    // UART Transmitter for JB[0]
    uart_tx tx_inst_JB (
        .clk(clk_uart),
        .reset(reset),
        .tx_data(tx_utf8_data2),
        .tx_start(tx_start_JB),
        .tx_busy(),                
        .tx_out(JB[0])
    );

    // UART Receiver for RsRx
    uart_rx rx_inst (
        .clk(clk_uart),
        .reset(reset),
        .rx_in(RsRx),
        .rx_data(rx_utf8_data),
        .rx_ready(rx_ready)
    );

    // UART Receiver for JB[1]
    uart_rx rx_inst2 (
        .clk(clk_uart),
        .reset(reset),
        .rx_in(JB[1]),
        .rx_data(rx_utf8_data2),
        .rx_ready(rx_ready2)
    );

    // Transmission Logic
    always @(posedge clk_uart) begin
        // Data from switches
        if (btnU_singlepulser) begin 
           // tx_utf8_data <= d;          // Send to RsRx
            tx_utf8_data2 <= d;         // Send to JB[0]
            tx_start_RsRx <= 0; 
            tx_start_JB <= 1; 
        end 
        // Data from keyboard (RsRx)
        else if (rx_ready_singlepulser) begin 
            //tx_utf8_data <= rx_utf8_data; // Send to RsRx
            tx_utf8_data2 <= rx_utf8_data; // Send to JB[0]
            tx_start_RsRx <= 0;
            tx_start_JB <= 1;
        end 
        // Data from JB[1]
        else if (rx_ready_singlepulser2) begin
            tx_utf8_data <= rx_utf8_data2; // Send to RsRx
            tx_start_RsRx <= 1; 
            tx_start_JB <= 0;              // Do not send to JB[0]
        end 
        // No data to send
        else begin
            tx_start_RsRx <= 0; 
            tx_start_JB <= 0; 
        end
    end
    
    // Hex to 7-Segment Display
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
    
    
        quadSevenSeg quadSevenSeg_inst (
        .seg(seg),
        .dp(dp),
        .an(an),
        .num0(num0),  // Right-most character
        .num1(num1),
        .num2(num2),
        .num3(num3),  // Left-most character
        .clk(clkDiv)    
    );

    // VGA Signal Generation
    wire [9:0] w_x, w_y;
    wire w_video_on;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;

    vga_controller vga (
        .clk_100MHz(clk),
        .reset(btnC),
        .hsync(Hsync),
        .vsync(Vsync),
        .video_on(w_video_on),
        .p_tick(w_p_tick),
        .x(w_x),
        .y(w_y)
    );

    display cdisplay (
        .clk(clk),
        .video_on(w_video_on),
        .x(w_x),
        .y(w_y),
        .tx_data(tx_utf8_data),
        .tx_start(tx_start_RsRx), // VGA uses RsRx data
        .rgb(rgb_next),
        .reset(btnC)
    );

    // RGB Buffer
    always @(posedge clk)
        if (w_p_tick)
            rgb_reg <= rgb_next;

    // RGB Output
    assign rgb = rgb_reg;

endmodule
