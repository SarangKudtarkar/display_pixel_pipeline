#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

mkdir -p regression/logs

xrun -64bit -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    -f sim/xcelium/filelist.f \
    -l regression/logs/xcelium.log

python3 scripts/triage.py regression/logs/xcelium.log
