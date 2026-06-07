module instruction_memory (
    input       [3:0] address,
    output reg   [7:0] instruction
);

    // For this module, we will execute the following program:
    //      0: LI R1, 3
    //      1: ADD R1, R2
    //      2: ST R1, [R0]
    //      3: NOP

    always @(*) begin
        case(address)
            4'b0000: instruction = 8'b00111010;
            4'b0001: instruction = 8'b01100000;
            4'b0010: instruction = 8'b01001110;
            4'b0011: instruction = 8'b00001111;
            default: instruction = 8'b00001111;
        endcase
    end

endmodule