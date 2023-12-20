#!/bin/sh
# trialmig wrapper: validates configuration, runs the COBOL binary, promotes output.
# usage: trialmig.sh [--validate-only] <input>
# Runs in the current directory: work/ (scratch), diag/ (diagnostics), out/ (result).
# The key never goes on a command line; .env is parsed as KEY=VALUE, never sourced.
umask 077
HERE=$(cd "$(dirname "$0")" && pwd)
BIN=${TRIALMIG_BIN:-$HERE/../build/trialmig}
PLACEHOLDER=CHANGE-ME-INVALID-PLACEHOLDER-KEY

mode=RUN
if [ "$1" = "--validate-only" ]; then
    mode=VALIDATE
    shift
fi
input=$1

# Wrapper-side abort: COBOL never started, so write the one-line report ourselves.
abort() {
    name=$(basename "${input:--}" 2>/dev/null)
    rm -rf diag
    mkdir -p diag
    printf 'RUN %s\nRC 12\nCAUSE %s\n' "${name:--}" "$1" > diag/reconciliation.rpt
    echo "trialmig: abort $1" >&2
    rm -rf work
    exit 12
}

rm -rf diag work
mkdir -p diag work || abort BADARGS
[ $# -eq 1 ] || abort BADARGS

# .env values apply only where the environment does not already set them.
if [ -f .env ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        case $line in
            TRIALMIG_SALT=*) [ -n "${TRIALMIG_SALT+x}" ] || TRIALMIG_SALT=${line#TRIALMIG_SALT=} ;;
            TRIALMIG_STRICT_SIGN=*) [ -n "${TRIALMIG_STRICT_SIGN+x}" ] || TRIALMIG_STRICT_SIGN=${line#TRIALMIG_STRICT_SIGN=} ;;
        esac
    done < .env
fi
TRIALMIG_STRICT_SIGN=${TRIALMIG_STRICT_SIGN:-N}
case $TRIALMIG_STRICT_SIGN in Y|N) ;; *) abort BADCONFIG ;; esac
[ "${TRIALMIG_SALT:-$PLACEHOLDER}" != "$PLACEHOLDER" ] || abort BADKEY
[ "${#TRIALMIG_SALT}" -ge 32 ] || abort BADKEY

# work/ is renamed to out/ at the end, which is only atomic on one filesystem.
[ "$(df -P . | awk 'NR==2{print $1}')" = "$(df -P work | awk 'NR==2{print $1}')" ] || abort BADARGS
if [ "$mode" = RUN ] && [ -e out ]; then
    abort OUTEXISTS
fi

export TRIALMIG_SALT TRIALMIG_STRICT_SIGN
TRIALMIG_MODE=$mode "$BIN" "$input"
rc=$?

if [ "$rc" -eq 0 ] || [ "$rc" -eq 4 ] || [ "$rc" -eq 8 ]; then
    if [ "$mode" = RUN ]; then
        [ ! -e out ] || abort OUTEXISTS
        mv work/out out || abort OUTEXISTS
    fi
fi
rm -rf work
exit "$rc"
