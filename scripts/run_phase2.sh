#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v xrun >/dev/null 2>&1; then
    echo "ERROR: xrun not found. Source your Xcelium environment."
    exit 1
fi

mkdir -p logs

xrun -64bit -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    rtl/bus/apb_regs.sv \
    sim/apb/apb_tb.sv \
    -top apb_tb \
    -l logs/phase2_apb.log

if grep -q "PHASE2_APB_PASS" logs/phase2_apb.log; then
    echo "PHASE 2 APB TEST PASSED"
else
    echo "ERROR: PHASE 2 PASS marker not found"
    exit 1
fi
