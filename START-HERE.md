# Start here

Three steps. The AI does the setup itself.

## 1. Put the kit into your project

In your project's folder (next to your code):

```bash
git clone --depth 1 https://github.com/OWNER/ai-workflow-kit && rm -rf ai-workflow-kit/.git
```

Or download the ZIP, unzip it there and rename the folder to `ai-workflow-kit`. Then open Claude Code in your
project as usual.

## 2. Paste this once

```
Set up the workflow in ai-workflow-kit/ for this project.
Read ai-workflow-kit/README.md and ai-workflow-kit/docs/WORKFLOW.md first.
- Copy the kit's files (all but README.md, START-HERE.md and LICENSE) into place at the project root.
  Never overwrite a file I already have: merge into it.
  CLAUDE-rules.md goes at the top of my CLAUDE.md (create it if there is none).
- Fill every {{...}} placeholder from what this project really uses: find the build, test, single-test,
  coverage and browser-test commands by reading the project, and run each one once to prove it works.
  Delete the parts that don't apply (no frontend: drop the browser tests and the UI tester).
  If a command starts a server, check its port is free first; if it's busy, stop nothing: skip it and tell me.
- Ask me only two things, with your suggested answers from the code: the branch to commit on, and the risky
  areas the agents must not touch alone (sign-in, payments, migrations, paid APIs).
- Add .verify/ to .gitignore, run sh scripts/install-hooks.sh, and remove the ai-workflow-kit/ folder.
- Show me what you changed. Don't commit until I say.
```

Then close Claude Code and open it again, so it loads the new agents and the `/work` command.

## 3. Every day

**Add work.** Write rough lines into `QUEUE.md` under Intake, one per thought. Or tell Claude:

```
Add to the queue: <what you want, as rough as you like>
```

**Run it.** Type:

```
/work
```

It takes one task at a time: writes its "done when" lines, writes failing tests, builds until they pass, has a
separate agent check it, then commits. It stops when the queue is empty. `/work dry` shows what it would do first.
The first time, stay and approve the commands it asks for; pick "always allow" for your test and build commands.

**Answer its questions.** Anything only you can decide waits in `QUEUE.md` → Needs you, with its suggestion. Write
your answer under it, or tell Claude:

```
Answer the queue question about <thing>: <your answer>
```

**Before you release,** walk through `TEST-BY-HAND.md`. Then release yourself: the agents never push or deploy.

## One task by hand, without /work

```
Do <the task> the way WORKER.md says: Done when lines first, failing tests first, build until they pass,
then start a fresh verifier agent with only the Done when lines and the diff. Commit only on its PASS.
```
