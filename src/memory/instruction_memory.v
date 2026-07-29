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
            4'b0000: instruction = 8'b00111010; // LI R1, 3
            4'b0001: instruction = 8'b01100000; // ADD R1, R2
            4'b0010: instruction = 8'b01001110; // ST R1, [R0]
            4'b0011: instruction = 8'b10001101; // LD R2, [R0]
            4'b0100: instruction = 8'b00001111; // NOP
            default: instruction = 8'b00001111; // NOP
        endcase
    end

endmodule