# Register File Design

## Overview

This document describes the 4-register, 8-bit register file used as a major component of the 8-bit CPU project.

The register file stores data values that can be used as operands for the ALU and can also store results produced by the ALU. It contains four 8-bit registers: `R0`, `R1`, `R2`, and `R3`.

The register file has one write port and two read ports. This allows one register to be written on a clock edge while two register values can be read as outputs.

## Inputs and Outputs

| Signal        | Width | Direction | Description                                   |
| ------------- | ----: | --------- | --------------------------------------------- |
| `readA`       | 2-bit | Input     | Selects which register appears on `dataA`     |
| `readB`       | 2-bit | Input     | Selects which register appears on `dataB`     |
| `regW`        | 2-bit | Input     | Selects which register is written to          |
| `dataW`       | 8-bit | Input     | Data value written into the selected register |
| `writeEnable` | 1-bit | Input     | Enables writing to the selected register      |
| `clk`         | 1-bit | Input     | Clock signal                                  |
| `dataA`       | 8-bit | Output    | First read data output                        |
| `dataB`       | 8-bit | Output    | Second read data output                       |

## Register Organization

The register file contains four 8-bit registers.

| Register | Width | Description        |
| -------- | ----: | ------------------ |
| `R0`     | 8-bit | General register 0 |
| `R1`     | 8-bit | General register 1 |
| `R2`     | 8-bit | General register 2 |
| `R3`     | 8-bit | General register 3 |

Each register stores one 8-bit value. In the current design, all four registers are writable.

## Register Address Mapping

The register file uses 2-bit addresses to select one of the four registers.

| Address | Register |
| ------- | -------- |
| `00`    | `R0`     |
| `01`    | `R1`     |
| `10`    | `R2`     |
| `11`    | `R3`     |

The same address encoding is used for `readA`, `readB`, and `regW`.

## Write Design

The register file has one write port. The write address `regW` selects which register should store the value from `dataW`.

Writing only occurs when `writeEnable` is high. The write operation happens on the rising edge of `clk`.

The write enable logic is implemented by decoding `regW` into four individual register enable signals:

```text
en0 = writeEnable & (regW == 00)
en1 = writeEnable & (regW == 01)
en2 = writeEnable & (regW == 10)
en3 = writeEnable & (regW == 11)
```

Only one register enable signal should be active at a time.

The same `dataW` bus is connected to the data input of all four registers, but only the selected register stores the value on the clock edge.

## Read Design

The register file has two independent read ports.

The first read port uses `readA` to select which register value appears on `dataA`.

The second read port uses `readB` to select which register value appears on `dataB`.

This allows two register values to be read at the same time. This is useful for ALU operations that require two operands.

For example:

```text
dataA = R1
dataB = R2
ALU result = dataA + dataB
```

## Read Port Selection

The `dataA` output is selected using a 4-to-1 multiplexer controlled by `readA`.

| `readA` | `dataA` Output |
| ------- | -------------- |
| `00`    | `R0`           |
| `01`    | `R1`           |
| `10`    | `R2`           |
| `11`    | `R3`           |

The `dataB` output is selected using a second 4-to-1 multiplexer controlled by `readB`.

| `readB` | `dataB` Output |
| ------- | -------------- |
| `00`    | `R0`           |
| `01`    | `R1`           |
| `10`    | `R2`           |
| `11`    | `R3`           |

## 8-bit Register Design

Each register in the register file is built using an 8-bit register module.

The 8-bit register has:

| Signal   | Width | Direction | Description                   |
| -------- | ----: | --------- | ----------------------------- |
| `D`      | 8-bit | Input     | Data input                    |
| `Q`      | 8-bit | Output    | Stored data output            |
| `enable` | 1-bit | Input     | Allows the register to update |
| `clk`    | 1-bit | Input     | Clock signal                  |

On the rising edge of `clk`, if `enable` is high, the register stores the value on `D`.

Conceptually:

```text
if enable = 1 on rising edge of clk:
    Q becomes D
else:
    Q keeps its previous value
```

## Register File Role in the CPU

The register file is part of the CPU datapath. It provides operands to the ALU and stores results after ALU operations.

A simple CPU operation can be described as:

```text
Read two registers → send values to ALU → write ALU result back to register file
```

For example:

```text
R3 = R1 + R2
```

This would mean:

```text
readA selects R1
readB selects R2
ALU performs ADD
regW selects R3
dataW receives the ALU result
writeEnable allows R3 to store the result
```

## Verification

The register file is tested using an Icarus Verilog testbench. The testbench applies write and read operations and checks the actual outputs against expected values.

The testbench currently verifies:

* Writing to `R0`
* Writing to `R1`
* Writing to `R2`
* Writing to `R3`
* Reading two registers at the same time
* Preventing writes when `writeEnable = 0`
* Overwriting an existing register value

Because the register file uses clocked storage, write operations are checked after the rising edge of `clk`.

## Current Status

The 8-bit register and 4-register register file have been implemented and tested successfully using terminal-based simulation with Icarus Verilog.

## Block Diagram

![Register File Block Diagram](images/register_file_block_diagram.png)
