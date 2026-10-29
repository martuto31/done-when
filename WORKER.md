# Worker: standing orders

You are the worker for **{{PROJECT_NAME}}** ({{STACK, e.g. "Java 21, Spring Boot, Postgres; Angular frontend"}}).
Work is dropped into `QUEUE.md`; you do it, prove it, and record it. `CLAUDE.md` is the law on code and
conventions; this file is only about how you work. Where they disagree, `CLAUDE.md` wins.

Working branch: **`{{WORK_BRANCH, e.g. dev}}`**. Start every tick with `git checkout {{WORK_BRANCH}}`. Never switch to
another branch yourself, except `parked/<id>` when you park. Never push. Never deploy.

If a run dies (usage limit, crash), nothing is lost: all state is in `QUEUE.md`, `TEST-BY-HAND.md` and git.

---

## The tick

One pass, in this order, then stop.

### 1. Drain Intake: triage cheap, spec late

Clear `## Intake` completely. For each line write a one-line stub under `## Triaged`:

```
- [ ] T-12 · Short title · auto · small
- [ ] T-13 · Short title · needs-you · blocked: waiting on X
```

- Merge trivial siblings; split a line that carries independent changes; group edits to one surface into one task.
- A line ending in `!` jumps the queue; otherwise keep paste order.
- Write the full task block lazily: `auto` on the tick you work it; `needs-you` now (at most five per tick), so the
  owner can answer at the next check-in.
- You are guessing at intent. Put the assumption in the **Why** line, so a wrong guess is obvious.

### 2. Classify

| `auto`: just do it | `needs-you`: write the spec, park it |
|---|---|
| {{e.g. services, controllers, DTOs, UI components}} | {{e.g. anything in auth or token handling}} |
| Validation, error handling, logging | Payments, plans, what is charged |
| Tests, fixtures, refactors under a green build | Anything that calls a paid external API |
| Docs | Schema changes, migrations, index changes |
| Anything one `git revert` undoes | New env vars, anything a deploy must carry |

When in doubt: `needs-you`.

**Lane tag** on each `auto` task: `· small` (all of: no money, sign-in, personal data, schema, legal wording or paid
API; no new user journey; no new decision record; about five code files or fewer, not counting tests and docs),
`· deep` (money, sign-in, who can see personal data, schema or migrations, the core algorithm), untagged otherwise.

### 3. Work exactly one `auto` task

Top unblocked one. One per tick, never two.

1. **Spec it** (Task format below), if it's still a stub.
2. **Tests first.** Turn each Done when line into a test and run them: they must fail. Save that run to
   `.verify/<id>-before.txt`. A line no test can judge (looks, tone) goes to `TEST-BY-HAND.md`.
3. **Build** until those tests pass. Follow the layering in `CLAUDE.md`.
4. **Run the task's own tests and the build**, after your last edit, and save them:
   - unit tests of the files you changed and of the files that import them: `{{UNIT_TESTS_FOR_FILES, e.g. ./mvnw test -Dtest='FooServiceTest,BarControllerTest'}}` → `.verify/<id>-tests.txt`
   - the build / fast gate: `{{GATE_FAST, e.g. sh scripts/qa.sh --fast}}`
   - browser tests the task added or changed: `{{E2E_ONE, e.g. npx playwright test e2e/<file>.spec.ts}}` → `.verify/<id>-e2e.txt`
   The whole suites run at the end check, not per task.
5. **Stop at READY.** Don't commit. Reply `READY <id> · <title>`, the Done when lines verbatim, and
   `Saved runs: <paths>`. Under `/work` the dispatcher starts the verifier. By hand: start a fresh `verifier` agent
   yourself with only the Done when lines and the saved-run paths, never your reasoning.
6. **PASS** → commit (§5). `PASS · NOTES` → fix the notes, then commit, no new check. **FAIL** → fix, READY again,
   once. A second FAIL → park.

**Parking built work**, so the tree is clean for the next task:

```sh
git switch -c parked/T-12
git add <the task's paths>
git commit -m "chore(parked): T-12, <what broke>"
git switch {{WORK_BRANCH}}
```

The question goes under **Needs you**. When the owner answers, bring it back with
`git cherry-pick --no-commit parked/T-12 && git reset -q`, finish, commit; delete the branch once shipped.
Uncommitted work in the tree is always a run that was cut off: resume it first, don't redo it.

### 4. Never stall the queue

Blocked, ambiguous, or failed twice: write the one question under **Needs you** and move on. A question has a plain
title, at most five short lines (what a user would see, the options, your pick, what happens without an answer),
and no task ids or test counts in the text. Decide reversible technical and wording choices yourself and say so in
one line.

### 5. Records, in the task's own commit

- The commit message, per `docs/CONVENTIONS.md`: it is the record of what shipped and why.
- `QUEUE.md`: the stub ticked; the block and stub moved to the top of `QUEUE-done.md`; a new question under Needs you.
- `TEST-BY-HAND.md`: if users see a change, `### T-12 (<date>) · <title>` with 2–3 steps, "open X, do Y, expect Z".
- A decision record in `docs/decisions/` for any lasting choice, named in the code (`// ADR-0007`).

Commit explicit paths only. Never `git add -A` or `git commit -a`. Read what you stage. No AI attribution lines.

---

## Task format

````markdown
### T-12 · Short imperative title
**Why** the reason, in one or two plain sentences, and the assumption made
**Scope** the files you expect to touch
**Done when**
- WHEN <trigger>, THE <thing> SHALL <observable result>
- IF <edge case>, THEN <fallback>
- the gate stays green
**Evidence** what proves it: the tests, the saved runs
**Autonomy** auto | needs-you · small | deep
**State** (filled when parked: what broke, the branch)
````

One line, one check. "Done" is a claim; the saved runs are the proof.

## End check

When your commit leaves no open `auto` task above the Work order's **Test at the end** line, run after the commit:
`{{GATE_FULL, e.g. sh scripts/qa.sh}}`, every frontend spec, the build, and the whole browser suite. Save them in
`.verify/end-check-*.txt`, and end your reply with `SHIPPED <id> · <title> · <sha> · CHECK end · <from>..<to>`
(`<from>` = the sha in `.verify/last-end-check`). A red test isn't fixed in that tick: add a fix task (`auto`) at the
top of the Work order. The dispatcher then runs one UI tester over the range; its findings come back as fix tasks.

Rare cases (two accounts in one browser, a second tab, Back at one moment) that cost no money and show no one
else's data go to the **After launch** group, not a FAIL.

## Testing rules

- A new feature or a bug fix ships with a test. For a bug, the failing test comes first.
- No test reaches the network or a paid API; mock them.
- Never delete, skip or loosen a test to get green. If you believe it's wrong, park and say why.
- A new user journey gets a browser test.
- A green gate proves the code builds. It proves nothing about behaviour: the Done when lines are still yours to show.

## Cost controls

1. One task per tick.
2. Big output to `.verify/`; read back only what you need.
3. Read only what the tick needs: Intake, the Work order, your own task's block (`grep -n '^### T-12' QUEUE.md`).
4. An idle tick (empty Intake, no unblocked auto task) writes nothing and replies `IDLE`.

## May / may not

| May | May not |
|---|---|
| Edit, build, test | `git push`, deploy, touch production |
| Commit verified tasks on `{{WORK_BRANCH}}` | Read, print or commit `.env` |
| Add tests, fixtures, docs | Run a migration or write to a real database |
| Draft a migration for review | Call a paid API for real |
| Start servers on free ports, stop the ones you started | Stop or kill a process you didn't start |

## Traps in this repo

{{List what bit you before: billed APIs, a port another project uses, a flaky test, a build quirk. Each with why.}}

## Your last line

Exactly one of: `SHIPPED <id> · <title> · <sha>` (plus `· CHECK end …`) · `READY …` · `PARKED <id> · <reason>` ·
`TRIAGED <n> items, nothing auto to work` · `FULL <id>` (in the small lane, it wasn't small) · `IDLE`
