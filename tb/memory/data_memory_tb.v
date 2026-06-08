module data_memory_tb ();

    reg clk;
    reg MemRead;
    reg MemWrite;
    reg   [3:0] address;
    reg   [7:0] dataIn;
    wire  [7:0] dataOut;

    data_memory dut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $dumpfile("data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        clk = 0;
        MemRead = 0;
        MemWrite = 0;
        address = 4'b0000;
        dataIn = 8'b00000000;

        // Test 1: Write value to address 0:
        address = 4'b0000;
        dataIn = 8'b00000001; // dataIn = 1
        MemWrite = 1;
        MemRead = 0;

        @(posedge clk);
        #1;

        MemWrite = 0;
        MemRead = 1;
        #1;

        if(dataOut == 8'b00000001)
            $display("PASS: wrote and read 1 at address 0");
        else
            $display("FAIL: expected 00000001 at address 0, got %b", dataOut);

        // Test 2: Write 25 to address 5:
        address = 4'b0101;
        dataIn = 8'd25;
        MemWrite = 1;
        MemRead = 0;

        @(posedge clk);
        #1;

        MemWrite = 0;
        MemRead = 1;
        #1;

        if(dataOut == 8'd25)
            $display("PASS: wrote and read 25 at address 5");
        else
            $display("FAIL: expected 25 at address 5, got %b", dataOut);

        // Test 3: MemRead off should output 0:
        MemRead = 0;
        #1;

        if(dataOut == 8'b00000000)
            $display("PASS: MemRead is 0 and dataOut is 0");
        else
            $display("FAIL: dataOut is %b", dataOut);

        $finish;
    end

endmodule