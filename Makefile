.PHONY: help lint sim triage clean

help:
	@echo "Targets:"
	@echo "  make sim     - Run Xcelium"
	@echo "  make triage  - Parse existing Xcelium log"
	@echo "  make clean   - Remove generated simulation output"

sim:
	bash sim/xcelium/run.sh

triage:
	python3 scripts/triage.py regression/logs/xcelium.log

clean:
	rm -rf xcelium.d INCA_libs *.history *.log
	rm -f regression/logs/*
	rm -f regression/reports/*
