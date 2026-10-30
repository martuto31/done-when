# Privacy

done-when is a set of Claude Code skills and agent prompts. It has no server, no account and no telemetry.

- **What it reads:** files in the repository you run it in (the queue, code, tests, `git diff` and `git log`), and
  your git email (`git config user.email`), only to check that commits will carry the one you expect.
- **What it writes:** files in that repository (the queue, records, code, tests, `.claude/settings.json` at setup) and
  git commits on your machine. It never pushes.
- **What it sends:** nothing. The plugin makes no network calls of its own. What the agents read is processed by
  Claude Code under Anthropic's terms, as in any Claude Code session.
- **What it keeps:** nothing outside your repository.

Questions: [open an issue](https://github.com/martuto31/done-when/issues).
