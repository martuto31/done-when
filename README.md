# ai-workflow-kit

**Drop rough to-dos into a queue; Claude Code turns each one into a tested commit, checked by a second agent that
never saw how it was built.**

A small set of markdown files and two shell scripts. No packages, any stack: the setup prompt reads your project and
fills in your own build and test commands. Built for Claude Code (subagents and a `/work` command); the method also
works by hand with any coding agent.

```
you write a rough line ─► triage: one-line stub, auto or needs-you, lane
                          spec: Why · Scope · Done when (one testable line each) · Evidence
                          tests first: each Done when line becomes a test, run it, it must FAIL
                          build until those tests pass, plus the build
                          a separate verifier, who never saw the builder's reasoning, checks the diff
                            against the Done when lines (+ a bug-hunting reviewer for money, sign-in, data)
                          PASS ─► one commit with its records      FAIL ─► fix once, then park it
                          queue empty ─► end check: every suite + a UI tester; findings become fix tasks
```

The two ideas that matter most:
1. **Done when lines decide what "done" means, before any code.** One line, one check, written so a test can judge it.
2. **The agent that builds never grades its own work.** A fresh agent with only the Done when lines and the diff
   does, and a diff that deletes or loosens a test fails.

## Quick start

1. In your project's folder:
   ```bash
   git clone --depth 1 https://github.com/OWNER/ai-workflow-kit && rm -rf ai-workflow-kit/.git
   ```
   (or Code → Download ZIP, unzip it into your project and rename the folder to `ai-workflow-kit`).
2. Open Claude Code in your project and paste the prompt from [`START-HERE.md`](START-HERE.md). It finds and runs
   your build and test commands, asks you two questions, puts the files in place and removes the kit folder.
3. Restart Claude Code, write a few lines into `QUEUE.md` → Intake, and type `/work`.

## Who it's for

Solo developers and small teams who want the agent to keep working while they're away, and to come back to
commits they can trust rather than a chat to read. It fits less well where every change goes through a pull
request: here the agent commits on a working branch and you push.

- **Light to install:** about 20 text files; `gitleaks` is optional for the secret scan in the commit hook.
- **Not light on tokens:** every task runs a builder and a separate checker. Tasks tagged `small` can run on a
  cheaper model with a lighter check.
- **Safe by default:** `.claude/settings.json` blocks `git push`, deploy commands, `reset --hard`, killing
  processes and reading `.env`, in every permission mode. You release; the agents never do.
- **Asks you only what's yours:** money, legal risk, direction, or taste on something you can see. Each question
  comes with its suggested answer.

Built and used daily on a production SaaS, and set up unaided on two other projects (one with tests, one without).

## What's in the box

| File | Goes to | What it is |
|---|---|---|
| `START-HERE.md` | read it, then it's removed | Setup in three steps, with the prompts to paste |
| `docs/WORKFLOW.md` | same | The method, for people: each step and why it exists |
| `WORKER.md` | repo root | Standing orders the builder agent follows every task |
| `QUEUE.md`, `QUEUE-done.md` | repo root | Where you drop work (Intake, Triaged, Work order, Needs you); finished tasks |
| `TEST-BY-HAND.md` | repo root | What a person checks before a release |
| `docs/CONVENTIONS.md` | same | Commit messages, decision records, code comments |
| `docs/decisions/` | same | Decision record template and index |
| `CLAUDE-rules.md` | paste into your `CLAUDE.md` (or `AGENTS.md`) | The house rules block |
| `.claude/settings.json` | same (merge into yours) | Hard blocks in every mode: no push, no deploy, no `.env` |
| `.claude/agents/*.md` | same | The four roles: worker, verifier, reviewer, ui-tester |
| `.claude/skills/work/SKILL.md` | same | `/work`: runs worker → verifier → commit until the queue is empty |
| `scripts/qa.sh` | same | One gate command, with a coverage floor that only goes up |
| `scripts/hooks/commit-msg`, `scripts/install-hooks.sh` | same | Commit title check and a secret scan |
| `scripts/agents.sh` | same | Optional: runs `/work` in the background and restarts it after a usage limit |

`README.md` and `LICENSE` stay in the kit; they are not copied into your project.

## Set up by hand (about 20 minutes)

1. Copy everything except `README.md`, `START-HERE.md` and `LICENSE` into the repo root; the folders match
   (`docs/`, `.claude/`, `scripts/`).
2. Fill the `{{…}}` placeholders. `grep -rn '{{' .` lists them; they are the gate commands, the test commands and
   the working branch. Delete what doesn't apply (no frontend → drop the browser and UI tester parts).
3. Paste `CLAUDE-rules.md` into your `CLAUDE.md`, and adjust the "auto vs needs-you" table in `WORKER.md` to your
   risky areas (auth, payments, migrations, paid APIs).
4. `sh scripts/install-hooks.sh` once per clone. Add `.verify/` to `.gitignore` (saved test runs live there).
5. Put a few lines in `QUEUE.md` → Intake, then run `/work` in Claude Code (or `sh scripts/agents.sh` to run it in
   the background). `/work dry` shows what would run.

Without subagents (another tool): do the same by hand. One session builds and stops at READY; a second, fresh
session gets only the Done when lines and `git diff`, and gives PASS or FAIL.

## Your part

- Write rough lines into Intake. Put exact values in quotes, say which screen or file, end a line with `!` to jump
  the queue.
- Answer `QUEUE.md` → **Needs you**. Each question has a pick and says what happens without an answer.
- Before a release, walk `TEST-BY-HAND.md`.
- Release yourself. The agents never push or deploy.

## License

MIT. See [`LICENSE`](LICENSE).
