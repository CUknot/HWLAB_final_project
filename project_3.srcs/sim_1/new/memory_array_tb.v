`timescale 1ns / 1ps

module memory_array_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [23:0] data_in;
    reg data_ready;
    reg [5:0] addr;

    // Outputs
    wire [23:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    memory_array uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_ready(data_ready),
        .addr(addr),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Simulation
    initial begin
        // Initialize inputs
        reset = 1;
        data_in = 0;
        data_ready = 0;
        addr = 0;

        // Apply reset
        #20;
        reset = 0;
        
        data_in = 23'h0A0B0E;
        // Test case 4: Fill all rows
        repeat(64) begin
            data_in = data_in + 1;
            data_ready = 1;
            #10;
            data_ready = 0;
            #10;
        end


        repeat(64) begin
            data_in = 24'h00007F;
            data_ready = 1;
            #10;
            data_ready = 0;
            #10;
        end
        /*// Test case 5: Add data when all rows are full
        @(posedge clk);
        data_in = 24'h123456;
        data_ready = 1;
        @(posedge clk);
        data_ready = 0;

        // Test case 6: Handle Backspace (DEL)
        @(posedge clk);
        data_in = 24'h007F;  // Backspace
        data_ready = 1;
        @(posedge clk);
        data_ready = 0;

        // Test case 7: Backspace at row = 0
        repeat(16) begin
            @(posedge clk);
            data_in = 24'h007F;
            data_ready = 1;
            @(posedge clk);
            data_ready = 0;
        end

        // Test case 8: Handle Enter
        @(posedge clk);
        data_in = 24'h00000D;  // Enter
        data_ready = 1;
        @(posedge clk);
        data_ready = 0;

        // Test case 9: Enter when memory is full
        repeat(3) begin
            @(posedge clk);
            data_in = 24'h00000D;  // Enter
            data_ready = 1;
            @(posedge clk);
            data_ready = 0;
        end

        // End simulation
        #100;*/
        $stop;
    end
    
//    always @(posedge clk) begin
//        // Display the contents of the memory array after each clock cycle
//        $display("Time: %0d", $time);
//        $display("Row: %0d, Col: %0d", uut.row, uut.col);
//        for (integer r = 0; r < 4; r = r + 1) begin
//            $write("Row %0d: ", r);
//            for (integer c = 0; c < 16; c = c + 1) begin
//                $write("%h ", uut.memory_array[r][c]);
//            end
//            $display("");  // Newline
//        end
//        $display("--------------------------------------------------");
//    end

endmodule
