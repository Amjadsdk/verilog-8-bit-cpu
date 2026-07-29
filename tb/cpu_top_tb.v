`timescale 1ns/1ps

module cpu_top_tb();

    reg clk;
    reg reset;

    wire [3:0] debug_PC;
    wire [7:0] debug_instruction;
    wire [3:0] debug_opcode;
    wire [2:0] debug_state;
    wire debug_PCWrite;

    wire [7:0] debug_dataA;
    wire [7:0] debug_dataB;
    wire [7:0] debug_aluResult;
    wire debug_RFWrite;
    wire [1:0] debug_RegWriteSel;

    wire debug_MemRead;
    wire debug_MemWrite;
    wire [3:0] debug_dataMemAddress;
    wire [7:0] debug_dataMemOut;
    wire [7:0] debug_R0;
    wire [7:0] debug_R1;
    wire [7:0] debug_R2;
    wire [7:0] debug_R3;

    cpu_top dut (
        .clk(clk),
        .reset(reset),

        .debug_PC(debug_PC),
        .debug_instruction(debug_instruction),
        .debug_opcode(debug_opcode),
        .debug_state(debug_state),
        .debug_PCWrite(debug_PCWrite),

        .debug_dataA(debug_dataA),
        .debug_dataB(debug_dataB),
        .debug_aluResult(debug_aluResult),
        .debug_RFWrite(debug_RFWrite),
        .debug_RegWriteSel(debug_RegWriteSel),

        .debug_MemRead(debug_MemRead),
        .debug_MemWrite(debug_MemWrite),
        .debug_dataMemAddress(debug_dataMemAddress),
        .debug_dataMemOut(debug_dataMemOut),
        .debug_R0(debug_R0),
        .debug_R1(debug_R1),
        .debug_R2(debug_R2),
        .debug_R3(debug_R3)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_top.vcd");
        $dumpvars(0, cpu_top_tb);

        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        $display("Time\tPC\tInstr\t\tOpcode\tState\tPCW\tRFW\tMR\tMW\tA\t\tB\t\tALU\t\tAddr\tDMemOut\t\tR0\t\tR1\t\tR2\t\tR3\t\tWBSel");

        repeat (20) begin
            @(posedge clk);
            #1;

            $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
                $time,
                debug_PC,
                debug_instruction,
                debug_opcode,
                debug_state,
                debug_PCWrite,
                debug_RFWrite,
                debug_MemRead,
                debug_MemWrite,
                debug_dataA,
                debug_dataB,
                debug_aluResult,
                debug_dataMemAddress,
                debug_dataMemOut,
                debug_R0,
                debug_R1,
                debug_R2,
                debug_R3,
                debug_RegWriteSel);
        end

        $display("CPU top integration test complete.");
        $finish;
    end

endmodule