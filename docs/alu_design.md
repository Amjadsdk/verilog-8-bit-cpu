# ALU Design

## Overview

This document describes the 8-bit Arithmetic Logic Unit (ALU) used as the first major component of the 8-bit CPU project.

The ALU takes two 8-bit inputs, `A` and `B`, and a 3-bit operation select signal, `op[2:0]`. Based on the operation select value, the ALU produces an 8-bit output `S` and a carry-out signal `Co`.

## Inputs and Outputs

| Signal | Width | Direction | Description                         |
| ------ | ----: | --------- | ----------------------------------- |
| `A`    | 8-bit | Input     | First operand                       |
| `B`    | 8-bit | Input     | Second operand                      |
| `op`   | 3-bit | Input     | Operation select signal             |
| `S`    | 8-bit | Output    | ALU result                          |
| `Co`   | 1-bit | Output    | Carry-out for arithmetic operations |

## Supported Operations

| `op[2:0]` | Operation        | Description                                          |
| --------- | ---------------- | ---------------------------------------------------- |
| `000`     | ADD              | Adds `A + B`                                         |
| `001`     | SUB              | Subtracts `B` from `A`                               |
| `010`     | AND              | Bitwise AND                                          |
| `011`     | OR               | Bitwise OR                                           |
| `100`     | XOR              | Bitwise XOR                                          |
| `101`     | Shift Left       | Logical shift left of `A` by 1                       |
| `110`     | Shift Right      | Logical shift right of `A` by 1                      |
| `111`     | Equal Comparison | Outputs `00000001` if `A == B`, otherwise `00000000` |

## Arithmetic Design

The ADD operation uses an 8-bit ripple-carry adder built from 1-bit full adders.

The SUB operation reuses the same ripple-carry adder idea by using two’s complement subtraction:

```text
A - B = A + (~B) + 1
```

This means subtraction can be implemented by inverting `B` and setting the initial carry-in to `1`.

## Logic Operations

The AND, OR, and XOR operations are implemented as bitwise operations across the full 8-bit inputs.

For example:

```text
S[7:0] = A[7:0] & B[7:0]
```

## Shift Operations

The shift-left and shift-right operations are logical shifts by one bit.

For shift left:

```text
S = A << 1
```

For shift right:

```text
S = A >> 1
```

## Equality Comparison

The equality comparison checks whether all bits of `A` and `B` are equal.

If the values are equal:

```text
S = 00000001
```

If the values are not equal:

```text
S = 00000000
```

Only the least significant bit is used to represent the Boolean equality result. The upper seven bits are set to zero.

## Output Selection

Each operation produces its own 8-bit result. The final ALU output is selected using an 8-to-1 multiplexer controlled by `op[2:0]`.

## Verification

The ALU is tested using an Icarus Verilog testbench. The testbench applies input values for each supported operation and checks the actual output against the expected output.

The testbench currently verifies:

* ADD
* SUB
* AND
* OR
* XOR
* Shift left
* Shift right
* Equal comparison
* Not-equal comparison

## Current Status

The ALU has been implemented and tested successfully using terminal-based simulation with Icarus Verilog.

## Block Diagram

![ALU Block Diagram](images/alu_block_diagram.png)