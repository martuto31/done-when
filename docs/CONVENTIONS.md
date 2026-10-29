# Conventions: commits, decisions, code documentation

The reviewer and the verifier check these.

## 1. Commit messages: Conventional Commits

```
type(scope): what changes, in plain words

A short story, two to five lines: what was wrong or missing, for whom, and why now.
The reader never saw the chat.

Changes
- BE: what changed, by area, one line each.
- FE: …

Decisions
- Each choice made and why; a lasting one names its record: ADR-0007.

Tests
- What ran and the result; what wasn't tested and why.

Task: T-12
Refs: ADR-0007
```

- **Title:** `type(scope): subject`, at most 72 characters, lower case start, no full stop, says what changes for
  the user or the code, not the file names. One idea per commit.
- **Types:** `feat` new for a user · `fix` wrong made right · `perf` · `refactor` no behaviour change · `style` looks
  or wording only · `test` · `docs` · `build` · `ci` · `chore` (queue moves, parking) · `revert`. A breaking change
  adds `!` and a `BREAKING CHANGE:` trailer.
- **Scope:** the area a user would name (`checkout`, `courier`, `sign-in`); leave it out if there's none.
- **Body:** the story always (except one-line docs/chore); Changes and Tests for any code change; Decisions whenever
  a choice was made.
- **Trailers:** `Task:` the queue id, `Refs:` the decision records, `Pair: <repo> <sha>` when one task spans two repos.
- The task's records ride in the same commit. No AI attribution lines.
- `scripts/hooks/commit-msg` checks the title and scans the staged diff for secrets.

## 2. Decision records (`docs/decisions/`)

Write one for every choice a later session could undo by accident: a product rule, a data shape, an algorithm, a
default, a trade-off, a "we decided not to".

- File `docs/decisions/NNNN-short-title.md`, numbered in order, never renumbered; template `0000-template.md`;
  one line per record in `docs/decisions/README.md`.
- Status: `Proposed` (waiting for the owner), `Accepted`, `Superseded by ADR-NNNN`. A changed decision gets a new
  record; the old one stays.
- The code that carries it names it: `// ADR-0007: one departure time for every car`.

## 3. Code documentation

The code explains **why**. A reader who never saw the chat must understand each choice.

- Every class, component and service starts with a doc comment: what it's for, where it sits in the flow, the ADR
  it implements.
- Every method has one unless its name says everything and it's a few lines: what, why, the cases it handles
  (null, empty, limits), what it returns or throws.
- Every non-obvious line gets its reason; numbers carry their unit and reason
  (`/** 30 s: often enough to see a change, cheap for the server. */`).
- Tests are named `method_condition_expectedResult`, with a one-line comment when the scenario isn't obvious.
- Comments change in the same commit as their code. A stale comment is a bug. Don't comment the obvious.
