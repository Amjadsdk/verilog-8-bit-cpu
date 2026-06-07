module program_counter (
    input clk,
    input reset,
    input PCWrite,
    input       [3:0] nextPC,
    output reg  [3:0] PC
); 

    // PC stores current instruction
    // nextPC is calculated externally by the datapath (ALU)

    always @(posedge clk) begin
        if(reset)
            PC <= 4'b0000;
        else if (PCWrite)
            PC <= nextPC;
    end

endmodule