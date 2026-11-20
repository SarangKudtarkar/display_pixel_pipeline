#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOG="logs/phase7_formal.log"
REPORT="logs/phase7_formal_report.txt"

mkdir -p logs

echo "================================================"
echo "PHASE 7 - JASPERGOLD FORMAL VERIFICATION"
echo "================================================"

REQUIRED_FILES=(
    rtl/bus/apb_regs.sv
    rtl/display/vga_timing_gen.sv
    rtl/display/pixel_fifo.sv
    rtl/display/color_converter.sv
    rtl/display/display_top.sv
    rtl/top/display_subsystem_top.sv
    formal/display_properties.sv
    formal/display_formal_top.sv
    formal/phase7.tcl
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Missing file: $file"
        exit 1
    fi
done

# Ensure the corrected command is present.
if ! grep -Fqx \
    "elaborate -top display_formal_top" formal/phase7.tcl; then
    echo "ERROR: Incorrect elaboration command."
    exit 1
fi

if grep -Fq 'elaborate $TOP' formal/phase7.tcl; then
    echo "ERROR: Old elaboration command detected."
    exit 1
fi

if command -v jg >/dev/null 2>&1; then
    JASPER_CMD="jg"
elif command -v jaspergold >/dev/null 2>&1; then
    JASPER_CMD="jaspergold"
else
    echo "ERROR: JasperGold executable not found."
    echo "Load the Cadence JasperGold environment."
    exit 1
fi

rm -f "$LOG" "$REPORT"

echo "Using: $JASPER_CMD"
echo "Formal top: display_formal_top"
echo "Elaboration: elaborate -top display_formal_top"

set +e

if [[ "$JASPER_CMD" == "jg" ]]; then
    jg -batch formal/phase7.tcl 2>&1 | tee "$LOG"
    STATUS=${PIPESTATUS[0]}
else
    jaspergold -batch -tcl formal/phase7.tcl 2>&1 | tee "$LOG"
    STATUS=${PIPESTATUS[0]}
fi

set -e

if [[ "$STATUS" -ne 0 ]]; then
    echo "ERROR: JasperGold execution failed."
    echo "Check $LOG"
    exit 1
fi

if [[ ! -f "$REPORT" ]]; then
    echo "WARNING: Formal report was not generated."
    echo "Check $LOG"
    exit 1
fi

echo
echo "================================================"
echo "PHASE 7 EXECUTION COMPLETED"
echo "================================================"
echo "Log:    $LOG"
echo "Report: $REPORT"
echo
echo "Inspect assertion results before declaring PASS."
