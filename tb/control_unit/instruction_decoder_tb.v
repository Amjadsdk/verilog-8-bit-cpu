module instruction_decoder_tb ();

    reg   [7:0] instruction;

    wire  [1:0] RA;
    wire  [1:0] RB;
    wire  [1:0] Imm2;
    wire  [3:0] Imm4;
    wire  [3:0] opcode;

    instruction_decoder dut (
        .instruction(instruction),
        .RA(RA),
        .RB(RB),
        .Imm2(Imm2),
        .Imm4(Imm4),
        .opcode(opcode)
    );
    
    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        // ADD R1 R2
        // Format: RA RB opcode
        // RA = 01, RB = 10, opcode = 0000
        instruction = 8'b01100000;
        #10;

        if(RA == 2'b01 && RB == 2'b10 && Imm2 == 2'b10 && Imm4 == 4'b0110 && opcode == 4'b0000)
            $display("PASS: ADD R1 R2");
        else
            $display("FAIL: EXPECTED ADD R1 R2");


        // SUB R3 R1
        // RA = 11, RB = 01, opcode = 0001
        instruction = 8'b11010001;
        #10;

        if(RA == 2'b11 && RB == 2'b01 && Imm2 == 2'b01 && Imm4 == 4'b1101 && opcode == 4'b0001)
            $display("PASS: SUB R3 R1");
        else
            $display("FAIL: EXPECTED SUB R3 R1");
        

        // AND R2 R0
        // RA = 10, RB = 00, opcode = 0010
        instruction = 8'b10000010;
        #10;

        if(RA == 2'b10 && RB == 2'b00 && Imm2 == 2'b00 && Imm4 == 4'b1000 && opcode == 4'b0010)
            $display("PASS: AND R2 R0");
        else
            $display("FAIL: EXPECTED AND R2 R0");


        // SL R2, 3
        // RA = 10, Imm2 = 11, opcode = 0101
        instruction = 8'b10110101;
        #10;

        if(RA == 2'b10 && RB == 2'b11 && Imm2 == 2'b11 && Imm4 == 4'b1011 && opcode == 4'b0101)
            $display("PASS: SL R2 3");
        else
            $display("FAIL: EXPECTED SL R2 3");


        // LI R1, -2
        // Imm4 = 1110, opcode = 1010
        // For Imm4 instructions, R1 is assumed later by the control/datapath, not by the decoder
        instruction = 8'b11101010;
        #10;

        if(RA == 2'b11 && RB == 2'b10 && Imm2 == 2'b10 && Imm4 == 4'b1110 && opcode == 4'b1010)
            $display("PASS: LI R1 -2");
        else
            $display("FAIL: EXPECTED LI R1 -2");


        // BNZ -1
        // Imm4 = 1111, opcode = 1011
        instruction = 8'b11111011;
        #10;

        if(RA == 2'b11 && RB == 2'b11 && Imm2 == 2'b11 && Imm4 == 4'b1111 && opcode == 4'b1011)
            $display("PASS: BNZ -1");
        else
            $display("FAIL: EXPECTED BNZ -1");


        $finish;
        
    end

endmodule