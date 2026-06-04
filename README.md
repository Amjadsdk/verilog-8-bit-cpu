# Verilog 8-bit CPU

This project is an 8-bit CPU built from scratch in Verilog.

## Current Status

### Completed
- 8-bit ALU
- Full adder
- Ripple-carry adder
- Bitwise AND, OR, XOR
- Logical shift left and shift right
- Equality comparison
- ALU testbench using Icarus Verilog
- 8-bit Register
- Register File

### In Progress
- Control unit
- Instruction set design
- CPU top module

## ALU Design

The ALU takes two 8-bit inputs, `A` and `B`, and a 3-bit operation select signal, `op[2:0]`.

![ALU Block Diagram](docs/images/alu_block_diagram.png)

## ALU Operations

| op | Operation |
|---|---|
| 000 | ADD |
| 001 | SUB |
| 010 | AND |
| 011 | OR |
| 100 | XOR |
| 101 | Shift Left |
| 110 | Shift Right |
| 111 | Equal Comparison |

## Running the ALU Testbench

```bash
iverilog -s alu_8bit_tb -o alu_test src/alu/alu_8bit.v tb/alu/alu_8bit_tb.v
vvp alu_test
```

## ALU Simulation

The ALU was tested using an Icarus Verilog testbench. The testbench checks ADD, SUB, AND, OR, XOR, shift left, shift right, and equality comparison.

![ALU Waveform](docs/images/alu_waveform.png)

## Register File Design

The register file stores values used by the CPU datapath. It contains four 8-bit registers: `R0`, `R1`, `R2`, and `R3`.

The register file has one write port and two read ports. This allows the CPU to write one value into a selected register while also reading two register values for ALU operations.

![Register File Block Diagram](docs/images/register_file_block_diagram.png)

### Register File Signals

| Signal | Width | Direction | Description |
|---|---:|---|---|
| `clk` | 1-bit | Input | Clock signal |
| `writeEnable` | 1-bit | Input | Enables writing to a register |
| `regW` | 2-bit | Input | Selects which register to write to |
| `dataW` | 8-bit | Input | Data value written into the selected register |
| `readA` | 2-bit | Input | Selects the register output for `dataA` |
| `readB` | 2-bit | Input | Selects the register output for `dataB` |
| `dataA` | 8-bit | Output | First read data output |
| `dataB` | 8-bit | Output | Second read data output |

### Register Address Mapping

| Address | Register |
|---|---|
| `00` | `R0` |
| `01` | `R1` |
| `10` | `R2` |
| `11` | `R3` |

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