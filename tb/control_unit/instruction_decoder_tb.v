module instruction_decoder_tb ();

    reg   [7:0] instruction;
    wire  [1:0] readA;
    wire  [1:0] readB;
    wire  [1:0] regW;
    wire  [2:0] opcode; 

    instruction_decoder dut (
        .instruction(instruction),
        .readA(readA),
        .readB(readB),
        .regW(regW),
        .opcode(opcode)
    );
    
    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        // ADD R1 R2
        instruction = 8'b00001100;
        #10;

        if(readA == 2'b01 && readB == 2'b10 && regW == 2'b01 && opcode == 3'b000)
            $display("PASS: ADD R1 R2");
        else
            $display("FAIL: EXPECTED ADD R1 R2");

        // SUB R3 R1
        instruction = 8'b00111010;
        #10;

        if(readA == 2'b11 && readB == 2'b01 && regW == 2'b11 && opcode == 3'b001)
            $display("PASS: SUB R3 R1");
        else
            $display("FAIL: EXPECTED SUB R3 R1");
        
        // AND R2 R0
        instruction = 8'b01010000;
        #10;

        if(readA == 2'b10 && readB == 2'b00 && regW == 2'b10 && opcode == 3'b010)
            $display("PASS: AND R2 R0");
        else
            $display("FAIL: EXPECTED AND R2 R0");
        
    end

endmodule