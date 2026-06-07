# Program Counter Design

## Overview

This document describes the program counter (PC) module used in the 8-bit CPU project.

The program counter stores the address of the current instruction. This address is sent to instruction memory so the CPU can fetch the next instruction to execute.

The PC is 4 bits wide, which allows it to address 16 instruction memory locations.

## Purpose

The program counter is part of the instruction fetch path.

Conceptually:

```text
Program Counter → Instruction Memory → Instruction Decoder
```

The PC provides the instruction memory address. The instruction memory then outputs the 8-bit instruction stored at that address.

## Inputs and Outputs

| Signal    | Width | Direction | Description                           |
| --------- | ----: | --------- | ------------------------------------- |
| `clk`     | 1-bit | Input     | Clock signal                          |
| `reset`   | 1-bit | Input     | Resets the PC to `0000`               |
| `PCWrite` | 1-bit | Input     | Enables the PC to update              |
| `nextPC`  | 4-bit | Input     | Next address value loaded into the PC |
| `PC`      | 4-bit | Output    | Current instruction address           |

## PC Behavior

The program counter updates on the rising edge of `clk`.

The behavior is:

```text
if reset = 1:
    PC = 0000
else if PCWrite = 1:
    PC = nextPC
else:
    PC holds its current value
```

This means the PC only changes when either `reset` is active or `PCWrite` is enabled.

If `PCWrite` is low, the PC keeps its previous value.

## Design Choice

The PC does not calculate `PC + 1` internally.

Instead, the next PC value is calculated externally by the datapath and control logic, then passed into the PC through `nextPC`.

This keeps the PC module simple and flexible.

For normal instruction sequencing, the datapath can calculate:

```text
nextPC = PC + 1
```

For branch instructions, the datapath can later calculate:

```text
nextPC = PC + SE(Imm4)
```

The PC does not need to know whether the CPU is incrementing normally or branching. It only loads the value provided on `nextPC` when `PCWrite` is high.

## Normal Instruction Flow

During normal execution, the CPU should move from one instruction to the next.

Example:

```text
PC = 0000
nextPC = 0001
PCWrite = 1
```

On the next rising edge of `clk`:

```text
PC = 0001
```

This allows instruction memory to output the instruction stored at address `0001`.

## Branch Support

The current ISA includes branch instructions such as:

```text
BNZ Imm4
BPZ Imm4
```

These instructions can use the ALU to calculate a branch target.

For example:

```text
nextPC = PC + SE(Imm4)
```

If the branch condition is true, the control unit can set:

```text
PCWrite = 1
```

and the PC will load the branch target.

If the branch condition is false, the datapath can instead provide:

```text
nextPC = PC + 1
```

## Hold Behavior

The `PCWrite` signal allows the control unit to pause the PC.

This may be useful later for multi-cycle instructions or control sequences where the CPU should not immediately move to the next instruction.

If:

```text
PCWrite = 0
```

then the PC holds its current value.

## Verification

The program counter is tested using an Icarus Verilog testbench.

The testbench currently verifies:

* `reset` sets the PC to `0000`
* `PCWrite = 1` allows the PC to load `nextPC`
* `PCWrite = 0` causes the PC to hold its current value
* `reset` still works after the PC has already changed

## Running the Program Counter Testbench

```bash
iverilog -s program_counter_tb -o pc_test src/control_unit/program_counter.v tb/control_unit/program_counter_tb.v
vvp pc_test
```

## Current Status

The program counter has been implemented and tested successfully using terminal-based simulation with Icarus Verilog.
