# The workflow

How a rough idea becomes a checked commit. Each rule says why it exists: most came from a week of an agent
working unattended and getting something wrong.

## 1. Drop work in, rough

You write into `QUEUE.md` → **Intake**, one line per thought, however rough. Exact values in quotes ("rename the
button to `Send`") ship as written; described ones ("a nicer name") come back as a question.

## 2. Triage cheap, spec late

Every tick the worker empties Intake into one-line stubs under **Triaged**:

```
- [ ] T-12 · Courier link shows the next stop first · auto · small
```

- It merges trivial siblings (three typos are one task), splits a line that holds independent changes, and groups
  edits to the same screen into one task.
- **auto** or **needs-you**. needs-you = auth, payments, paid API calls, data shape or migrations, new environment
  variables, legal wording, anything one `git revert` can't undo. When in doubt, needs-you: parking costs a glance,
  building the wrong thing costs a morning.
- **Lane**: `small` (≤ about 5 code files, nothing risky, no new decision) runs on a cheaper model with one checker;
  `deep` (money, sign-in, personal data, migrations, core algorithms) runs on the strongest model; everything else is
  normal. Why: most of a task's time was process, not the change; small things don't need the whole ceremony.
- The full spec is written only on the tick that works the task (auto) or right away for needs-you (so you can
  answer it). Thirty full specs written up front burn a usage window and ship nothing.

## 3. Scope: the task block

```markdown
### T-12 · Courier link shows the next stop first
**Why** the reason, in plain words, and the assumption made ("guessing you mean the phone view")
**Scope** the files expected to change
**Done when**
- WHEN the courier opens the link, THE page SHALL show the first unmarked stop at the top
- IF every stop is marked, THEN the page SHALL show "Day finished"
- the gate stays green
**Evidence** the tests that prove it, the saved runs
**Autonomy** auto · small
```

**Done when** lines use EARS (`WHEN … THE … SHALL …`, `IF … THEN …`, `WHILE …`): one line, one check. Prose
criteria are where a task quietly becomes whatever the agent felt like building. A line no test can judge (looks,
tone) says so and goes to `TEST-BY-HAND.md`.

## 4. Tests first, for features too

Before any code, each Done when line becomes a test (unit, browser, or a string check for copy) and is run: it must
fail. The failing run is saved (`.verify/T-12-before.txt`). For a bug, the failing test is the only proof the bug
was real. The task is done when the same tests pass.

## 5. Build, then stop at READY

The worker builds until the task's own tests and the build pass, saves those runs in `.verify/`, and stops before
committing with `READY T-12` plus the Done when lines and the saved-run paths. Per task only its own tests run (the
files it changed and their importers); the whole suites run once at the end. Why: the full suite on every task was
most of the hour.

## 6. An independent check

A fresh **verifier** gets the Done when lines and the diff, never the builder's reasoning: a checker that has read
the builder's argument just agrees with it. It reads the saved runs instead of re-running them (when they passed and
are newer than every changed file), runs what they don't settle, and answers per line:

- `PASS`, or `PASS · NOTES: …` (docs and comments to fix before the commit, no new check)
- `FAIL: <lines>`. Deleting, skipping or loosening a test the task didn't ask to change is a FAIL by itself.
- `ENV: <what>`: the environment failed (port busy, stale server), not the change. Restart it and check again; never
  counts as a FAIL.

When the diff changes who sees data, money or sign-in, a **reviewer** also hunts for the bug no Done when line
covers (a second click, an empty input, another user's data, an error swallowed) and must prove each finding with a
scenario and `file:line`.

## 7. Commit, or park

PASS → one commit per task with its records in the same commit: the message (story, Changes, Decisions, Tests), the
stub ticked, a `TEST-BY-HAND.md` entry if users see a change, a decision record for any lasting choice.
FAIL → fix and check once more. A second FAIL → the work goes to a `parked/T-12` branch, the question goes under
**Needs you**, and the queue moves on. Never stall on one task.

## 8. End check

When nothing auto is left: every suite, the build, the browser suite and one UI tester over everything since the last
end check, at phone and desktop widths. Findings become fix tasks at the top of the queue; the check runs again after
them. A release waits for a green end check and your `TEST-BY-HAND.md` walk.

## 9. Rare cases after launch

A finding that needs a rare sequence (two accounts in one browser, a second tab, Back at one exact moment), costs no
money and shows no one else's data doesn't hold the task: it's queued for after the release. Otherwise edge cases
eat the release date.

## Cost and safety rules

- One task per tick. Group related edits into one task to go faster; never run two.
- Big output (build logs, test runs, screenshots) goes to `.verify/`; read back only the part you need.
- Read only what the tick needs: Intake, the Work order and your own task's block, not the whole queue history.
  Finished tasks move to `QUEUE-done.md`.
- An idle tick writes nothing.
- A red gate is never routed around: no `--no-verify`, no skipped step, no weakened assertion.
- Agents never push, deploy, read `.env`, call paid APIs for real, or stop processes they didn't start.
