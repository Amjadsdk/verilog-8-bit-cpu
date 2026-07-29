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
        .debug_RegWriteSel(debug_RegWriteSel)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_top.vcd");
        $dumpvars(0, cpu_top_tb);

        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        $display("Time\tPC\tInstr\t\tOpcode\tState\tPCW\tRFW\tA\t\tB\t\tALU\t\tWBSel");

        repeat (12) begin
            @(posedge clk);
            #1;

            $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
                     $time,
                     debug_PC,
                     debug_instruction,
                     debug_opcode,
                     debug_state,
                     debug_PCWrite,
                     debug_RFWrite,
                     debug_dataA,
                     debug_dataB,
                     debug_aluResult,
                     debug_RegWriteSel);
        end

        $display("CPU top integration test complete.");
        $finish;
    end

endmodule