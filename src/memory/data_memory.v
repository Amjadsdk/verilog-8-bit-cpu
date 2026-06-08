module data_memory (
    input clk,
    input MemRead,
    input MemWrite,
    input   [3:0] address,
    input       [7:0] dataIn,
    output reg  [7:0] dataOut
);

    // First always block writes to memory (therefore only runs on clock edge)

    reg [7:0] memory [0:15];
    always @(posedge clk) begin
        if(MemWrite)
            memory[address] <= dataIn;
    end

    // Second always block reads from memory (no need to wait for clock edge since nothing is written)

    always @(*) begin
        if(MemRead)
            dataOut = memory[address];
        else
            dataOut = 8'b00000000;
    end

endmodule