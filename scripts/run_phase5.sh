#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p logs

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
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Missing required file: $file"
        exit 1
    fi
done

echo "=================================================="
echo "PHASE 5: UVM VERIFICATION"
echo "=================================================="

xrun -64bit -uvm -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    -uvmhome CDNS-1.1d \
    -top phase5_uvm_tb \
    rtl/bus/apb_regs.sv \
    rtl/display/vga_timing_gen.sv \
    rtl/display/pixel_fifo.sv \
    rtl/display/color_converter.sv \
    rtl/display/display_top.sv \
    rtl/top/display_subsystem_top.sv \
    sim/uvm/apb_if.sv \
    sim/uvm/display_uvm_pkg.sv \
    sim/uvm/phase5_uvm_tb.sv \
    -l logs/phase5_uvm.log

echo
echo "Checking Phase 5 results..."

LOG="logs/phase5_uvm.log"

if ! grep -q "PHASE5_UVM_SEQUENCE_COMPLETED" "$LOG"; then
    echo "ERROR: UVM sequence completion marker not found."
    exit 1
fi

# Read the numeric UVM summary counts.
ERROR_COUNT=$(
    sed -nE 's/.*UVM_ERROR[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$LOG" |
    tail -1
)

FATAL_COUNT=$(
    sed -nE 's/.*UVM_FATAL[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$LOG" |
    tail -1
)

if [[ -z "$ERROR_COUNT" || -z "$FATAL_COUNT" ]]; then
    echo "ERROR: Could not find UVM error/fatal summary counts."
    exit 1
fi

if (( ERROR_COUNT > 0 )); then
    echo "ERROR: UVM reported ${ERROR_COUNT} errors."
    exit 1
fi

if (( FATAL_COUNT > 0 )); then
    echo "ERROR: UVM reported ${FATAL_COUNT} fatal errors."
    exit 1
fi

echo
grep -E '\[APB_SB\].*SUMMARY' "$LOG" || true
echo "UVM errors: ${ERROR_COUNT}"
echo "UVM fatals: ${FATAL_COUNT}"
echo
echo "PHASE5_UVM_RUN_COMPLETED"
echo "PHASE5_UVM_PASS"

