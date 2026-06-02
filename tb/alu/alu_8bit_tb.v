module alu_8bit_tb();
    reg   [7:0] A;
    reg   [7:0] B;
    reg   [2:0] op;
    wire  [7:0] S;
    wire Co;

    alu_8bit dut (
        .A(A),
        .B(B),
        .op(op),
        .S(S),
        .Co(Co)
    );

    initial begin
        $dumpfile("alu_8bit.vcd");
        $dumpvars(0, alu_8bit_tb);

        // ADD: 10 + 5 = 15
        A = 8'd10;
        B = 8'd5;
        op = 3'b000;
        #10;

        if (S == 8'd15 && Co == 1'b0)
            $display("PASS: ADD");
        else
            $display("FAIL: ADD expected S=15 Co=0, got S=%d Co=%b", S, Co);


        // SUB: 10 - 5 = 5
        A = 8'd10;
        B = 8'd5;
        op = 3'b001;
        #10;

        if (S == 8'd5)
            $display("PASS: SUB");
        else
            $display("FAIL: SUB expected S=5, got S=%d Co=%b", S, Co);


        // AND: 10101010 & 11001100 = 10001000
        A = 8'b10101010;
        B = 8'b11001100;
        op = 3'b010;
        #10;

        if (S == 8'b10001000 && Co == 1'b0)
            $display("PASS: AND");
        else
            $display("FAIL: AND expected S=10001000 Co=0, got S=%b Co=%b", S, Co);


        // OR: 10101010 | 11001100 = 11101110
        A = 8'b10101010;
        B = 8'b11001100;
        op = 3'b011;
        #10;

        if (S == 8'b11101110 && Co == 1'b0)
            $display("PASS: OR");
        else
            $display("FAIL: OR expected S=11101110 Co=0, got S=%b Co=%b", S, Co);


        // XOR: 10101010 ^ 11001100 = 01100110
        A = 8'b10101010;
        B = 8'b11001100;
        op = 3'b100;
        #10;

        if (S == 8'b01100110 && Co == 1'b0)
            $display("PASS: XOR");
        else
            $display("FAIL: XOR expected S=01100110 Co=0, got S=%b Co=%b", S, Co);


        // Shift left: 00001111 << 1 = 00011110
        A = 8'b00001111;
        B = 8'b00000000;
        op = 3'b101;
        #10;

        if (S == 8'b00011110 && Co == 1'b0)
            $display("PASS: SHIFT LEFT");
        else
            $display("FAIL: SHIFT LEFT expected S=00011110 Co=0, got S=%b Co=%b", S, Co);


        // Shift right: 11110000 >> 1 = 01111000
        A = 8'b11110000;
        B = 8'b00000000;
        op = 3'b110;
        #10;

        if (S == 8'b01111000 && Co == 1'b0)
            $display("PASS: SHIFT RIGHT");
        else
            $display("FAIL: SHIFT RIGHT expected S=01111000 Co=0, got S=%b Co=%b", S, Co);


        // Equal comparison: 25 == 25 gives 00000001
        A = 8'd25;
        B = 8'd25;
        op = 3'b111;
        #10;

        if (S == 8'b00000001 && Co == 1'b0)
            $display("PASS: EQUAL");
        else
            $display("FAIL: EQUAL expected S=00000001 Co=0, got S=%b Co=%b", S, Co);


        // Equal comparison: 25 != 30 gives 00000000
        A = 8'd25;
        B = 8'd30;
        op = 3'b111;
        #10;

        if (S == 8'b00000000 && Co == 1'b0)
            $display("PASS: NOT EQUAL");
        else
            $display("FAIL: NOT EQUAL expected S=00000000 Co=0, got S=%b Co=%b", S, Co);
        $finish;
    end

endmodule