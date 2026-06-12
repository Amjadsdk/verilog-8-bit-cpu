# Control Unit Design

## Overview

This document describes the control unit for the 8-bit CPU project.

The control unit is responsible for coordinating the CPU datapath. It reads the instruction opcode and generates the control signals needed to move data through the program counter, instruction memory, register file, ALU, and data memory.

The control unit will be implemented as a finite state machine (FSM). The FSM breaks instruction execution into steps such as fetch, decode, execute, memory access, and writeback.

## Purpose

The control unit tells each CPU component what to do during each stage of instruction execution.

The CPU currently includes:

* Program counter
* Instruction memory
* Instruction decoder
* Register file
* ALU
* Data memory

The control unit connects these blocks into a working processor by generating signals such as:

* `PCWrite`
* `RFWrite`
* `MemRead`
* `MemWrite`
* `ALUop`
* ALU input select signals
* Register writeback select signals

## FSM States

The first version of the CPU will use a multi-cycle FSM.

| State       | Purpose                                                            |
| ----------- | ------------------------------------------------------------------ |
| `FETCH`     | Fetch the instruction from instruction memory using the current PC |
| `DECODE`    | Decode the instruction fields and prepare control decisions        |
| `EXECUTE`   | Perform ALU operation, address calculation, or branch calculation  |
| `MEMORY`    | Access data memory for load/store instructions                     |
| `WRITEBACK` | Write the final result back to the register file                   |

Not every instruction needs every state. For example, a register-register ALU instruction may use `FETCH`, `DECODE`, `EXECUTE`, and `WRITEBACK`, while a store instruction may use `FETCH`, `DECODE`, `EXECUTE`, and `MEMORY`.

## Control Signals

| Signal        | Width | Description                                             |
| ------------- | ----: | ------------------------------------------------------- |
| `PCWrite`     | 1-bit | Enables the program counter to load `nextPC`            |
| `RFWrite`     | 1-bit | Enables writing to the register file                    |
| `MemRead`     | 1-bit | Enables reading from data memory                        |
| `MemWrite`    | 1-bit | Enables writing to data memory                          |
| `ALUop`       | 3-bit | Selects the ALU operation                               |
| `ALUASel`     |   TBD | Selects the first ALU input                             |
| `ALUBSel`     |   TBD | Selects the second ALU input                            |
| `RegWriteSel` |   TBD | Selects what value is written back to the register file |
| `PCSel`       |   TBD | Selects the next PC source or branch behavior           |

Some signal widths are marked as `TBD` because the exact mux options will be finalized when the full datapath is connected.

## ALU Operation Mapping

The control unit converts instruction opcodes into ALU operation select signals.

| Instruction | Opcode | ALUop | ALU Operation       |
| ----------- | ------ | ----- | ------------------- |
| `ADD`       | `0000` | `000` | Addition            |
| `SUB`       | `0001` | `001` | Subtraction         |
| `AND`       | `0010` | `010` | Bitwise AND         |
| `OR`        | `0011` | `011` | Bitwise OR          |
| `XOR`       | `0100` | `100` | Bitwise XOR         |
| `SL`        | `0101` | `101` | Shift left          |
| `SR`        | `0110` | `110` | Shift right         |
| `EQ`        | `1000` | `111` | Equality comparison |

The instruction opcode is 4 bits, but the ALU operation select signal is 3 bits. The control unit translates the instruction opcode into the correct `ALUop`.

## Instruction Categories

The current ISA includes the following categories:

| Category              | Instructions                           |
| --------------------- | -------------------------------------- |
| Register-register ALU | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `EQ` |
| Shift                 | `SL`, `SR`                             |
| Immediate             | `ADDI`, `LI`                           |
| Branch                | `BNZ`, `BPZ`                           |
| Memory                | `LD`, `ST`                             |
| Control               | `NOP`                                  |

## State Behavior by Instruction Type

### Register-Register ALU Instructions

Instructions:

```text
ADD RA, RB
SUB RA, RB
AND RA, RB
OR RA, RB
XOR RA, RB
EQ RA, RB
```

Meaning:

```text
RA = RA operation RB
```

Expected states:

```text
FETCH → DECODE → EXECUTE → WRITEBACK
```

Behavior:

| State       | Behavior                                          |
| ----------- | ------------------------------------------------- |
| `FETCH`     | Fetch instruction from instruction memory         |
| `DECODE`    | Decode `RA`, `RB`, and opcode                     |
| `EXECUTE`   | ALU performs operation using `RA` and `RB` values |
| `WRITEBACK` | Register file writes ALU result back to `RA`      |

Control signal summary:

| Signal     | Value                              |
| ---------- | ---------------------------------- |
| `RFWrite`  | `1` during `WRITEBACK`             |
| `MemRead`  | `0`                                |
| `MemWrite` | `0`                                |
| `ALUop`    | Based on opcode                    |
| `PCWrite`  | Used during instruction sequencing |

### Shift Instructions

Instructions:

```text
SL RA, Imm2
SR RA, Imm2
```

Meaning:

```text
RA = RA << Imm2
RA = RA >> Imm2
```

Expected states:

```text
FETCH → DECODE → EXECUTE → WRITEBACK
```

Behavior:

| State       | Behavior                                       |
| ----------- | ---------------------------------------------- |
| `FETCH`     | Fetch instruction                              |
| `DECODE`    | Decode `RA`, `Imm2`, and opcode                |
| `EXECUTE`   | ALU shifts `RA` by `Imm2`                      |
| `WRITEBACK` | Register file writes shift result back to `RA` |

Note: The current ALU may need to be updated later to support variable shift amounts using `Imm2`.

### Immediate Instructions

Instructions:

```text
ADDI R1, Imm4
LI R1, Imm4
```

For Imm4-format instructions, the CPU assumes `R1` as the destination register.

Expected states:

```text
FETCH → DECODE → EXECUTE → WRITEBACK
```

Behavior:

| Instruction     | Behavior                             |
| --------------- | ------------------------------------ |
| `ADDI R1, Imm4` | ALU adds `R1 + SE(Imm4)`             |
| `LI R1, Imm4`   | Write sign-extended `Imm4` into `R1` |

Control signal summary:

| Signal     | Value                                                   |
| ---------- | ------------------------------------------------------- |
| `RFWrite`  | `1` during `WRITEBACK`                                  |
| `MemRead`  | `0`                                                     |
| `MemWrite` | `0`                                                     |
| `ALUop`    | ADD for `ADDI`; pass/select immediate for `LI` behavior |

### Branch Instructions

Instructions:

```text
BNZ Imm4
BPZ Imm4
```

Meanings:

```text
BNZ Imm4: if Z = 0, PC = PC + SE(Imm4)
BPZ Imm4: if N = 0, PC = PC + SE(Imm4)
```

Expected states:

```text
FETCH → DECODE → EXECUTE
```

Behavior:

| State     | Behavior                              |
| --------- | ------------------------------------- |
| `FETCH`   | Fetch branch instruction              |
| `DECODE`  | Decode opcode and `Imm4`              |
| `EXECUTE` | Check condition and calculate next PC |

Branch conditions:

| Instruction | Condition                       |
| ----------- | ------------------------------- |
| `BNZ`       | Branch if zero flag `Z = 0`     |
| `BPZ`       | Branch if negative flag `N = 0` |

The branch target is calculated using the ALU:

```text
nextPC = PC + SE(Imm4)
```

If the branch is not taken, the CPU continues with the next sequential instruction.

### Load Instruction

Instruction:

```text
LD RA, [RB]
```

Meaning:

```text
RA = MEM[RB]
```

Expected states:

```text
FETCH → DECODE → EXECUTE → MEMORY → WRITEBACK
```

Behavior:

| State       | Behavior                        |
| ----------- | ------------------------------- |
| `FETCH`     | Fetch instruction               |
| `DECODE`    | Decode `RA`, `RB`, and opcode   |
| `EXECUTE`   | Use `RB[3:0]` as memory address |
| `MEMORY`    | Read from data memory           |
| `WRITEBACK` | Write memory output into `RA`   |

Control signal summary:

| Signal        | Value                     |
| ------------- | ------------------------- |
| `MemRead`     | `1` during `MEMORY`       |
| `MemWrite`    | `0`                       |
| `RFWrite`     | `1` during `WRITEBACK`    |
| `RegWriteSel` | Select data memory output |

### Store Instruction

Instruction:

```text
ST RA, [RB]
```

Meaning:

```text
MEM[RB] = RA
```

Expected states:

```text
FETCH → DECODE → EXECUTE → MEMORY
```

Behavior:

| State     | Behavior                          |
| --------- | --------------------------------- |
| `FETCH`   | Fetch instruction                 |
| `DECODE`  | Decode `RA`, `RB`, and opcode     |
| `EXECUTE` | Use `RB[3:0]` as memory address   |
| `MEMORY`  | Write `RA` value into data memory |

Control signal summary:

| Signal     | Value               |
| ---------- | ------------------- |
| `MemRead`  | `0`                 |
| `MemWrite` | `1` during `MEMORY` |
| `RFWrite`  | `0`                 |

### NOP Instruction

Instruction:

```text
NOP
```

Meaning:

```text
Do nothing
```

Expected states:

```text
FETCH → DECODE
```

Behavior:

| Signal     | Value |
| ---------- | ----- |
| `RFWrite`  | `0`   |
| `MemRead`  | `0`   |
| `MemWrite` | `0`   |

The CPU simply moves to the next instruction.

## Program Counter Control

The program counter is updated using the `PCWrite` signal.

The PC module itself does not calculate `PC + 1` or branch targets. Instead, the datapath calculates `nextPC`, and the PC loads it when `PCWrite` is high.

Normal instruction sequencing:

```text
nextPC = PC + 1
PCWrite = 1
```

Branch target calculation:

```text
nextPC = PC + SE(Imm4)
PCWrite = 1 if branch condition is true
```

## Preliminary State Transitions

The general FSM flow is:

```text
FETCH → DECODE → EXECUTE
```

After `EXECUTE`, the next state depends on the instruction type.

| Instruction Type | State Flow                                              |
| ---------------- | ------------------------------------------------------- |
| Register ALU     | `FETCH → DECODE → EXECUTE → WRITEBACK → FETCH`          |
| Shift            | `FETCH → DECODE → EXECUTE → WRITEBACK → FETCH`          |
| Immediate        | `FETCH → DECODE → EXECUTE → WRITEBACK → FETCH`          |
| Branch           | `FETCH → DECODE → EXECUTE → FETCH`                      |
| Load             | `FETCH → DECODE → EXECUTE → MEMORY → WRITEBACK → FETCH` |
| Store            | `FETCH → DECODE → EXECUTE → MEMORY → FETCH`             |
| NOP              | `FETCH → DECODE → FETCH`                                |

## Verification Plan

The control unit should be tested using an Icarus Verilog testbench.

The testbench should verify:

* Correct state transitions
* Correct control signals for ALU instructions
* Correct control signals for shift instructions
* Correct control signals for immediate instructions
* Correct control signals for branch instructions
* Correct control signals for load and store instructions
* Correct behavior for `NOP`

The first testbench version should focus on checking that each opcode generates the expected control signals and state transitions.

## Current Status

The control unit has not been implemented yet. This document defines the planned FSM structure and control behavior before Verilog implementation begins.
