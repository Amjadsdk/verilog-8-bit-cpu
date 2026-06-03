module register_file_tb();

    reg  [1:0] readA;
    reg  [1:0] readB;
    reg  [1:0] regW;
    reg  [7:0] dataW;
    reg        writeEnable;
    reg        clk;

    wire [7:0] dataA;
    wire [7:0] dataB;

    register_file dut (
        .readA(readA),
        .readB(readB),
        .regW(regW),
        .dataW(dataW),
        .writeEnable(writeEnable),
        .clk(clk),
        .dataA(dataA),
        .dataB(dataB)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);

        // Write 10 to R0
        regW = 2'b00;
        dataW = 8'd10;
        writeEnable = 1'b1;
        @(posedge clk);
        #1;

        // Read R0 through dataA
        readA = 2'b00;
        #1;

        if (dataA == 8'd10)
            $display("PASS: Write/read R0");
        else
            $display("FAIL: R0 expected 10, got %d", dataA);

        // Write 25 to R1
        regW = 2'b01;
        dataW = 8'd25;
        writeEnable = 1'b1;
        @(posedge clk);
        #1;

        // Read R0 on dataA and R1 on dataB
        readA = 2'b00;
        readB = 2'b01;
        #1;

        if (dataA == 8'd10 && dataB == 8'd25)
            $display("PASS: Read R0 and R1 simultaneously");
        else
            $display("FAIL: Expected dataA=10 dataB=25, got dataA=%d dataB=%d", dataA, dataB);

        // Write 100 to R2
        regW = 2'b10;
        dataW = 8'd100;
        writeEnable = 1'b1;
        @(posedge clk);
        #1;

        readA = 2'b10;
        #1;

        if (dataA == 8'd100)
            $display("PASS: Write/read R2");
        else
            $display("FAIL: R2 expected 100, got %d", dataA);

        // Write 200 to R3
        regW = 2'b11;
        dataW = 8'd200;
        writeEnable = 1'b1;
        @(posedge clk);
        #1;

        readA = 2'b11;
        #1;

        if (dataA == 8'd200)
            $display("PASS: Write/read R3");
        else
            $display("FAIL: R3 expected 200, got %d", dataA);

        // Try to overwrite R1 with 99 while writeEnable is OFF
        regW = 2'b01;
        dataW = 8'd99;
        writeEnable = 1'b0;
        @(posedge clk);
        #1;

        // Read R1
        readA = 2'b01;
        #1;

        if (dataA == 8'd25)
            $display("PASS: writeEnable=0 prevented write");
        else
            $display("FAIL: writeEnable=0 failed, R1 expected 25, got %d", dataA);

        // Overwrite R0 with 55
        regW = 2'b00;
        dataW = 8'd55;
        writeEnable = 1'b1;
        @(posedge clk);
        #1;

        readA = 2'b00;
        #1;

        if (dataA == 8'd55)
            $display("PASS: Overwrite R0");
        else
            $display("FAIL: R0 expected 55 after overwrite, got %d", dataA);
        $finish;
    end

endmodule