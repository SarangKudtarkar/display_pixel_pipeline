# Display Pixel Pipeline Validation Environment

## Overview

A small display controller and pixel pipeline verification project.

### DUT blocks

- APB configuration register block
- VGA timing generator
- Pixel FIFO
- Pixel format converter
- Power management FSM
- Display output interface

### Verification goals

- APB register read/write verification
- Horizontal and vertical timing verification
- Pixel active-region checking
- FIFO underrun and overflow testing
- Mid-frame configuration testing
- Low-power entry and wake-up testing
- SVA-based protocol checking
- JasperGold formal verification
- Python regression log triage

## Tools

- SystemVerilog
- UVM
- Cadence Xcelium
- Cadence JasperGold
- SimVision / Verisium Debug
- Python 3

## Initial implementation status

This repository is a starter scaffold. The UVM monitor, APB agent,
reference model, scoreboard, functional coverage, and constrained-random
sequences must be implemented and connected before claiming UVM coverage.

The formal properties also require complete assumptions, reset handling,
and proof review before claiming formal sign-off.

## Build

```bash
make help
make sim
make triage
```

Requires a licensed Cadence installation and configured tool environment.

## Planned milestones

1. Complete synthesizable RTL and register specification.
2. Build APB UVM agent and output monitor.
3. Implement reference model and scoreboard.
4. Add directed and constrained-random sequences.
5. Add assertions and functional coverage.
6. Prove timing and power FSM properties.
7. Automate regression and failure triage.
8. Document debug findings and coverage closure.
