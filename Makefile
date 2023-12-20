# trialmig build. Paths are relative on purpose: the checkout path may contain spaces.
# The binary-truncate flag is not needed: probe p_comp5 showed COMP-5 never truncates
# (see docs/VERIFIED.md). No -O.
COBFLAGS = -free -Wall -debug -I copy
MODULES = src/LEDGER.cob src/PACKDEC.cob src/ZONEDEC.cob src/FLETCH16.cob \
          src/EBCXLATE.cob src/DATEUTIL.cob src/SHA256.cob src/HMAC.cob \
          src/CSVFMT.cob src/STAGEIO.cob src/RECONRPT.cob

.PHONY: preflight build build-test test-unit test-scen golden lint clean count

preflight:
	@command -v cobc >/dev/null || { echo "cobc not found: brew install gnucobol"; exit 1; }
	@command -v python3 >/dev/null || { echo "python3 not found"; exit 1; }
	@command -v sh >/dev/null || { echo "sh not found"; exit 1; }
	@cobc --version | head -1
	@python3 --version
	@cobc --version | head -1 | sed -E 's/.* ([0-9]+)\.([0-9]+).*/\1 \2/' | \
	  awk '{ if ($$1 < 3 || ($$1 == 3 && $$2 < 1)) { print "GnuCOBOL 3.1 or newer required"; exit 1 } }'

# The old binary is removed first: the linker intermittently fails to overwrite
# files on network mounts.
build:
	@mkdir -p build
	@rm -f build/trialmig
	cobc -x $(COBFLAGS) -o build/trialmig src/MAIN.cob $(MODULES)

# Test build adds the FAULT hook (tests/hook is searched first, so its FAULT.cpy
# shadows copy/FAULT.cpy).
build-test:
	@mkdir -p build
	@rm -f build/trialmig_test
	cobc -x -free -Wall -debug -I tests/hook -I copy -o build/trialmig_test src/MAIN.cob $(MODULES)

test-unit:
	python3 tests/ref/offset_audit.py
	sh tests/run_unit.sh

test-scen: build build-test
	sh tests/run_scen.sh

golden:
	python3 tests/ref/trialmig_ref.py vectors
	python3 tests/ref/trialmig_ref.py golden

lint:
	for f in tests/ref/*.py tests/gen/*.py; do python3 -I -m py_compile $$f || exit 1; done
	@if command -v shellcheck >/dev/null; then shellcheck bin/*.sh tests/*.sh; else echo 'shellcheck: SKIPPED (not installed)'; fi

count:
	sh tests/count_lines.sh

clean:
	rm -rf build
