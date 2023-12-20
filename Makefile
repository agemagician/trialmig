# trialmig build. Paths are relative on purpose: the checkout path may contain spaces.
# The binary-truncate flag is not needed: probe p_comp5 showed COMP-5 never truncates
# (see docs/VERIFIED.md). No -O.
COBFLAGS = -free -Wall -debug -I copy
MODULES = src/LEDGER.cob src/PACKDEC.cob src/ZONEDEC.cob src/FLETCH16.cob \
          src/EBCXLATE.cob src/DATEUTIL.cob src/SHA256.cob src/HMAC.cob \
          src/CSVFMT.cob src/STAGEIO.cob src/RECONRPT.cob

.PHONY: preflight build clean

preflight:
	@command -v cobc >/dev/null || { echo "cobc not found: brew install gnucobol"; exit 1; }
	@command -v sh >/dev/null || { echo "sh not found"; exit 1; }
	@cobc --version | head -1
	@cobc --version | head -1 | sed -E 's/.* ([0-9]+)\.([0-9]+).*/\1 \2/' | \
	  awk '{ if ($$1 < 3 || ($$1 == 3 && $$2 < 1)) { print "GnuCOBOL 3.1 or newer required"; exit 1 } }'

# The old binary is removed first: the linker intermittently fails to overwrite
# files on network mounts.
build:
	@mkdir -p build
	@rm -f build/trialmig
	cobc -x $(COBFLAGS) -o build/trialmig src/MAIN.cob $(MODULES)

clean:
	rm -rf build
