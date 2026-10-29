# Queue

Drop work into **Intake**. The worker triages it on its next tick, works the **Work order** top to bottom, and puts
anything only you can decide under **Needs you**. Finished tasks move to `QUEUE-done.md`.

## Intake

One line per thought, however rough. A newline is the only separator.

| Write this | Because |
|---|---|
| **Exact values in quotes or backticks** | A supplied string ships as written; a described one comes back as a question |
| **Say where**: the file, endpoint or screen | "the response of GET /orders" lands first try; "fix the orders thing" gets a question |
| **Say when you don't know**: "raise the limit, not sure to what" | It asks instead of inventing a value |
| **End a line with `!`** | Jumps the queue |

<!-- paste below this line -->


---

## Triaged

One stub per item drained from Intake: `- [ ] T-NN · title · auto|needs-you · small|deep · blocked: …`.
Full task blocks (`### T-NN · …`) are written under the stubs when a task is worked or needs you.


---

## Work order

Top to bottom. Each finished task is struck through with its date: `~~T-12~~ (done 3 Nov)`.

1. T-12 → T-13
2. …

**Test at the end**: when nothing `auto` is left above this line, the whole suites and one UI tester run over
everything since the last end check; findings go to the top as fix tasks, then the check runs again. A release waits
for it.

3. **After launch: the rare cases** (each needs two accounts in one browser, a second tab, or Back at one moment).

---

# Needs you

Only real questions: money, legal risk, direction, or taste on something you can see. Each one: a plain title, at
most five short lines (what a user sees, the options, the worker's pick, what happens without an answer). Answer
under it as `**Answer (<name>, <date>):** …`; the next tick moves it into the Work order and removes it here.

---

# Blocked

| Task | Blocked on | Who |
|---|---|---|
| _none_ | | |
