# trialmig

Batch migration of a legacy clinical-trial export, written in GnuCOBOL 3.x. It reads a
fixed-length (120-byte records) EBCDIC cp037 mainframe file, decodes it field by field,
checks every record and every cohort against the file's own trailers, and writes cleaned
CSV for an ML pipeline plus a reconciliation report that shows where each source record
went. All fixtures are synthetic (marker `SYNTHETIC-NOT-REAL`, fictional protocol
HB-ONC-0417). An AI assistant helped write this code.

## Run

```sh
brew install gnucobol            # needs cobc 3.1 or newer
make preflight build
cp .env.example .env             # set TRIALMIG_SALT to 32+ random characters
bin/trialmig.sh export.dat       # writes out/ and diag/
bin/trialmig.sh --validate-only export.dat   # report only, nothing promoted
```

`TRIALMIG_SALT` (the HMAC key) and `TRIALMIG_STRICT_SIGN` (`Y` or `N`, default `N`) come
from the environment or `.env` (parsed as `KEY=VALUE`, never sourced). The key never goes
on a command line and is never written to a file, report or log. Output made under
different keys cannot be joined. Run from a directory on a local filesystem: the wrapper
creates `work/` and `diag/` in the current directory and refuses to overwrite `out/`.

## Output and exit codes

`out/` holds `patients.csv`, `lab_results.csv`, `adverse_events.csv`, `reject.csv` and
`reconciliation.rpt`; held cohorts are under `out/held/<cohort>/`. Every detail record is
WRITTEN, REJECTED or HELD, and the report checks `detail_read = written + rejected + held`
per cohort and in total.

| RC | Meaning |
|---|---|
| 0 | clean |
| 4 | some records rejected, nothing held |
| 8 | at least one cohort held (trailer totals or a damaged record) |
| 12 | aborted, nothing promoted; `CAUSE` on stderr and in `diag/reconciliation.rpt` |

## Sign policy

Packed fields: sign nibbles C and F positive, D negative. Nibbles A, E (positive) and B
(negative) come from a 1997 job bug: lenient mode decodes them and flags `SGN`; strict mode
(`TRIALMIG_STRICT_SIGN=Y`) rejects the record. Any other nibble rejects.

## Limits

* This is pseudonymisation, not anonymisation. A +/-180 day date shift is a weak mask, and
  free text such as the adverse-event `term` can still identify a person.
* The key is checked for length (at least 32 characters), not entropy.
* The record checksum catches transmission damage, not tampering. Because the modulus is
  255, bytes `0x00` and `0xFF` contribute the same.
* Layouts are hard-wired to HB-ONC-0417. Caps: 64 cohorts, 5,000 patients.
* No restart or checkpointing: a failed run is discarded and rerun.
