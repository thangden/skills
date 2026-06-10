# aos — run the verify-gate gates on demand (mirrors the Stop hook).
# Reads commands from .claude/hooks/config.env. Usage: make check | compile | lint | test | format
SHELL := /bin/bash
CFG := .claude/hooks/config.env

.PHONY: help check compile lint test format
help:
	@echo "aos: make check (compile+lint+test) | compile | lint | test | format"
compile:
	@set -a; [ -f $(CFG) ] && . $(CFG); set +a; if [ -n "$$COMPILE_CMD" ]; then echo ">> $$COMPILE_CMD"; eval "$$COMPILE_CMD"; else echo "(no COMPILE_CMD)"; fi
lint:
	@set -a; [ -f $(CFG) ] && . $(CFG); set +a; if [ -n "$$LINT_CMD" ]; then echo ">> $$LINT_CMD"; eval "$$LINT_CMD"; else echo "(no LINT_CMD)"; fi
test:
	@set -a; [ -f $(CFG) ] && . $(CFG); set +a; if [ -n "$$TEST_CMD" ]; then echo ">> $$TEST_CMD"; eval "$$TEST_CMD"; else echo "(no TEST_CMD)"; fi
check: compile lint test
	@echo "aos check complete"
format:
	@set -a; [ -f $(CFG) ] && . $(CFG); set +a; if [ -n "$$FORMAT_CMD" ]; then echo ">> $$FORMAT_CMD ."; eval "$$FORMAT_CMD ."; else echo "(no FORMAT_CMD)"; fi
