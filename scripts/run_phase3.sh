#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p logs

echo "Compiling Phase 3 integration test with Xcelium..."

xrun -64bit -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    -top phase3_tb \
    rtl/bus/apb_regs.sv \
    rtl/power/power_fsm.sv \
    rtl/display/vga_timing_gen.sv \
    rtl/display/pixel_fifo.sv \
    rtl/display/color_converter.sv \
    rtl/display/display_top.sv \
    rtl/top/display_subsystem_top.sv \
    sim/integration/phase3_tb.sv \
    -l logs/phase3_xrun.log

echo "Phase 3 simulation completed."
