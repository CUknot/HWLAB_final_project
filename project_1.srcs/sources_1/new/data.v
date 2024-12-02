module rom_memory (
    input wire [6:0] addr,       // 7-bit address input
    output wire [6:0] data_out   // 7-bit data output from ROM
);

    // Declare a 128-location ROM (7-bit wide data at each address)
    reg [6:0] rom [127:0];  // 128 memory locations, 7 bits each

    // Assign the data from the ROM to the output based on the address
    assign data_out = rom[addr];

    // Read the ROM contents from the file at the beginning of the simulation
    initial begin
        // The file should contain values in hexadecimal format (7-bit)
        $readmemh("data.txt", rom); // Use $readmemh for hexadecimal data
    end

endmodule