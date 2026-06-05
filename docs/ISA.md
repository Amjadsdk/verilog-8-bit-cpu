# Instruction Set Architecture

## Overview

This document describes the instruction set architecture (ISA) for the 8-bit CPU project.

The CPU uses 8-bit instructions. Each instruction is divided into register fields, immediate fields, and an opcode. The opcode identifies the instruction, while the upper instruction bits are interpreted as either register selectors or immediate values depending on the instruction type.

The control unit will use the decoded instruction fields to generate datapath control signals such as `ALUop`, register write enable, memory control signals, and program counter control signals.

## Register Encoding

The CPU currently uses four general-purpose 8-bit registers.

| Register | Encoding |
| -------- | -------- |
| `R0`     | `00`     |
| `R1`     | `01`     |
| `R2`     | `10`     |
| `R3`     | `11`     |

## Main Instruction Format

For most instructions, the 8-bit instruction format is:

```text
[7:6] = RA
[5:4] = RB or Imm2
[3:0] = opcode
```

| Bits    | Field         | Width | Description                                       |
| ------- | ------------- | ----: | ------------------------------------------------- |
| `[7:6]` | `RA`          | 2-bit | Register A; usually first operand and destination |
| `[5:4]` | `RB` / `Imm2` | 2-bit | Register B or 2-bit immediate                     |
| `[3:0]` | `opcode`      | 4-bit | Instruction opcode                                |

For register-register instructions, the instruction usually means:

```text
RA = RA operation RB
```

For example:

```text
ADD R1, R2
```

means:

```text
R1 = R1 + R2
```

## Immediate Fields

The CPU currently uses two immediate formats: `Imm2` and `Imm4`.

| Immediate | Bits    | Extension               | Use                                       |
| --------- | ------- | ----------------------- | ----------------------------------------- |
| `Imm2`    | `[5:4]` | Zero-extended as needed | Shift amount                              |
| `Imm4`    | `[7:4]` | Sign-extended to 8 bits | Small signed constants and branch offsets |

## Imm4 Instruction Format

For Imm4-format instructions, the instruction format is:

```text
[7:4] = Imm4
[3:0] = opcode
```

When an Imm4-format instruction is used, the CPU assumes:

```text
RA = R1
destination register = R1
```

So Imm4 instructions operate on `R1` by default.

## Instruction Decoder Fields

The instruction decoder should expose these fields from the 8-bit instruction:

```text
RA     = instruction[7:6]
RB     = instruction[5:4]
Imm2   = instruction[5:4]
Imm4   = instruction[7:4]
opcode = instruction[3:0]
```

The decoder does not decide the full CPU behavior. It only separates the instruction into fields. The control unit decides how to use those fields based on the opcode.

## Opcode Map

### Register-Register Instructions

| Instruction Bits | Instruction  | Meaning                      |
| ---------------- | ------------ | ---------------------------- |
| `RA RB 0000`     | `ADD RA, RB` | `RA = RA + RB`               |
| `RA RB 0001`     | `SUB RA, RB` | `RA = RA - RB`               |
| `RA RB 0010`     | `AND RA, RB` | `RA = RA & RB`               |
| `RA RB 0011`     | `OR RA, RB`  | `RA = RA \| RB`              |
| `RA RB 0100`     | `XOR RA, RB` | `RA = RA ^ RB`               |
| `RA RB 1000`     | `EQ RA, RB`  | `RA = 1 if RA == RB, else 0` |

### Shift Instructions Using Imm2

Shift instructions use `Imm2` as the shift amount.

Format:

```text
[7:6] = RA
[5:4] = Imm2
[3:0] = opcode
```

| Instruction Bits | Instruction   | Meaning           |
| ---------------- | ------------- | ----------------- |
| `RA Imm2 0101`   | `SL RA, Imm2` | `RA = RA << Imm2` |
| `RA Imm2 0110`   | `SR RA, Imm2` | `RA = RA >> Imm2` |

| Imm2 | Shift Amount |
| ---- | -----------: |
| `00` |            0 |
| `01` |            1 |
| `10` |            2 |
| `11` |            3 |

### Imm4 Instructions

Imm4 instructions use:

```text
[7:4] = Imm4
[3:0] = opcode
```

For these instructions, the CPU assumes:

```text
RA = R1
destination register = R1
```

| Instruction Bits | Instruction     | Meaning                          |
| ---------------- | --------------- | -------------------------------- |
| `Imm4 1001`      | `ADDI R1, Imm4` | `R1 = R1 + SE(Imm4)`             |
| `Imm4 1010`      | `LI R1, Imm4`   | `R1 = SE(Imm4)`                  |
| `Imm4 1011`      | `BNZ Imm4`      | If `Z = 0`, branch by `SE(Imm4)` |
| `Imm4 1100`      | `BPZ Imm4`      | If `N = 0`, branch by `SE(Imm4)` |

`SE(Imm4)` means the 4-bit immediate is sign-extended to 8 bits.

| Imm4   | Sign-Extended Value |
| ------ | ------------------: |
| `0000` |                   0 |
| `0001` |                   1 |
| `0010` |                   2 |
| `0111` |                   7 |
| `1111` |                  -1 |
| `1110` |                  -2 |
| `1000` |                  -8 |

### Memory and Control Instructions

| Instruction Bits | Instruction   | Meaning        |
| ---------------- | ------------- | -------------- |
| `RA RB 1101`     | `LD RA, [RB]` | `RA = MEM[RB]` |
| `RA RB 1110`     | `ST RA, [RB]` | `MEM[RB] = RA` |
| `00 00 1111`     | `NOP`         | Do nothing     |

## Full Opcode Summary

| Opcode | Format           | Instruction     | Meaning                          |
| ------ | ---------------- | --------------- | -------------------------------- |
| `0000` | `RA RB opcode`   | `ADD RA, RB`    | `RA = RA + RB`                   |
| `0001` | `RA RB opcode`   | `SUB RA, RB`    | `RA = RA - RB`                   |
| `0010` | `RA RB opcode`   | `AND RA, RB`    | `RA = RA & RB`                   |
| `0011` | `RA RB opcode`   | `OR RA, RB`     | `RA = RA \| RB`                  |
| `0100` | `RA RB opcode`   | `XOR RA, RB`    | `RA = RA ^ RB`                   |
| `0101` | `RA Imm2 opcode` | `SL RA, Imm2`   | `RA = RA << Imm2`                |
| `0110` | `RA Imm2 opcode` | `SR RA, Imm2`   | `RA = RA >> Imm2`                |
| `0111` | Reserved         | Reserved        | Future use                       |
| `1000` | `RA RB opcode`   | `EQ RA, RB`     | `RA = 1 if RA == RB, else 0`     |
| `1001` | `Imm4 opcode`    | `ADDI R1, Imm4` | `R1 = R1 + SE(Imm4)`             |
| `1010` | `Imm4 opcode`    | `LI R1, Imm4`   | `R1 = SE(Imm4)`                  |
| `1011` | `Imm4 opcode`    | `BNZ Imm4`      | If `Z = 0`, `PC = PC + SE(Imm4)` |
| `1100` | `Imm4 opcode`    | `BPZ Imm4`      | If `N = 0`, `PC = PC + SE(Imm4)` |
| `1101` | `RA RB opcode`   | `LD RA, [RB]`   | `RA = MEM[RB]`                   |
| `1110` | `RA RB opcode`   | `ST RA, [RB]`   | `MEM[RB] = RA`                   |
| `1111` | Control          | `NOP`           | Do nothing                       |

## Instruction Decoder Block Diagram

![Instruction Decoder Block Diagram](docs/images/instruction_decoder_diagram.png)

## Example Encodings

### ADD R1, R2

```text
RA = R1 = 01
RB = R2 = 10
opcode = ADD = 0000
```

Full instruction:

```text
01 10 0000
```

Binary:

```text
01100000
```

Meaning:

```text
R1 = R1 + R2
```

### SUB R3, R1

```text
RA = R3 = 11
RB = R1 = 01
opcode = SUB = 0001
```

Full instruction:

```text
11 01 0001
```

Binary:

```text
11010001
```

Meaning:

```text
R3 = R3 - R1
```

### SL R2, 3

```text
RA = R2 = 10
Imm2 = 3 = 11
opcode = SL = 0101
```

Full instruction:

```text
10 11 0101
```

Binary:

```text
10110101
```

Meaning:

```text
R2 = R2 << 3
```

### LI R1, -2

`-2` as 4-bit two’s complement:

```text
1110
```

Opcode:

```text
LI = 1010
```

Full instruction:

```text
1110 1010
```

Binary:

```text
11101010
```

Meaning:

```text
R1 = SE(1110) = -2
```

### BNZ -1

`-1` as 4-bit two’s complement:

```text
1111
```

Opcode:

```text
BNZ = 1011
```

Full instruction:

```text
1111 1011
```

Binary:

```text
11111011
```

Meaning:

```text
if Z = 0:
    PC = PC + SE(1111)
```

## Current Status

This ISA is the current working instruction format for the CPU project. It may be expanded later as the datapath, control unit, memory, and program counter are implemented.
