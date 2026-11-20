# Display Pixel Pipeline — Automated Project Status

Generated: 2026-11-20T07:17:51

## Verification evidence

| Phase | Automated finding |
|---|---|
| Phase 5 — UVM | NOT RUN — completion marker not found |
| Phase 6 — Coverage/regression | NOT RUN — completion marker not found |
| Phase 7 — JasperGold formal | NOT RUN — no formal logs/reports found |

## Log scan

- Text log/report files scanned: 0
- UVM_ERROR counts found: 0
- UVM_FATAL counts found: 0

> Counts are aggregated across scanned files and may include repeated or historical runs. Review the individual logs before treating them as a final regression result.

## RTL source inventory

- `rtl/apb/apb_regs.sv`
- `rtl/bus/apb_regs.sv`
- `rtl/common/display_pkg.sv`
- `rtl/display/color_converter.sv`
- `rtl/display/display_top.sv`
- `rtl/display/pixel_fifo.sv`
- `rtl/display/vga_timing_gen.sv`
- `rtl/pixel/color_convert.sv`
- `rtl/pixel/pixel_fifo.sv`
- `rtl/power/power_ctrl.sv`
- `rtl/power/power_fsm.sv`
- `rtl/timing/vga_timing_gen.sv`
- `rtl/top/display_subsystem_top.sv`
- `rtl/top/display_top.sv`

## UVM source inventory

- `sim/uvm/apb_if.sv`
- `sim/uvm/display_uvm_pkg.sv`
- `sim/uvm/phase5_uvm_tb.sv`

## Scanned log files

- No matching log files found.

## Review checklist

- [ ] Confirm Phase 5 UVM summary and zero-error/fatal result in its run log.
- [ ] Confirm Phase 6 coverage report exists and inspect covered/ uncovered bins.
- [ ] Confirm Phase 7 JasperGold proof results and review every unproven property.
- [ ] Add screenshots of waveforms, coverage, and formal results to the portfolio.
- [ ] Update the project README with tool versions and exact run commands.

This report is generated from files present at scan time. It does not run simulations, calculate functional coverage, or prove properties.
