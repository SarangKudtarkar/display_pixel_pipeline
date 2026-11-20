# Display Pixel Pipeline Validation Environment

## Project overview

A SystemVerilog-based display pixel pipeline verification project combining
an APB-programmable display subsystem, UVM simulation, functional coverage,
and formal property checking.

## Project components

- Display timing generation and pixel datapath
- Pixel FIFO and color conversion
- APB register interface and subsystem integration
- SystemVerilog Assertions
- UVM-based verification environment
- Functional coverage and regression scripts
- JasperGold formal verification setup
- Python-based log triage and project status reporting

## Verification evidence

Record the exact simulator/formal tool versions, commands, run dates,
and results here. Include links or screenshots for:

- UVM regression summary
- Functional coverage report
- JasperGold proof summary and any reviewed counterexamples

Do not claim a phase passed unless its actual run output supports that claim.

## Automation

Run `python3 scripts/phase8_triage.py` from the project root to regenerate:

- `docs/phase8_project_status.md`
- `docs/phase8_project_status.json`
