module control_unit(
    input clk,
    input reset,
    input   [3:0] opcode,
    input Z,
    input N,
    output reg PCWrite,
    output reg RFWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg [2:0] ALUop,
    output reg [1:0] ALUASel,
    output reg [1:0] ALUBSel,
    output reg [1:0] RegWriteSel,
    output reg [1:0] PCSel,

    output     [2:0] currentStateOut
);

    // Multiplexors:

    // ALUASel
    // 00 = register A
    // 01 = PC

    // ALUBSel
    // 00 = register B
    // 01 = immediate
    // 10 = constant 1

    // RegWriteSel
    // 00 = ALU result
    // 01 = data memory output
    // 10 = immediate

    // PCSel
    // 00 = PC + 1
    // 01 = branch target

    localparam FETCH        = 3'b000;
    localparam DECODE       = 3'b001;
    localparam EXECUTE      = 3'b010;
    localparam MEMORY       = 3'b011;
    localparam WRITEBACK    = 3'b100;

    reg [2:0] currentState, nextState;

    always @(posedge clk) begin
        if(reset)
            currentState <= FETCH;
        else
            currentState <= nextState;
    end

    // Next State Logic
    always @(*) begin
        case(currentState)
            FETCH: begin
                nextState = DECODE;
            end

            DECODE: begin
                case(opcode)
                    4'b0000: nextState = EXECUTE; // ADD
                    4'b0001: nextState = EXECUTE; // SUB
                    4'b0010: nextState = EXECUTE; // AND
                    4'b0011: nextState = EXECUTE; // OR
                    4'b0100: nextState = EXECUTE; // XOR
                    4'b0101: nextState = EXECUTE; // SL
                    4'b0110: nextState = EXECUTE; // SR
                    4'b1000: nextState = EXECUTE; // EQ

                    // Immediate instructions
                    4'b1001: nextState = EXECUTE; // ADDI
                    4'b1010: nextState = EXECUTE; // LI

                    // Branch instructions
                    4'b1011: nextState = EXECUTE; // BNZ
                    4'b1100: nextState = EXECUTE; // BPZ

                    // Memory instructions
                    4'b1101: nextState = EXECUTE; // LD
                    4'b1110: nextState = EXECUTE; // ST

                    // NOP
                    4'b1111: nextState = FETCH;

                    default: nextState = FETCH;
                endcase
            end

            EXECUTE: begin
                case(opcode)
                    // ALU, shift, immediate instructions need writeback
                    4'b0000: nextState = WRITEBACK; // ADD
                    4'b0001: nextState = WRITEBACK; // SUB
                    4'b0010: nextState = WRITEBACK; // AND
                    4'b0011: nextState = WRITEBACK; // OR
                    4'b0100: nextState = WRITEBACK; // XOR
                    4'b0101: nextState = WRITEBACK; // SL
                    4'b0110: nextState = WRITEBACK; // SR
                    4'b1000: nextState = WRITEBACK; // EQ
                    4'b1001: nextState = WRITEBACK; // ADDI
                    4'b1010: nextState = WRITEBACK; // LI

                    // Branches finish after execute
                    4'b1011: nextState = FETCH; // BNZ
                    4'b1100: nextState = FETCH; // BPZ

                    // Memory instructions go to memory state
                    4'b1101: nextState = MEMORY; // LD
                    4'b1110: nextState = MEMORY; // ST

                    default: nextState = FETCH;
                endcase
            end

            MEMORY: begin
                case(opcode)
                    // LD needs writeback after memory read
                    4'b1101: nextState = WRITEBACK;

                    // ST finishes after memory write
                    4'b1110: nextState = FETCH;
                    default: nextState = FETCH;
                endcase
            end

            WRITEBACK: begin
                nextState <= FETCH;
            end

            default: nextState <= FETCH;
        endcase
    end

    // Control Signal Logic
    always @(*) begin
        // Default values
        PCWrite = 0;
        RFWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        ALUop = 3'b000;
        ALUASel = 2'b00;
        ALUBSel = 2'b00;
        RegWriteSel = 2'b00;
        PCSel = 2'b00;

        case (currentState)
            FETCH: begin
                PCWrite = 1;
                PCSel = 2'b00;      // PC + 1
                ALUASel = 2'b01;    // ALU input A = PC
                ALUBSel = 2'b10;    // ALU input B = constant 1
                ALUop = 3'b000;     // ADD
            end

            DECODE: begin
                // No writes yet
            end

            EXECUTE: begin
                case(opcode)
                    4'b0000: begin // ADD
                        ALUop = 3'b000;
                        ALUASel = 2'b00; // register A
                        ALUBSel = 2'b00; // register B
                    end

                    4'b0001: begin // SUB
                        ALUop = 3'b001;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0010: begin // AND
                        ALUop = 3'b010;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0011: begin // OR
                        ALUop = 3'b011;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0100: begin // XOR
                        ALUop = 3'b100;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0101: begin // SL
                        ALUop = 3'b101;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b0110: begin // SR
                        ALUop = 3'b110;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b1000: begin // EQ
                        ALUop = 3'b111;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b1001: begin // ADDI
                        ALUop = 3'b000;
                        ALUASel = 2'b00; // R1
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b1010: begin // LI
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b1011: begin // BNZ
                        ALUop = 3'b000;
                        ALUASel = 2'b01; // PC
                        ALUBSel = 2'b01; // Imm4
                        PCSel = 2'b01;   // branch target

                        if (Z == 0)
                            PCWrite = 1;
                    end

                    4'b1100: begin // BPZ
                        ALUop = 3'b000;
                        ALUASel = 2'b01; // PC
                        ALUBSel = 2'b01; // Imm4
                        PCSel = 2'b01;   // branch target

                        if (N == 0)
                            PCWrite = 1;
                    end
                endcase
            end

            MEMORY: begin
                case (opcode)
                    4'b1101: begin // LD
                        MemRead = 1;
                    end

                    4'b1110: begin // ST
                        MemWrite = 1;
                    end
                endcase
            end

            WRITEBACK: begin
                case(opcode)
                    // ALU result writeback
                    4'b0000,
                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b0101,
                    4'b0110,
                    4'b1000,
                    4'b1001: begin
                        RFWrite = 1;
                        RegWriteSel = 2'b00; // ALU result
                    end

                    // LI writes immediate
                    4'b1010: begin
                        RFWrite = 1;
                        RegWriteSel = 2'b10; // immediate
                    end

                    // LD writes memory output
                    4'b1101: begin
                        RFWrite = 1;
                        RegWriteSel = 2'b01; // data memory output
                    end
                endcase
            end
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default values
        PCWrite = 0;
        RFWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        ALUop = 3'b000;
        ALUASel = 2'b00;
        ALUBSel = 2'b00;
        RegWriteSel = 2'b00;
        PCSel = 2'b00;

        case(currentState)
            FETCH: begin
                PCWrite = 1;
                PCSel = 2'b00;       // nextPC = PC + 1
                ALUASel = 2'b01;     // ALU input A = PC
                ALUBSel = 2'b10;     // ALU input B = constant 1
                ALUop = 3'b000;      // ADD
            end

            DECODE: begin
                // no writes happen yet
            end

            EXECUTE: begin
                case(opcode)
                    4'b0000: begin // ADD
                        ALUop = 3'b000;
                        ALUASel = 2'b00; // register A
                        ALUBSel = 2'b00; // register B
                    end

                    4'b0001: begin // SUB
                        ALUop = 3'b001;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0010: begin // AND
                        ALUop = 3'b010;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0011: begin // OR
                        ALUop = 3'b011;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0100: begin // XOR
                        ALUop = 3'b100;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b0101: begin // SL
                        ALUop = 3'b101;
                        ALUASel = 2'b00; // register A
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b0110: begin // SR
                        ALUop = 3'b110;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b01;
                    end

                    4'b1000: begin // EQ
                        ALUop = 3'b111;
                        ALUASel = 2'b00;
                        ALUBSel = 2'b00;
                    end

                    4'b1001: begin // ADDI
                        ALUop = 3'b000;  // ADD
                        ALUASel = 2'b00; // register A / R1 later in datapath
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b1010: begin // LI
                        // LI does not really need the ALU in this first design.
                        // Writeback will select the immediate value.
                        ALUBSel = 2'b01; // immediate
                    end

                    4'b1011: begin // BNZ
                        ALUop = 3'b000;  // ADD for PC + immediate
                        ALUASel = 2'b01; // PC
                        ALUBSel = 2'b01; // immediate
                        PCSel = 2'b01;   // branch target

                        if (Z == 0)
                            PCWrite = 1;
                    end

                    4'b1100: begin // BPZ
                        ALUop = 3'b000;  // ADD for PC + immediate
                        ALUASel = 2'b01; // PC
                        ALUBSel = 2'b01; // immediate
                        PCSel = 2'b01;   // branch target

                        if (N == 0)
                            PCWrite = 1;
                    end

                    4'b1101: begin // LD
                        // Address comes from RB later in datapath.
                        // Actual memory read happens in MEMORY state.
                    end

                    4'b1110: begin // ST
                        // Address comes from RB later in datapath.
                        // Actual memory write happens in MEMORY state.
                    end

                    4'b1111: begin // NOP
                        // Do nothing
                    end

                    default: begin
                        // Keep default values
                    end
                endcase
            end

            MEMORY: begin
                case(opcode)
                    4'b1101: begin // LD
                        MemRead = 1;
                    end

                    4'b1110: begin // ST
                        MemWrite = 1;
                    end

                    default: begin
                        // Keep default values
                    end
                endcase
            end

            WRITEBACK: begin
                case(opcode)
                    // ALU result writeback
                    4'b0000, // ADD
                    4'b0001, // SUB
                    4'b0010, // AND
                    4'b0011, // OR
                    4'b0100, // XOR
                    4'b0101, // SL
                    4'b0110, // SR
                    4'b1000, // EQ
                    4'b1001: begin // ADDI
                        RFWrite = 1;
                        RegWriteSel = 2'b00; // ALU result
                    end

                    4'b1010: begin // LI
                        RFWrite = 1;
                        RegWriteSel = 2'b10; // immediate
                    end

                    4'b1101: begin // LD
                        RFWrite = 1;
                        RegWriteSel = 2'b01; // data memory output
                    end

                    default: begin
                        // No writeback
                    end
                endcase
            end
        endcase
    end
    assign currentStateOut = currentState;
endmodule