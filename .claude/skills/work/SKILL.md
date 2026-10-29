---
name: work
description: Run the project's agents until the queue is empty — one worker tick per round, an independent verifier (and a reviewer or UI tester when needed) between the build and the commit, an end check when nothing is left. `/work dry` only reports what would run.
---

# /work: worker → verifier → commit, until the queue is empty

You are the **dispatcher**. You never do project work yourself. Workers do it, one subagent per round, following
`WORKER.md`. Subagents can't start subagents, so the independent checkers are started by **you**, between the
worker's READY and its commit.

Run subagents (and `SendMessage` resumes) in the foreground and wait for each reply. Start all of a phase's checkers
in **one message** so they run in parallel. Load `SendMessage` and `TaskStop` with ToolSearch if they aren't loaded.

## Setup
- Check `git config user.email` is the one commits should carry. If not, stop and say so.
- Keep a tally: rounds done, last status.

## A round
1. Read only `QUEUE.md`'s Intake, Work order and Triaged stubs. **Active** = Intake has lines, or there's an open
   `auto` task above the Work order's **Test at the end** line (or under Triaged, if there's no Work order).
   Needs you and Blocked don't count.
2. Nothing active → **Finish**. Argument `dry` → print what would run, then **Finish** without starting anything.
3. **Lane** from the next task's tag: `small` → worker on model `sonnet`, effort medium, prompt adds "Work <id> in
   the small lane; if it isn't small, change nothing and reply `FULL <id>`". `deep` → `opus`, effort high.
   Untagged → `sonnet`, effort high (or `opus` if you can afford it).
4. Start the **worker** (`subagent_type: worker`) with the worker prompt below.
5. Act on its last line:
   - `READY …` → start the checkers, all in one message:
     - always a **verifier** (`subagent_type: verifier`; `sonnet` for small tasks) with the verifier prompt;
     - a **reviewer** (`subagent_type: reviewer`, `opus`) too when the diff touches money, sign-in, personal data or
       data migrations: give it the changed paths, the task's Why and Done when lines. `DEFECTS` counts as FAIL.
     - a **ui-tester** too, after the verifier's PASS, when the change touches UI files and the project has no end
       check. With an end check, the UI tester runs once at the end instead.
     - If the project has a script that starts an isolated test stack, start it first in the background on its own
       ports, wait until it's up, give its URLs to the checkers, and stop it when the verdicts are in.
   - Send the combined verdict to the worker with `SendMessage` and wait for its new last line:
     - `PASS` / `PASS · NOTES: …` → it commits (fixes the notes first, no new check).
     - `FAIL` → it fixes and replies READY again, once; a second FAIL → it parks the task.
     - `ENV: …` (any checker) → not a FAIL: restart the test stack and run that checker once more. A second ENV →
       the worker parks with that line.
     - Rare-case findings (two accounts in one browser, a second tab, Back at one moment) that cost no money and
       show no one else's data are NOTES: the worker queues them under **After launch**.
   - `FULL <id>` → start a normal-lane worker for it this round.
   - `SHIPPED … · CHECK end · <from>..<to>` → **End check** before the next round: one ui-tester over everything in
     the range (`git log --oneline <range>`, each task's Done when lines in `QUEUE-done.md`, at 390 and 1280 px).
     PASS → write `<to>` to `.verify/last-end-check`. FAIL → tell the next round's worker: "First add these as fix
     tasks (`auto`) at the top of the Work order, then do your tick: <findings>".
   - `SHIPPED`, `PARKED`, `TRIAGED` → next round. `IDLE` → **Finish**.
   - A usage-limit or rate-limit error → **Finish**, and say so.
6. 20 rounds → **Finish** with a note (a guard against going in circles).

## Worker prompt

> You are the worker for this repo. Read `WORKER.md` and do exactly **one tick** (triage Intake, work at most one
> `auto` task).
> - Resume interrupted work first: uncommitted changes mean a run was cut off. Find its task, finish it, reply READY.
> - Don't spawn a verifier. When the task's tests and the build pass, stop before committing and reply
>   `READY <id> · <title>`, the task's **Done when** lines verbatim, then `Saved runs: <paths in .verify/>`. I'll send
>   an independent verdict. PASS → commit and record as `WORKER.md` says. FAIL → fix and reply READY once more; a
>   second FAIL → park the task as `WORKER.md` says, so the tree is clean.
> - An item under Needs you with an `**Answer (…)**` line is approved: move it into the Work order and work it as
>   the answer says.
> - Hard limits: never push, never deploy or touch production, never read or print `.env`, no real paid API calls,
>   only the local test database, never stop a process you didn't start.
> - Your last line is exactly one of the lines `WORKER.md` → "Your last line" lists.

## Verifier prompt

> You are an independent verifier. On purpose, you haven't seen how this change was built. Run
> `git status --short && git diff`, read new untracked files, and check the change against these **Done when** lines:
>
> <the Done when lines, verbatim>
>
> Saved runs: <paths from READY>. Read a saved run instead of re-running it when it passed and is newer than every
> changed file. Run only what no saved run settles. Give each line PASS or FAIL with one line of evidence. Last line:
> `PASS`, `PASS · NOTES: <which>`, `FAIL: <which lines>` or `ENV: <what>`.

Give the verifier nothing else: not the worker's reasoning, not its summary.

## Finish
1. Write a short summary to `.agents-summary.md` and print it: **Shipped** (id · title · sha), **Parked** (id ·
   reason), **Needs you** (count, plain titles), **Why it stopped** (nothing left · usage limit · round cap).
2. Stop. Don't ask questions: nobody may be watching. Don't schedule or loop.
