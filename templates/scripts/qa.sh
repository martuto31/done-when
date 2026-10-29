#!/bin/sh
# The gate: one command for the worker, the verifier and you.
#
#   sh scripts/qa.sh          full pass: build, every test, coverage floor (before a release: the end check)
#   sh scripts/qa.sh --fast   quick pass: compiles (per task, with the task's own tests)
#
# Exits non-zero on the first failure. Each step's output goes to .verify/ (add it to .gitignore), so an agent reads
# back only what it needs instead of pulling a whole build log into its context.
#
# No `| tee` anywhere: under /bin/sh a pipeline reports the LAST command's exit code, so `failing | tee log` passes a
# red build.
set -e

FAST=0
[ "$1" = "--fast" ] && FAST=1

cd "$(git rev-parse --show-toplevel)"
mkdir -p .verify

say()  { printf '\n\033[1m== %s\033[0m\n' "$1"; }
fail() { printf '\n\033[1;31m== FAILED: %s\033[0m\n   full output: %s\n' "$1" "$2"; exit 1; }

# run <label> <outfile> <command...>
run() {
  label=$1; out=".verify/$2"; shift 2
  say "$label"
  if "$@" >"$out" 2>&1; then
    tail -3 "$out"
  else
    cat "$out"
    fail "$label" "$out"
  fi
}

if [ "$FAST" = "1" ]; then
  run "compile" compile.txt {{COMPILE, e.g. ./mvnw -q compile  |  npx tsc --noEmit}}
else
  run "build and every test" build.txt {{BUILD_AND_TEST, e.g. ./mvnw clean install  |  npm test -- --watch=false}}

  # Coverage must not drop. Line coverage is held against the best seen in this checkout (.verify/coverage-floor),
  # with 0.2 points of slack for flaky timing paths; a higher result raises the floor. To accept a lower figure on
  # purpose, write it into that file.
  # With no tests yet, some tools report 100%, and that would become the floor: until real tests exist, write 0
  # into .verify/coverage-floor and delete it once they do.
  # COVERAGE must print one number, the line coverage in percent. Examples:
  #   JaCoCo CSV (columns 8, 9 = lines missed, covered):
  #     awk -F, 'NR > 1 { m += $8; c += $9 } END { printf "%.2f", (m + c) ? 100 * c / (m + c) : 0 }' target/site/jacoco/jacoco.csv
  #   Istanbul json-summary: node -p "require('./coverage/coverage-summary.json').total.lines.pct"
  pct=$({{COVERAGE}})
  floor=$(cat .verify/coverage-floor 2>/dev/null || echo 0)
  say "line coverage $pct% (floor $floor%)"
  if awk -v p="$pct" -v f="$floor" 'BEGIN { exit !(p + 0.2 < f) }'; then
    fail "line coverage $pct% is below the floor $floor%" ".verify/build.txt"
  fi
  if awk -v p="$pct" -v f="$floor" 'BEGIN { exit !(p > f) }'; then echo "$pct" > .verify/coverage-floor; fi
fi

printf '\n\033[1;32m== QA passed\033[0m\n'
