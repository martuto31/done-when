#!/bin/sh
# Optional: runs /work in the background until the queue is empty, and starts it again after a usage limit or a
# crash. From the repo root:
#   sh scripts/agents.sh          start (detached; closing the terminal doesn't stop it)
#   sh scripts/agents.sh log      watch
#   sh scripts/agents.sh stop     stop now (a task in hand stays uncommitted; the next run resumes it)
#
# Unattended runs need --permission-mode auto: "acceptEdits" lets it edit files but not run tests or commit. The
# deny rules in .claude/settings.json hold in every mode: no push, no deploy, no .env. Add your own deploy commands
# there.
cd "$(git rev-parse --show-toplevel)" || exit 1
RUNLOG=.verify/agents-runner.log
LAST=.verify/agents-last.txt
PIDFILE=.verify/agents.pid
mkdir -p .verify

running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }

case "${1:-}" in
  stop) if running; then pkill -P "$(cat "$PIDFILE")"; kill "$(cat "$PIDFILE")"; echo "agents: stopped"; else echo "agents: not running"; fi
        rm -f "$PIDFILE"; exit 0 ;;
  log)  exec tail -n 30 -f "$RUNLOG" ;;
  --fg) echo $$ > "$PIDFILE"; trap 'rm -f "$PIDFILE"' EXIT ;;
  *)    if running; then echo "agents: already running. Watch: sh scripts/agents.sh log"; exit 0; fi
        nohup sh "$0" --fg >> "$RUNLOG" 2>&1 < /dev/null &
        echo "agents: running in the background. Watch: sh scripts/agents.sh log · Stop: sh scripts/agents.sh stop"; exit 0 ;;
esac

crashes=0
for attempt in $(seq 1 30); do
  rm -f .agents-summary.md
  echo "agents: run $attempt started $(date '+%a %H:%M')" | tee "$LAST"
  claude -p "/work" --permission-mode auto 2>&1 | tee -a "$LAST"
  if [ -s .agents-summary.md ] && ! grep -qi 'usage limit' .agents-summary.md; then
    echo "agents: finished $(date '+%a %H:%M')"; exit 0
  fi
  if grep -qiE 'usage limit|rate limit|resets [0-9]' "$LAST"; then
    crashes=0
    echo "agents: usage limit at $(date '+%H:%M'), trying again in 30 minutes"
    sleep 1800
  else
    crashes=$((crashes + 1))
    [ "$crashes" -gt 12 ] && { echo "agents: gave up after 12 crashes"; exit 1; }
    echo "agents: run crashed at $(date '+%H:%M'), retrying in 10 minutes ($crashes/12)"
    sleep 600
  fi
done
echo "agents: gave up after 30 runs"
