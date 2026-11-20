#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p logs

REQUIRED_FILES=(
    rtl/bus/apb_regs.sv
    rtl/power/power_fsm.sv
    rtl/display/vga_timing_gen.sv
    rtl/display/pixel_fifo.sv
    rtl/display/color_converter.sv
    rtl/display/display_top.sv
    rtl/top/display_subsystem_top.sv
    sim/integration/phase3_tb.sv
    sva/display_sva_checker.sv
    sva/display_subsystem_bind.sv
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file missing: $file"
        exit 1
    fi
done

echo "=================================================="
echo "PHASE 4: SVA ASSERTION SIMULATION"
echo "=================================================="

xrun -64bit -sv \
    -assert \
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
    sva/display_sva_checker.sv \
    sva/display_subsystem_bind.sv \
    sim/integration/phase3_tb.sv \
    -l logs/phase4_xrun.log

echo
echo "=================================================="
echo "PHASE 4 SIMULATION COMPLETED"
echo "=================================================="

if grep -q "PHASE3_INTEGRATION_PASS" logs/phase4_xrun.log; then
    echo "PHASE 3 TESTBENCH: PASS"
else
    echo "WARNING: Phase 3 pass marker not found in log."
fi

if grep -qi "SVA ERROR" logs/phase4_xrun.log; then
    echo "SVA CHECKS: FAILURE DETECTED"
    exit 1
else
    echo "SVA CHECKS: No assertion error messages found."
fi

echo "PHASE4_SVA_RUN_COMPLETED"
