#!/usr/bin/env python3

import re
import sys
from collections import Counter
from pathlib import Path

SIGNATURES = {
    "ASSERTION": re.compile(r"Error:.*assert|ASSERTION.*FAIL", re.I),
    "UVM_FATAL": re.compile(r"UVM_FATAL", re.I),
    "UVM_ERROR": re.compile(r"UVM_ERROR", re.I),
    "UNDERRUN": re.compile(r"underrun", re.I),
    "TIMEOUT": re.compile(r"timeout|simulation.*hang", re.I),
    "JASPER": re.compile(r"property.*fail|counterexample", re.I),
}

def classify(line):
    for name, pattern in SIGNATURES.items():
        if pattern.search(line):
            return name
    return "OTHER"

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 scripts/triage.py <logfile>")
        sys.exit(1)

    logfile = Path(sys.argv[1])

    if not logfile.exists():
        print(f"Log file not found: {logfile}")
        sys.exit(1)

    counts = Counter()
    examples = {}

    for line in logfile.read_text(errors="replace").splitlines():
        signature = classify(line)
        if signature != "OTHER":
            counts[signature] += 1
            examples.setdefault(signature, line.strip())

    report = [
        "DISPLAY PIPELINE REGRESSION TRIAGE",
        "=" * 45,
        f"Log: {logfile}",
        "",
        "Failure summary:"
    ]

    for name, count in counts.most_common():
        report.append(f"{name}: {count}")
        report.append(f"  Example: {examples[name]}")

    if not counts:
        report.append("No recognized failures found.")

    output = Path("regression/reports/triage_summary.txt")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(report) + "\n")

    print("\n".join(report))
    print(f"\nSaved report: {output}")

if __name__ == "__main__":
    main()
