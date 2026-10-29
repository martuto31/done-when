---
name: setup
description: Set up the done-when workflow in this project, once. Copies the queue, the standing orders, the house rules and the scripts into place, fills in this project's real build and test commands (each run once to prove it works), and blocks push, deploy and .env reads in .claude/settings.json.
---

# Set up done-when in this project

The files to copy are in `${CLAUDE_PLUGIN_ROOT}/templates/`. Read `${CLAUDE_PLUGIN_ROOT}/docs/WORKFLOW.md` first: it is
the method each file serves. Never push, deploy or read `.env` while you do this.

1. **Copy** everything under `templates/` into the project root, keeping the folders (`docs/`, `scripts/`,
   `.claude/settings.json`). Never overwrite a file the project already has; merge into it:
   - `.claude/settings.json`: add the `permissions.deny` entries to the ones already there;
   - `docs/decisions/README.md`: keep the existing index and add nothing twice;
   - `CLAUDE-rules.md`: put its block at the top of the project's `CLAUDE.md` (create one if there is none), then
     delete the copied `CLAUDE-rules.md`.
2. **Fill every `{{...}}` placeholder.** `grep -rn '{{' CLAUDE.md WORKER.md QUEUE.md TEST-BY-HAND.md docs scripts .claude`
   lists them. Take each value from what this project really uses: find the build, test, single-test, coverage and
   browser-test commands by reading the project (its package or build files, CI config, README), and run each one
   once to prove it works. Delete the parts that don't apply (no frontend: drop the browser tests and the ui-tester
   lines). If a command starts a server, check its port is free first; if it is busy, stop nothing: skip it and say
   so. With no tests at all, keep the coverage floor at 0 (`scripts/qa.sh` says why).
3. **Ask only two things**, each with your suggested answer from the code: the branch to commit on, and the risky
   areas the agents must not touch alone (for example sign-in, payments, migrations, paid APIs). The answers go into
   the rules block in `CLAUDE.md` and the auto / needs-you table in `WORKER.md`. When the person who ran this said to
   use your suggestions, use them and don't ask.
4. Add `.verify/` to `.gitignore` (saved test runs live there) and run `sh scripts/install-hooks.sh`.
5. **Show** what changed (`git status --short` and one line per file) and how to start:
   - write a few rough lines under `QUEUE.md` → Intake;
   - run `/done-when:work` (`/done-when:work dry` shows what would run first);
   - `sh scripts/agents.sh` runs it in the background and restarts it after a usage limit.

   Don't commit until the person says so.
