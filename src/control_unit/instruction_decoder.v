module instruction_decoder(
    input   [7:0] instruction,
    output  [1:0] RA,
    output  [1:0] RB,
    output  [1:0] Imm2,
    output  [3:0] Imm4,
    output  [3:0] opcode
);

    assign RA       = instruction[7:6];
    assign RB       = instruction[5:4];
    assign Imm2     = instruction[5:4];
    assign Imm4     = instruction[7:4];
    assign opcode   = instruction[3:0];

endmodule