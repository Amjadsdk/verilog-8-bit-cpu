module cpu_top (
    input clk,
    input reset,

    output [3:0] debug_PC,
    output [7:0] debug_instruction,
    output [3:0] debug_opcode,
    output [2:0] debug_state,
    output debug_PCWrite,
    output [7:0] debug_dataA,
    output [7:0] debug_dataB,
    output [7:0] debug_aluResult,
    output debug_RFWrite,
    output [1:0] debug_RegWriteSel,
    output debug_MemRead,
    output debug_MemWrite,
    output [3:0] debug_dataMemAddress,
    output [7:0] debug_dataMemOut,
    output [7:0] debug_R0,
    output [7:0] debug_R1,
    output [7:0] debug_R2,
    output [7:0] debug_R3
);

    // Program counter wires
    wire [3:0] PC;
    wire [3:0] nextPC;
    wire PCWrite;

    // Instruction wires
    wire [7:0] instructionFromMemory;
    reg [7:0] instructionReg;
    wire [1:0] RA;
    wire [1:0] RB;
    wire [1:0] Imm2;
    wire [3:0] Imm4;
    wire [3:0] opcode;

    // Control unit wires
    wire RFWrite;
    wire MemRead;
    wire MemWrite;
    wire [2:0] ALUop;
    wire [1:0] ALUASel;
    wire [1:0] ALUBSel;
    wire [1:0] RegWriteSel;
    wire [1:0] PCSel;
    wire [2:0] currentStateOut;

    // Register file wires
    wire [7:0] dataA;
    wire [7:0] dataB;
    wire [7:0] dataW;
    wire [1:0] regW;

    // ALU wires
    wire [7:0] aluA;
    wire [7:0] aluB;
    wire [7:0] aluResult;
    wire aluCarryOut;

    // Data memory wires
    wire [3:0] dataMemAddress;
    wire [7:0] dataMemOut;

    assign dataMemAddress = dataB[3:0];

    // Writeback MUX logic
    wire [7:0] imm4SignExt;
    wire [7:0] imm2ZeroExt;

    // Immediate values
    assign imm4SignExt = {{4{Imm4[3]}}, Imm4};
    assign imm2ZeroExt = {6'b000000, Imm2};

    // ALU input selection
    assign aluA = (ALUASel == 2'b01) ? {4'b0000, PC} :
              dataA;

    assign aluB = (ALUBSel == 2'b01) ? imm4SignExt :
            (ALUBSel == 2'b10) ? 8'b00000001 :
            dataB;

     // Temporary flags for now
    wire Z;
    wire N;

    assign Z = 0;
    assign N = 0;

    // Register writeback selection
    assign dataW = (RegWriteSel == 2'b00) ? aluResult :
               (RegWriteSel == 2'b01) ? dataMemOut :
               (RegWriteSel == 2'b10) ? imm4SignExt :
               8'b00000000;

    // Register destination selection
    assign regW = (opcode == 4'b1001 || opcode == 4'b1010) ? 2'b01 : RA;

    // Next PC logic
    assign nextPC = aluResult[3:0];

    localparam FETCH = 3'b000;

    always @(posedge clk) begin
        if (reset)
            instructionReg <= 8'b00001111; // NOP
        else if (currentStateOut == FETCH)
            instructionReg <= instructionFromMemory;
    end

     program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .nextPC(nextPC),
        .PC(PC)
    );

    data_memory dmem_inst (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(dataMemAddress),
        .dataIn(dataA),
        .dataOut(dataMemOut)
    );

    alu_8bit alu_inst (
        .A(aluA),
        .B(aluB),
        .op(ALUop),
        .S(aluResult),
        .Co(aluCarryOut)
    );

    instruction_memory imem_inst (
        .address(PC),
        .instruction(instructionFromMemory)
    );

    instruction_decoder decoder_inst (
        .instruction(instructionReg),
        .RA(RA),
        .RB(RB),
        .Imm2(Imm2),
        .Imm4(Imm4),
        .opcode(opcode)
    );

    register_file regfile_inst (
        .readA(RA),
        .readB(RB),
        .regW(regW),
        .dataW(dataW),
        .writeEnable(RFWrite),
        .clk(clk),
        .dataA(dataA),
        .dataB(dataB),
        .debug_R0(debug_R0),
        .debug_R1(debug_R1),
        .debug_R2(debug_R2),
        .debug_R3(debug_R3)
    );

    control_unit control_inst (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .Z(Z),
        .N(N),

        .PCWrite(PCWrite),
        .RFWrite(RFWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUop(ALUop),
        .ALUASel(ALUASel),
        .ALUBSel(ALUBSel),
        .RegWriteSel(RegWriteSel),
        .PCSel(PCSel),
        .currentStateOut(currentStateOut)
    );

    assign debug_PC = PC;
    assign debug_instruction = instructionReg;
    assign debug_opcode = opcode;
    assign debug_state = currentStateOut;
    assign debug_PCWrite = PCWrite;

    assign debug_dataA = dataA;
    assign debug_dataB = dataB;
    assign debug_aluResult = aluResult;
    assign debug_RFWrite = RFWrite;
    assign debug_RegWriteSel = RegWriteSel;

    assign debug_MemRead = MemRead;
    assign debug_MemWrite = MemWrite;
    assign debug_dataMemAddress = dataMemAddress;
    assign debug_dataMemOut = dataMemOut;

endmodule