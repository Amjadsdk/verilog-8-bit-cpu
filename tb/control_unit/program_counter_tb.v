module program_counter_tb ();

    reg clk;
    reg reset;
    reg PCWrite;
    reg [3:0] nextPC;

    wire [3:0] PC;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .nextPC(nextPC),
        .PC(PC)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $dumpfile("program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        // Initial values
        clk = 0;
        reset = 0;
        PCWrite = 0;
        nextPC = 4'b0000;

        // Test 1: reset should set PC to 0
        reset = 1;
        @(posedge clk);
        #1;

        if (PC == 4'b0000)
            $display("PASS: reset sets PC to 0");
        else
            $display("FAIL: reset expected PC=0000, got PC=%b", PC);

        // Turn reset off
        reset = 0;

        // Test 2: PCWrite = 1 should load nextPC
        nextPC = 4'b0011;
        PCWrite = 1;
        @(posedge clk);
        #1;

        if (PC == 4'b0011)
            $display("PASS: PCWrite loads nextPC");
        else
            $display("FAIL: expected PC=0011, got PC=%b", PC);

        // Test 3: PCWrite = 0 should hold PC
        nextPC = 4'b1010;
        PCWrite = 0;
        @(posedge clk);
        #1;

        if (PC == 4'b0011)
            $display("PASS: PC holds when PCWrite is 0");
        else
            $display("FAIL: expected PC to hold 0011, got PC=%b", PC);

        // Test 4: PCWrite = 1 should load a new value
        nextPC = 4'b0101;
        PCWrite = 1;
        @(posedge clk);
        #1;

        if (PC == 4'b0101)
            $display("PASS: PC loads new nextPC value");
        else
            $display("FAIL: expected PC=0101, got PC=%b", PC);

        // Test 5: reset should work again
        reset = 1;
        @(posedge clk);
        #1;

        if (PC == 4'b0000)
            $display("PASS: reset works after PC changed");
        else
            $display("FAIL: reset expected PC=0000, got PC=%b", PC);

        $finish;
    end

endmodule