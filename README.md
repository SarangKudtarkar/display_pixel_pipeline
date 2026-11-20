# Display Pixel Pipeline Validation Environment

## Project Overview

A SystemVerilog-based display pixel pipeline verification environment
using Xcelium, UVM, SystemVerilog Assertions, JasperGold, and Python.

## Design Features

- VGA timing generation
- Pixel FIFO
- Color conversion
- APB programmable register interface
- Display subsystem integration
- Configurable display timing

## Verification Features

- APB register read/write verification
- UVM-based testbench
- SystemVerilog Assertions
- Functional coverage
- Regression automation
- JasperGold formal verification
- Python-based log triage

## Project Structure

- `rtl/` — RTL design
- `sim/uvm/` — UVM verification environment
- `formal/` — Formal verification sources
- `scripts/` — Simulation and automation scripts
- `logs/` — Simulation and formal logs
- `docs/` — Project documentation
- `cov_work/` — Coverage database

## Verification Status

- Phase 5: UVM completion marker detected
- Phase 6: Coverage database generated; coverage results require review
- Phase 7: Formal log generated; individual proof results require review
- Phase 8: Python log triage completed

## Tools

- SystemVerilog
- UVM
- Synopsys VCS/Xcelium-compatible simulation workflow (record the actual simulator used)
- Cadence JasperGold
- Python 3
- Linux

## Execution

See the scripts in `scripts/` and phase documentation in `docs/`
for the exact commands and tool requirements.

## Author Notes

Add your architecture diagram, simulation waveform screenshots,
coverage summary, and JasperGold proof summary before publishing.

## Architecture Diagram

```mermaid
flowchart TB
    TB["UVM Testbench"]

    subgraph DUT["Display Subsystem"]
        APB["APB Register Interface"]
        REG["Display Configuration Registers"]
        ENABLE["Display Enable Control"]

        subgraph PIPE["Display Pixel Pipeline"]
            TIMING["VGA Timing Generator"]
            FIFO["Pixel FIFO"]
            COLOR["Color Converter"]
        end

        OUTPUT["Display Outputs"]
    end

    TB -->|"APB Read/Write"| APB
    APB --> REG
    REG -->|"Timing Configuration"| TIMING
    REG -->|"Pixel Format"| COLOR
    REG --> ENABLE
    TIMING -->|"Pixel Coordinates and Sync"| OUTPUT
    TIMING -->|"Active Video"| ENABLE
    ENABLE -->|"Gated Active Video"| OUTPUT

    SOURCE["Pixel Data Source"] -->|"Pixel Data"| FIFO
    FIFO -->|"Buffered Pixels"| COLOR
    COLOR -->|"Converted Pixel Data"| OUTPUT
    OUTPUT -->|"Display Status"| TB

    ASSERT["SVA Assertions"] -.-> DUT
    FORMAL["JasperGold Formal Verification"] -.-> DUT
