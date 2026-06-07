# Instruction Memory Design

## Overview

This document describes the instruction memory module used in the 8-bit CPU project.

The instruction memory stores the program instructions that the CPU will execute. It takes a 4-bit address as input and outputs the 8-bit instruction stored at that address.

In the full CPU, the program counter will provide the address to instruction memory. The instruction memory will then output the instruction to be decoded and executed by the rest of the CPU datapath.

## Purpose

The instruction memory is responsible for storing the CPU program.

Conceptually:

```text
Program Counter → Instruction Memory → Instruction Decoder
```

The program counter selects the instruction address, and the instruction memory outputs the corresponding 8-bit instruction.

## Inputs and Outputs

| Signal        | Width | Direction | Description                                |
| ------------- | ----: | --------- | ------------------------------------------ |
| `address`     | 4-bit | Input     | Selects one of 16 instruction locations    |
| `instruction` | 8-bit | Output    | Instruction stored at the selected address |

## Memory Organization

The current instruction memory is organized as:

```text
16 instruction locations × 8 bits
```

Because the address input is 4 bits wide, the instruction memory can address 16 locations:

```text
2^4 = 16 addresses
```

Each memory location stores one 8-bit instruction.

## Current Program

For the current version of the module, the instruction memory is hardcoded with a small test program.

| Address | Instruction   | Binary     | Meaning                                          |
| ------- | ------------- | ---------- | ------------------------------------------------ |
| `0000`  | `LI R1, 3`    | `00111010` | Load the value `3` into `R1`                     |
| `0001`  | `ADD R1, R2`  | `01100000` | `R1 = R1 + R2`                                   |
| `0010`  | `ST R1, [R0]` | `01001110` | Store `R1` into memory at address stored in `R0` |
| `0011`  | `NOP`         | `00001111` | Do nothing                                       |

All other addresses currently output `NOP` by default.

## Default Instruction

The default instruction is:

```text
NOP = 00001111
```

If the instruction memory receives an address that is not explicitly programmed, it outputs `NOP`.

This prevents undefined instruction values and gives the CPU a safe instruction to execute when no program instruction is stored at that address.

## Hardcoded ROM Design

The current instruction memory is implemented as a hardcoded ROM using a `case` statement.

For example:

```text
address 0000 → LI R1, 3
address 0001 → ADD R1, R2
address 0010 → ST R1, [R0]
address 0011 → NOP
default      → NOP
```

This approach is simple and useful for early CPU testing because the program is directly visible in the Verilog module.

## Future Improvement

Although the instruction memory is hardcoded for now, this is not the final plan.

Later, the instruction memory should be changed so that programs can be loaded from an external program file instead of being manually written into the Verilog module.

A future version may use a memory array and load instructions from a `.mem` file, such as:

```text
programs/test_program.mem
```

This would allow the CPU to run different programs without editing the Verilog source code.

The future workflow would be:

```text
Edit program file → run simulation → CPU executes new program
```

instead of:

```text
Edit instruction_memory.v → recompile → run simulation
```

## Role in the CPU

In the full CPU, instruction memory will connect to the program counter and instruction decoder.

The expected flow is:

```text
PC provides address
Instruction memory outputs instruction
Instruction decoder separates instruction fields
Control unit generates control signals
Datapath executes instruction
```

So the instruction memory is the first major block in the instruction fetch stage.

## Verification

The instruction memory is tested using an Icarus Verilog testbench.

The testbench checks that each programmed address returns the correct 8-bit instruction.

The testbench currently verifies:

* Address `0000` outputs `LI R1, 3`
* Address `0001` outputs `ADD R1, R2`
* Address `0010` outputs `ST R1, [R0]`
* Address `0011` outputs `NOP`
* An unprogrammed address outputs the default `NOP`

## Running the Instruction Memory Testbench

```bash
iverilog -s instruction_memory_tb -o imem_test src/memory/instruction_memory.v tb/memory/instruction_memory_tb.v
vvp imem_test
```

## Current Status

The instruction memory has been implemented as a simple hardcoded ROM and tested successfully using terminal-based simulation with Icarus Verilog.

## Block Diagram

![Instruction Memory Block Diagram](images/instruction_memory_block_diagram.png)
