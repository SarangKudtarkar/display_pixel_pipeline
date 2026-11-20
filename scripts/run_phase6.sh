#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOG="logs/phase6_coverage.log"
COV_DIR="cov_work/phase6"

mkdir -p logs cov_work

REQUIRED_FILES=(
    rtl/bus/apb_regs.sv
    rtl/display/vga_timing_gen.sv
    rtl/display/pixel_fifo.sv
    rtl/display/color_converter.sv
    rtl/display/display_top.sv
    rtl/top/display_subsystem_top.sv
    sim/uvm/apb_if.sv
    sim/uvm/display_uvm_pkg.sv
    sim/uvm/phase5_uvm_tb.sv
    sim/coverage/display_phase6_coverage.sv
)

echo "================================================"
echo "PHASE 6: FUNCTIONAL COVERAGE"
echo "================================================"

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

if ! command -v xrun >/dev/null 2>&1; then
    echo "ERROR: Xcelium xrun command not found."
    exit 1
fi

rm -f "$LOG"

echo "Starting coverage-enabled UVM simulation..."

xrun -64bit -uvm -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    -uvmhome CDNS-1.1d \
    -coverage all \
    -covoverwrite \
    -covworkdir "$COV_DIR" \
    -covtest phase6 \
    -top phase5_uvm_tb \
    rtl/bus/apb_regs.sv \
    rtl/display/vga_timing_gen.sv \
    rtl/display/pixel_fifo.sv \
    rtl/display/color_converter.sv \
    rtl/display/display_top.sv \
    rtl/top/display_subsystem_top.sv \
    sim/coverage/display_phase6_coverage.sv \
    sim/uvm/apb_if.sv \
    sim/uvm/display_uvm_pkg.sv \
    sim/uvm/phase5_uvm_tb.sv \
    -l "$LOG"

echo
echo "Checking Phase 6 results..."

if ! grep -q "PHASE5_UVM_SEQUENCE_COMPLETED" "$LOG"; then
    echo "ERROR: UVM sequence completion marker not found."
    exit 1
fi

ERROR_COUNT=$(
    sed -nE 's/.*UVM_ERROR[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$LOG" |
    tail -1
)

FATAL_COUNT=$(
    sed -nE 's/.*UVM_FATAL[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$LOG" |
    tail -1
)

if [[ -z "$ERROR_COUNT" || -z "$FATAL_COUNT" ]]; then
    echo "ERROR: Could not read UVM error/fatal summary."
    echo "Check $LOG"
    exit 1
fi

if (( ERROR_COUNT > 0 || FATAL_COUNT > 0 )); then
    echo "ERROR: UVM errors=$ERROR_COUNT fatals=$FATAL_COUNT"
    exit 1
fi

echo
echo "================================================"
echo "PHASE 6 SIMULATION PASS"
echo "================================================"
echo "UVM errors : $ERROR_COUNT"
echo "UVM fatals : $FATAL_COUNT"
echo "Coverage database: $COV_DIR"
echo "Simulation log   : $LOG"
echo
echo "NOTE: Simulation pass does not by itself mean"
echo "that all functional coverage goals were hit."
