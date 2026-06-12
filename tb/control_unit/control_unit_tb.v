`timescale 1ns/1ps

module control_unit_tb();

    reg clk;
    reg reset;
    reg [3:0] opcode;
    reg Z;
    reg N;

    wire PCWrite;
    wire RFWrite;
    wire MemRead;
    wire MemWrite;
    wire [2:0] ALUop;
    wire [1:0] ALUASel;
    wire [1:0] ALUBSel;
    wire [1:0] RegWriteSel;
    wire [1:0] PCSel;
    wire [2:0] currentStateOut;

    control_unit dut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .Z(Z),
        .N(N),

        .PCWrite(PCWrite),
        .RFWrite(RFWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUop(ALUop),
        .ALUASel(ALUASel),
        .ALUBSel(ALUBSel),
        .RegWriteSel(RegWriteSel),
        .PCSel(PCSel),
        .currentStateOut(currentStateOut)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        clk = 0;
        reset = 1;
        opcode = 4'b0000;
        Z = 0;
        N = 0;

        #10;
        reset = 0;
        #1;

        if (currentStateOut == 3'b000)
            $display("PASS: Reset starts FSM in FETCH");
        else
            $display("FAIL: Expected FETCH after reset, got %b", currentStateOut);

        // ----------------------------------------------------
        // Test 1: ADD instruction
        // Expected: FETCH -> DECODE -> EXECUTE -> WRITEBACK -> FETCH
        // ----------------------------------------------------
        opcode = 4'b0000; // ADD

        @(posedge clk); #1; // DECODE
        if (currentStateOut == 3'b001)
            $display("PASS: ADD moved to DECODE");
        else
            $display("FAIL: ADD expected DECODE, got %b", currentStateOut);

        @(posedge clk); #1; // EXECUTE
        if (currentStateOut == 3'b010 && ALUop == 3'b000)
            $display("PASS: ADD moved to EXECUTE with ALUop ADD");
        else
            $display("FAIL: ADD expected EXECUTE with ALUop 000, got state %b ALUop %b", currentStateOut, ALUop);

        @(posedge clk); #1; // WRITEBACK
        if (currentStateOut == 3'b100 && RFWrite == 1 && RegWriteSel == 2'b00)
            $display("PASS: ADD moved to WRITEBACK and enables RFWrite");
        else
            $display("FAIL: ADD expected WRITEBACK with RFWrite=1, got state %b RFWrite %b RegWriteSel %b",
                     currentStateOut, RFWrite, RegWriteSel);

        @(posedge clk); #1; // FETCH
        if (currentStateOut == 3'b000)
            $display("PASS: ADD returned to FETCH");
        else
            $display("FAIL: ADD expected FETCH, got %b", currentStateOut);


        // ----------------------------------------------------
        // Test 2: LD instruction
        // Expected: FETCH -> DECODE -> EXECUTE -> MEMORY -> WRITEBACK -> FETCH
        // ----------------------------------------------------
        opcode = 4'b1101; // LD

        @(posedge clk); #1; // DECODE
        @(posedge clk); #1; // EXECUTE

        if (currentStateOut == 3'b010)
            $display("PASS: LD moved to EXECUTE");
        else
            $display("FAIL: LD expected EXECUTE, got %b", currentStateOut);

        @(posedge clk); #1; // MEMORY
        if (currentStateOut == 3'b011 && MemRead == 1)
            $display("PASS: LD moved to MEMORY and enables MemRead");
        else
            $display("FAIL: LD expected MEMORY with MemRead=1, got state %b MemRead %b",
                     currentStateOut, MemRead);

        @(posedge clk); #1; // WRITEBACK
        if (currentStateOut == 3'b100 && RFWrite == 1 && RegWriteSel == 2'b01)
            $display("PASS: LD moved to WRITEBACK and selects memory output");
        else
            $display("FAIL: LD expected WRITEBACK with memory writeback, got state %b RFWrite %b RegWriteSel %b",
                     currentStateOut, RFWrite, RegWriteSel);

        @(posedge clk); #1; // FETCH
        if (currentStateOut == 3'b000)
            $display("PASS: LD returned to FETCH");
        else
            $display("FAIL: LD expected FETCH, got %b", currentStateOut);


        // ----------------------------------------------------
        // Test 3: ST instruction
        // Expected: FETCH -> DECODE -> EXECUTE -> MEMORY -> FETCH
        // ----------------------------------------------------
        opcode = 4'b1110; // ST

        @(posedge clk); #1; // DECODE
        @(posedge clk); #1; // EXECUTE

        if (currentStateOut == 3'b010)
            $display("PASS: ST moved to EXECUTE");
        else
            $display("FAIL: ST expected EXECUTE, got %b", currentStateOut);

        @(posedge clk); #1; // MEMORY
        if (currentStateOut == 3'b011 && MemWrite == 1)
            $display("PASS: ST moved to MEMORY and enables MemWrite");
        else
            $display("FAIL: ST expected MEMORY with MemWrite=1, got state %b MemWrite %b",
                     currentStateOut, MemWrite);

        @(posedge clk); #1; // FETCH
        if (currentStateOut == 3'b000)
            $display("PASS: ST returned to FETCH");
        else
            $display("FAIL: ST expected FETCH, got %b", currentStateOut);


        // ----------------------------------------------------
        // Test 4: NOP instruction
        // Expected: FETCH -> DECODE -> FETCH
        // ----------------------------------------------------
        opcode = 4'b1111; // NOP

        @(posedge clk); #1; // DECODE
        if (currentStateOut == 3'b001)
            $display("PASS: NOP moved to DECODE");
        else
            $display("FAIL: NOP expected DECODE, got %b", currentStateOut);

        @(posedge clk); #1; // FETCH
        if (currentStateOut == 3'b000 && RFWrite == 0 && MemRead == 0 && MemWrite == 0)
            $display("PASS: NOP returned to FETCH with no writes");
        else
            $display("FAIL: NOP expected FETCH with no writes, got state %b RFWrite %b MemRead %b MemWrite %b",
                     currentStateOut, RFWrite, MemRead, MemWrite);


        // ----------------------------------------------------
        // Test 5: BNZ branch taken
        // Expected: PCWrite = 1 during EXECUTE when Z = 0
        // ----------------------------------------------------
        opcode = 4'b1011; // BNZ
        Z = 0;

        @(posedge clk); #1; // DECODE
        @(posedge clk); #1; // EXECUTE

        if (currentStateOut == 3'b010 && PCWrite == 1 && PCSel == 2'b01)
            $display("PASS: BNZ taken sets PCWrite and PCSel branch");
        else
            $display("FAIL: BNZ taken expected PCWrite=1 PCSel=01, got state %b PCWrite %b PCSel %b",
                     currentStateOut, PCWrite, PCSel);

        @(posedge clk); #1; // FETCH


        // ----------------------------------------------------
        // Test 6: BNZ branch not taken
        // Expected: PCWrite = 0 during EXECUTE when Z = 1
        // ----------------------------------------------------
        opcode = 4'b1011; // BNZ
        Z = 1;

        @(posedge clk); #1; // DECODE
        @(posedge clk); #1; // EXECUTE

        if (currentStateOut == 3'b010 && PCWrite == 0)
            $display("PASS: BNZ not taken keeps PCWrite off");
        else
            $display("FAIL: BNZ not taken expected PCWrite=0, got state %b PCWrite %b",
                     currentStateOut, PCWrite);

        @(posedge clk); #1; // FETCH


        $display("Control unit testbench complete.");
        $finish;
    end

endmodule