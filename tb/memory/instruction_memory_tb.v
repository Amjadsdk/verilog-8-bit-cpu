module instruction_memory_tb ();

    reg  [3:0] address;
    wire [7:0] instruction;

    instruction_memory dut (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        // Address 0: LI R1, 3
        address = 4'b0000;
        #10;

        if (instruction == 8'b00111010)
            $display("PASS: address 0 = LI R1, 3");
        else
            $display("FAIL: address 0 expected 00111010, got %b", instruction);


        // Address 1: ADD R1, R2
        address = 4'b0001;
        #10;

        if (instruction == 8'b01100000)
            $display("PASS: address 1 = ADD R1, R2");
        else
            $display("FAIL: address 1 expected 01100000, got %b", instruction);


        // Address 2: ST R1, [R0]
        address = 4'b0010;
        #10;

        if (instruction == 8'b01001110)
            $display("PASS: address 2 = ST R1, [R0]");
        else
            $display("FAIL: address 2 expected 01001110, got %b", instruction);


        // Address 3: NOP
        address = 4'b0011;
        #10;

        if (instruction == 8'b00001111)
            $display("PASS: address 3 = NOP");
        else
            $display("FAIL: address 3 expected 00001111, got %b", instruction);


        // Default/unprogrammed address should also return NOP
        address = 4'b0100;
        #10;

        if (instruction == 8'b00001111)
            $display("PASS: default address = NOP");
        else
            $display("FAIL: default address expected 00001111, got %b", instruction);


        $finish;
    end

endmodule