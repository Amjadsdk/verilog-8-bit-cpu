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

### In Progress
- Register file
- Control unit
- Instruction set design
- CPU top module

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