module vga_controller #(
    parameter BIT_WIDTH = 9,      // 2^9 = 512 > 320
    parameter BIT_HEIGHT = 8,     // 2^8 = 256 > 240
    parameter FONT_WIDTH = 8,
    parameter FONT_HEIGHT = 16
) (
    input wire clk_pixel,
    input wire [BIT_WIDTH-1:0] cx,
    input wire [BIT_HEIGHT-1:0] cy,
    output reg [23:0] rgb = 24'd0
);

    // ASCII Storage: 24 characters (3 lines, 8 characters each)
    reg [7:0] ascii_data[0:23];
    initial begin
        // Initialize ASCII data (e.g., "Hello VGA!")
        ascii_data[0] = "H";
        ascii_data[1] = "e";
        ascii_data[2] = "l";
        ascii_data[3] = "l";
        ascii_data[4] = "o";
        ascii_data[5] = ",";
        ascii_data[6] = " ";
        ascii_data[7] = "V";
        ascii_data[8] = "G";
        ascii_data[9] = "A";
        ascii_data[10] = " ";
        ascii_data[11] = "T";
        ascii_data[12] = "e";
        ascii_data[13] = "s";
        ascii_data[14] = "t";
        ascii_data[15] = "!";
        ascii_data[16] = "L";
        ascii_data[17] = "i";
        ascii_data[18] = "n";
        ascii_data[19] = "e";
        ascii_data[20] = "3";
        ascii_data[21] = ".";
        ascii_data[22] = "?";
        ascii_data[23] = " ";
    end

    // Character ROM and Attributes
    wire [127:0] glyph;
    wire [23:0] fgrgb = 24'hFFFFFF; // White text
    wire [23:0] bgrgb = 24'h000000; // Black background
    glyphmap glyphmap(.codepoint(ascii_data[char_index]), .glyph(glyph));

    // Calculate character indices
    localparam CHAR_COLS = 8;
    localparam CHAR_ROWS = 3;

    wire [3:0] char_x = cx / FONT_WIDTH;       // Horizontal character index
    wire [3:0] char_y = cy / FONT_HEIGHT;     // Vertical character index
    wire [4:0] char_index = char_y * CHAR_COLS + char_x; // Current character index in ascii_data

    // Glyph pixel indices
    wire [2:0] glyph_x = cx % FONT_WIDTH;     // Current column in glyph
    wire [3:0] glyph_y = cy % FONT_HEIGHT;    // Current row in glyph

    // Blink logic (optional)
    reg [5:0] blink_timer = 0;
    always @(posedge clk_pixel) begin
        if (cx == 0 && cy == 0)
            blink_timer <= blink_timer + 1;
    end

    // Render the pixel
    always @(posedge clk_pixel) begin
        if (char_index < 24) begin
            // Display the glyph or background based on glyph bit
            if (glyph[{~glyph_y, ~glyph_x}])
                rgb <= fgrgb; // Foreground color
            else
                rgb <= bgrgb; // Background color
        end else begin
            rgb <= bgrgb; // Default to background if out of range
        end
    end

endmodule
