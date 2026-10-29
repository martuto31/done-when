## Rules for every session and every agent

<!-- Paste this block at the top of your CLAUDE.md (or AGENTS.md). Fill the {{…}} parts. -->

- **Never push, to any branch, and never deploy or touch production.** The owner does that.
- Commits go on **`{{WORK_BRANCH}}`**, one per task, explicit paths only (never `git add -A`), no AI attribution
  lines, messages per `docs/CONVENTIONS.md`.
- Never read, print or commit `.env` or any key file. No real calls to paid APIs; tests mock them.
- Never stop, kill or restart a process you didn't start. {{Ports NNNN and NNNN run other projects}}: use a free port.
- Only the local test database. Never write to a real one.
- **How work runs:** `WORKER.md`. One task at a time: Done when lines first, tests first (they must fail), build,
  then a separate verifier that never saw the builder's reasoning; a reviewer too when the diff changes who sees
  data, money or sign-in. Then one commit with its records. `/done-when:work` runs that loop until the queue is empty.
- **The agent that builds a change never checks it.** A diff that deletes, skips or loosens a test the task didn't
  ask to change fails, whatever else it does.
- **Replies to the owner:** short, plain words, no task ids to remember; detail goes into files. Decide reversible
  technical and wording choices yourself and say so in one line. Ask only about money, legal risk, direction, or taste
  on something they can see, and show them the thing.
- Every lasting choice gets a record in `docs/decisions/` and is named in the code; every class and method says
  what it does and why (`docs/CONVENTIONS.md`).
- Every agent brief repeats these rules.
