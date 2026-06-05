# Verilog 8-bit CPU

This project is an 8-bit CPU built from scratch in Verilog.

## Current Status

### Completed

* 8-bit ALU
* Full adder
* Ripple-carry adder
* Bitwise AND, OR, XOR
* Logical shift left and shift right
* Equality comparison
* ALU testbench using Icarus Verilog
* 8-bit Register
* Register File
* Instruction decoder
* Initial instruction set architecture

### In Progress

* Control unit
* Instruction set design
* Instruction memory
* Program counter
* CPU top module

---

# Instruction Set Architecture

The CPU uses 8-bit instructions.

For most instructions, the instruction format is:

```text
[7:6] = RA
[5:4] = RB or Imm2
[3:0] = opcode
```

For register-register instructions:

```text
RA = destination register and first operand
RB = second operand
opcode = instruction operation
```

This means most register-register instructions follow this pattern:

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

## Register Encoding

| Register | Bits |
| -------- | ---- |
| `R0`     | `00` |
| `R1`     | `01` |
| `R2`     | `10` |
| `R3`     | `11` |

## Immediate Fields

The CPU currently uses two immediate formats: `Imm2` and `Imm4`.

| Immediate | Bits    | Extension               | Use                                       |
| --------- | ------- | ----------------------- | ----------------------------------------- |
| `Imm2`    | `[5:4]` | Zero-extended as needed | Shift amount                              |
| `Imm4`    | `[7:4]` | Sign-extended to 8 bits | Small signed constants and branch offsets |

For `Imm4`-format instructions:

```text
[7:4] = Imm4
[3:0] = opcode
```

When an `Imm4` instruction is used, the CPU assumes:

```text
RA = R1
destination register = R1
```

So `Imm4` instructions operate on `R1` by default.

---

# Opcode Map

## Register-Register Instructions

| Instruction Bits | Instruction  | Meaning                      |
| ---------------- | ------------ | ---------------------------- |
| `RA RB 0000`     | `ADD RA, RB` | `RA = RA + RB`               |
| `RA RB 0001`     | `SUB RA, RB` | `RA = RA - RB`               |
| `RA RB 0010`     | `AND RA, RB` | `RA = RA & RB`               |
| `RA RB 0011`     | `OR RA, RB`  | `RA = RA \| RB`              |
| `RA RB 0100`     | `XOR RA, RB` | `RA = RA ^ RB`               |
| `RA RB 1000`     | `EQ RA, RB`  | `RA = 1 if RA == RB, else 0` |

## Shift Instructions Using Imm2

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

## Imm4 Instructions

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

Examples:

| Imm4   | Sign-Extended Value |
| ------ | ------------------: |
| `0000` |                   0 |
| `0001` |                   1 |
| `0010` |                   2 |
| `0111` |                   7 |
| `1111` |                  -1 |
| `1110` |                  -2 |
| `1000` |                  -8 |

## Memory and Control Instructions

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

---

# Example Encodings

## `ADD R1, R2`

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

## `SL R2, 3`

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

## `LI R1, -2`

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

## `BNZ -1`

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

---

# ALU Design

The ALU takes two 8-bit inputs, `A` and `B`, and a 3-bit operation select signal, `op[2:0]`.

The ALU will eventually be controlled by internal `ALUop` signals generated by the control unit. This allows the CPU instruction opcode to be separate from the ALU operation select signal.

![ALU Block Diagram](docs/images/alu_block_diagram.png)

## ALU Operations

| op    | Operation        |
| ----- | ---------------- |
| `000` | ADD              |
| `001` | SUB              |
| `010` | AND              |
| `011` | OR               |
| `100` | XOR              |
| `101` | Shift Left       |
| `110` | Shift Right      |
| `111` | Equal Comparison |

## Running the ALU Testbench

```bash
iverilog -s alu_8bit_tb -o alu_test src/alu/alu_8bit.v tb/alu/alu_8bit_tb.v
vvp alu_test
```

## ALU Simulation

The ALU was tested using an Icarus Verilog testbench. The testbench checks ADD, SUB, AND, OR, XOR, shift left, shift right, and equality comparison.

![ALU Waveform](docs/images/alu_waveform.png)

---

# Register File Design

The register file stores values used by the CPU datapath. It contains four 8-bit registers: `R0`, `R1`, `R2`, and `R3`.

The register file has one write port and two read ports. This allows the CPU to write one value into a selected register while also reading two register values for ALU operations.

![Register File Block Diagram](docs/images/register_file_block_diagram.png)

### Register File Signals

| Signal        | Width | Direction | Description                                   |
| ------------- | ----: | --------- | --------------------------------------------- |
| `clk`         | 1-bit | Input     | Clock signal                                  |
| `writeEnable` | 1-bit | Input     | Enables writing to a register                 |
| `regW`        | 2-bit | Input     | Selects which register to write to            |
| `dataW`       | 8-bit | Input     | Data value written into the selected register |
| `readA`       | 2-bit | Input     | Selects the register output for `dataA`       |
| `readB`       | 2-bit | Input     | Selects the register output for `dataB`       |
| `dataA`       | 8-bit | Output    | First read data output                        |
| `dataB`       | 8-bit | Output    | Second read data output                       |

### Register Address Mapping

| Address | Register |
| ------- | -------- |
| `00`    | `R0`     |
| `01`    | `R1`     |
| `10`    | `R2`     |
| `11`    | `R3`     |

### Write Behavior

The register file writes data on the rising edge of `clk` when `writeEnable` is high.

The write address `regW` is decoded into four enable signals:

```text
en0 = writeEnable & (regW == 00)
en1 = writeEnable & (regW == 01)
en2 = writeEnable & (regW == 10)
en3 = writeEnable & (regW == 11)
```

## Running the Register File Testbench

```bash
iverilog -s register_file_tb -o rf_test src/registers/register_8bit.v src/registers/register_file.v tb/registers/register_file_tb.v
vvp rf_test
```

## Register File Simulation

The register file was tested using an Icarus Verilog testbench. The testbench checks that values can be written to each register, read through both read ports, and protected from accidental writes when `writeEnable` is disabled.

![Register File Waveform](docs/images/register_file_waveform.png)

---

# Instruction Set Architecture

See [`docs/isa.md`](docs/isa.md) for the current ISA, instruction formats, opcode map, and example encodings.

## Decoder Fields

| Field    | Bits    | Description                                       |
| -------- | ------- | ------------------------------------------------- |
| `RA`     | `[7:6]` | Register A / destination register                 |
| `RB`     | `[5:4]` | Register B or Imm2                                |
| `Imm2`   | `[5:4]` | 2-bit immediate used for shifts                   |
| `Imm4`   | `[7:4]` | 4-bit immediate used for Imm4-format instructions |
| `opcode` | `[3:0]` | 4-bit instruction opcode                          |

## Running the Instruction Decoder Testbench

```bash
iverilog -s instruction_decoder_tb -o decoder_test src/control_unit/instruction_decoder.v tb/control_unit/instruction_decoder_tb.v
vvp decoder_test
```

## Instruction Decoder Simulation

The instruction decoder was tested using an Icarus Verilog testbench. The testbench checks that encoded 8-bit instructions are correctly separated into register fields, immediate fields, and opcode fields.

![Instruction Decoder Waveform](docs/images/instruction_decoder_waveform.png)

---

# Next Steps

Planned next modules:

* Instruction memory
* Program counter
* Control FSM
* Data memory
* CPU top module
* Full CPU testbench

The next major goal is to connect:

```text
Instruction memory → instruction decoder → control unit → register file → ALU → writeback
```

Once these blocks are connected, the CPU should be able to execute a small program using the defined 8-bit ISA.
