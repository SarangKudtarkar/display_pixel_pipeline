#!/usr/bin/env python3
"""Summarise available simulation and formal logs without assuming success."""

from pathlib import Path
from datetime import datetime
import json
import re

ROOT = Path(__file__).resolve().parents[1]
LOG_DIR = ROOT / "logs"
REPORT_DIR = ROOT / "docs"
REPORT = REPORT_DIR / "phase8_project_status.md"
STATUS_JSON = REPORT_DIR / "phase8_project_status.json"

# Include JasperGold session logs when they exist.
search_roots = [LOG_DIR, ROOT / "jgproject" / "sessionLogs"]
files = []
for folder in search_roots:
    if folder.exists():
        files.extend(p for p in folder.rglob("*") if p.is_file())

# Only inspect likely text logs/reports.
files = sorted({
    p for p in files
    if p.suffix.lower() in {
        ".log", ".txt", ".rpt", ".out", ".err", ".v", ".html"
    }
})

contents = {}
for path in files:
    try:
        contents[path] = path.read_text(errors="replace")
    except OSError:
        continue

all_text = "\n".join(contents.values())

def numeric_count(pattern):
    values = re.findall(pattern, all_text, flags=re.IGNORECASE)
    return sum(int(v) for v in values)

uvm_errors = numeric_count(r"\bUVM_ERROR\s*:\s*(\d+)")
uvm_fatals = numeric_count(r"\bUVM_FATAL\s*:\s*(\d+)")

def matching_files(pattern):
    rx = re.compile(pattern, re.IGNORECASE)
    return [p for p, text in contents.items() if rx.search(text)]

def simulation_status(marker):
    hits = matching_files(marker)
    if not hits:
        return "NOT RUN — completion marker not found"
    if uvm_errors or uvm_fatals:
        return f"REVIEW — UVM errors={uvm_errors}, fatals={uvm_fatals}"
    return "COMPLETION MARKER FOUND — inspect log for full pass criteria"

phase5 = simulation_status(r"PHASE5_UVM_SEQUENCE_COMPLETED")
phase6 = simulation_status(r"PHASE6.*COMPLETED|PHASE6.*PASS")

formal_hits = matching_files(
    r"\b(PROVEN|PROOF SUCCESS|COUNTEREXAMPLE|UNPROVEN|FAILED|FAIL)\b"
)
formal_text = "\n".join(contents[p] for p in formal_hits)
if not any("jgproject" in str(p) or "formal" in str(p).lower()
           for p in contents):
    phase7 = "NOT RUN — no formal logs/reports found"
elif re.search(r"COUNTEREXAMPLE|UNPROVEN|FAILED|\bFAIL\b",
               formal_text, re.IGNORECASE):
    phase7 = "REVIEW — failure or unproven property text found"
elif re.search(r"PROVEN|PROOF SUCCESS", formal_text, re.IGNORECASE):
    phase7 = "PROOF INDICATOR FOUND — inspect JasperGold report"
else:
    phase7 = "REVIEW — formal logs found, result not automatically classified"

rtl_files = sorted((ROOT / "rtl").rglob("*.sv")) if (ROOT / "rtl").exists() else []
uvm_files = sorted((ROOT / "sim" / "uvm").rglob("*")) if (ROOT / "sim" / "uvm").exists() else []
uvm_files = [p for p in uvm_files if p.is_file()]

status = {
    "generated_at": datetime.now().isoformat(timespec="seconds"),
    "project": ROOT.name,
    "phase5": phase5,
    "phase6": phase6,
    "phase7": phase7,
    "uvm_error_count_across_scanned_logs": uvm_errors,
    "uvm_fatal_count_across_scanned_logs": uvm_fatals,
    "scanned_log_count": len(contents),
    "rtl_systemverilog_files": [str(p.relative_to(ROOT)) for p in rtl_files],
    "uvm_files": [str(p.relative_to(ROOT)) for p in uvm_files],
    "scanned_logs": [str(p.relative_to(ROOT)) for p in contents],
}

STATUS_JSON.write_text(json.dumps(status, indent=2) + "\n")

lines = [
    "# Display Pixel Pipeline — Automated Project Status",
    "",
    f"Generated: {status['generated_at']}",
    "",
    "## Verification evidence",
    "",
    "| Phase | Automated finding |",
    "|---|---|",
    f"| Phase 5 — UVM | {phase5} |",
    f"| Phase 6 — Coverage/regression | {phase6} |",
    f"| Phase 7 — JasperGold formal | {phase7} |",
    "",
    "## Log scan",
    "",
    f"- Text log/report files scanned: {len(contents)}",
    f"- UVM_ERROR counts found: {uvm_errors}",
    f"- UVM_FATAL counts found: {uvm_fatals}",
    "",
    "> Counts are aggregated across scanned files and may include repeated "
    "or historical runs. Review the individual logs before treating them "
    "as a final regression result.",
    "",
    "## RTL source inventory",
    "",
]
lines += [f"- `{p.relative_to(ROOT)}`" for p in rtl_files] or ["- No RTL .sv files found."]
lines += ["", "## UVM source inventory", ""]
lines += [f"- `{p.relative_to(ROOT)}`" for p in uvm_files] or ["- No UVM files found."]
lines += ["", "## Scanned log files", ""]
lines += [f"- `{p.relative_to(ROOT)}`" for p in contents] or ["- No matching log files found."]
lines += [
    "",
    "## Review checklist",
    "",
    "- [ ] Confirm Phase 5 UVM summary and zero-error/fatal result in its run log.",
    "- [ ] Confirm Phase 6 coverage report exists and inspect covered/ uncovered bins.",
    "- [ ] Confirm Phase 7 JasperGold proof results and review every unproven property.",
    "- [ ] Add screenshots of waveforms, coverage, and formal results to the portfolio.",
    "- [ ] Update the project README with tool versions and exact run commands.",
    "",
    "This report is generated from files present at scan time. It does not "
    "run simulations, calculate functional coverage, or prove properties.",
]
REPORT.write_text("\n".join(lines) + "\n")

print("PHASE 8 AUTOMATION COMPLETED")
print(f"Logs scanned : {len(contents)}")
print(f"RTL files    : {len(rtl_files)}")
print(f"UVM files    : {len(uvm_files)}")
print(f"Phase 5      : {phase5}")
print(f"Phase 6      : {phase6}")
print(f"Phase 7      : {phase7}")
print(f"Report       : {REPORT.relative_to(ROOT)}")
print(f"JSON status  : {STATUS_JSON.relative_to(ROOT)}")
