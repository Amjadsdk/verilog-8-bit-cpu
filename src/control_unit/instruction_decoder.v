module instruction_decoder(
    input   [7:0] instruction,
    output  [1:0] readA,
    output  [1:0] readB,
    output  [1:0] regW,
    output  [2:0] opcode
);

    // from "instruction":
    // * [7:5] -> opcode
    // * [4:3] -> regA & regW
    // * [2:1] -> regB
    // * [0] -> unused for now, can be used for later instructions

    assign opcode =     instruction[7:5];
    assign readA =      instruction[4:3];
    assign regW =       instruction[4:3];
    assign readB =       instruction[2:1];

endmodule