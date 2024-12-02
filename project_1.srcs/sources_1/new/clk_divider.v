module clk_divider (
    input wire clk_in,        // 100 MHz input clock
    input wire reset,         // Reset signal
    output reg clk_out        // Divided clock output
);

    reg [13:0] counter;       // 14-bit counter for dividing

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;  // Ensure clk_out is initialized to 0
        end else begin
            // Check if counter has reached the division value
            if (counter == 10416 / 2 - 1) begin
                clk_out <= ~clk_out;  // Toggle output clock
                counter <= 0;         // Reset counter after toggle
            end else begin
                counter <= counter + 1; // Increment counter
            end
        end
    end
endmodule
