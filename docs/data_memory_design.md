# Data Memory Design

## Overview

This document describes the data memory module used in the 8-bit CPU project.

The data memory stores program data during CPU execution. It is separate from instruction memory. Instruction memory stores the program instructions, while data memory stores values that can be read from or written to during execution.

The data memory supports both load and store operations through `MemRead` and `MemWrite` control signals.

## Purpose

The data memory is used by the CPU when executing memory instructions.

The current ISA includes:

```text
LD RA, [RB]
ST RA, [RB]
```

These instructions allow the CPU to move data between the register file and data memory.

Conceptually:

```text
Register File → Data Memory
Data Memory → Register File
```

## Inputs and Outputs

| Signal     | Width | Direction | Description                        |
| ---------- | ----: | --------- | ---------------------------------- |
| `clk`      | 1-bit | Input     | Clock signal                       |
| `MemRead`  | 1-bit | Input     | Enables reading from memory        |
| `MemWrite` | 1-bit | Input     | Enables writing to memory          |
| `address`  | 4-bit | Input     | Selects one of 16 memory locations |
| `dataIn`   | 8-bit | Input     | Data value written into memory     |
| `dataOut`  | 8-bit | Output    | Data value read from memory        |

## Memory Organization

The current data memory is organized as:

```text
16 memory locations × 8 bits
```

Because the address input is 4 bits wide, the memory can address 16 locations:

```text
2^4 = 16 addresses
```

Each location stores one 8-bit value.

## Addressing

The data memory uses a 4-bit address.

The register file stores 8-bit values, so when a register is used as a memory address, the CPU datapath can use the lower 4 bits of that register value.

```text
address = RB[3:0]
```

This keeps the memory small and simple for the first version of the CPU.

## Write Behavior

Writing is clocked.

On the rising edge of `clk`, if `MemWrite` is high, the value on `dataIn` is stored into the selected memory address.

Conceptually:

```text
on rising edge of clk:
    if MemWrite = 1:
        memory[address] = dataIn
```

This is used by the store instruction:

```text
ST RA, [RB]
```

Meaning:

```text
MEM[RB] = RA
```

In the datapath:

```text
address = RB[3:0]
dataIn = RA
MemWrite = 1
```

## Read Behavior

Reading is combinational.

If `MemRead` is high, `dataOut` shows the value stored at the selected memory address.

If `MemRead` is low, `dataOut` outputs zero.

Conceptually:

```text
if MemRead = 1:
    dataOut = memory[address]
else:
    dataOut = 00000000
```

This is used by the load instruction:

```text
LD RA, [RB]
```

Meaning:

```text
RA = MEM[RB]
```

In the datapath:

```text
address = RB[3:0]
MemRead = 1
dataOut is written back to RA
```

## Clocked Write and Combinational Read

The data memory uses two different styles of behavior:

```text
Write = clocked
Read = combinational
```

Writing changes stored memory contents, so it occurs on a clock edge.

Reading only displays a stored value, so it can update whenever `address` or `MemRead` changes.

This is why the module uses separate logic for reading and writing.

## Role in the CPU

The data memory is part of the CPU datapath for load and store instructions.

For a load instruction:

```text
LD RA, [RB]
```

The CPU reads memory at the address stored in `RB` and writes the memory value into `RA`.

For a store instruction:

```text
ST RA, [RB]
```

The CPU writes the value in `RA` into memory at the address stored in `RB`.

The data memory does not store instructions. Program instructions are stored separately in instruction memory.

## Verification

The data memory is tested using an Icarus Verilog testbench.

The testbench currently verifies:

* Writing a value to address `0`
* Reading the value back from address `0`
* Writing a different value to address `5`
* Reading the value back from address `5`
* Confirming that `dataOut` becomes `0` when `MemRead` is disabled

Because writes occur on the rising edge of `clk`, the testbench waits for a positive clock edge before checking written values.

## Running the Data Memory Testbench

```bash
iverilog -s data_memory_tb -o dmem_test src/memory/data_memory.v tb/memory/data_memory_tb.v
vvp dmem_test
```

## Current Status

The data memory has been implemented and tested successfully using terminal-based simulation with Icarus Verilog.

## Block Diagram

![Data Memory Block Diagram](images/data_memory_block_diagram.png)
