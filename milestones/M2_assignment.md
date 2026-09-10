# M2 — Critique of Another Group's M1

**Group · Presented in class; slides due the same day · Weight and deadline: see the syllabus**

---

## What M2 is

In class, your group presents a **critique of the M1 you were
assigned** — another group's replication, not your own.

Pairings are announced when M1 is submitted, and run in a cycle so that **no group reviews
the group reviewing it**. Every member presents a section and answers questions on it.

## What you submit

**A slide deck (PDF), due the same day you present.** There is
no separate written round afterwards: the slides you present are the deliverable.

Your deck must include a **cover note** on the final slide, containing a one-line
contribution note per member, any external-feedback disclosure, and an AI Use Statement.
M2 is slides only, so there is no `COVER-NOTE.md` to file.

## Scope — three things, in about six slides

1. **Did their code run?** Not only whether it executed — whether it **regenerates the
   numbers in their deck**. Say how far you got, where it stopped, and which reported
   figures you could and could not reproduce from their repository.
2. **Two or three substantive points about the epidemiology.** The exposure and outcome
   definitions; the adjustment set and how it was justified; selection into the cohort;
   whether the stated interpretation follows from the estimate they actually report; and
   how far the finding would generalize. The analytic choices carrying that
   epidemiology are in scope here too — whether the estimate respects the design and
   outcome structure the data actually have, whether the missing-data handling matches
   the missingness they actually have, whether the quantity estimated is the one the
   claim needs.
3. **Do you agree with their choice of dominant threat?** If not, which threat you think
   dominates, and why.

That is the whole scope. You do **not** write code for the other group's paper, and you do
**not** implement anything on it — running what they gave you is reproduction, not
reimplementation. Your recommendations are input that they must answer at M3.

**What you may take away from reviewing.** You hold another group's unpublished deck and
repository in order to review them. You may not copy or adapt their code, text, figures,
output, or distinctive implementation into your own M2, M3 or M4, and crediting them does
not make it permitted. What reviewing may do is send you back to your own analysis: if it
shows you something you should reconsider, justify and implement the change yourself, on
your own paper, and disclose the influence in your cover note.

**Ignorance is not a reviewer's position.** You are equipped to judge all three of these
on a paper you did not choose: that is what the course has been training, and it includes
the clinical material. You are not expected to have arrived knowing the clinical
literature of a paper you did not choose; you are expected to go and read enough of it to
make the point you are making. Where a point turns on something you do not already know —
a diagnostic threshold, a disease definition, an unfamiliar estimator, a survey design
feature — find out; the paper's citations and the code in front of you are within reach.
Put it as a **question** only after you have looked and the answer is genuinely unsettled,
and then say what you checked. "The paper cites no source for this threshold" is a
finding. "We are not clinicians" is not.

## Using AI while you review

Use AI to tighten language you wrote, and to fix problems on **your own machine** while
running their code — a package that will not install, an R version, a path their script
assumes, what a generic R error means. The rule for what you type into the tool is:
**paste what is yours or public; describe what is theirs.**

Yours or public: your own `sessionInfo()`, your own installation log, package
documentation, and an error message you have stripped of their code, file names, variable
names and numbers. Theirs: every line of their code, and their slides, output, logs,
`README`, file listing and results — none of it goes into any AI tool, in whole or in
part, pasted, uploaded, screenshotted or retyped. If you cannot ask the question without
quoting their work, ask the teaching team instead; that is what we are for.

AI does not write the critique. Another group is graded on the feedback they receive, and
a machine-generated review harms real people. Disclose your AI use in the cover note.

## How it is graded

You are graded on the **quality of the critique** — whether you identify real
methodological weaknesses, express them professionally, and suggest a practical way
forward. **Never on how many faults you produce.**

A critique that finds little wrong is entirely acceptable **when it is evidenced**: a
reviewer who recommends acceptance with reasons is doing the job. A review that finds
little to correct is judged on the evidence it gives for that conclusion, not penalised
for the absence of faults.

The usual three-band scale applies:

- **Exceptional** — deep insight, or masterful engagement with counter-arguments.
- **Adequate** — the mechanics executed correctly, with sound epidemiological
  understanding.
- **Weak** — generic, superficial, or incorrect. Criticism generic enough to fit
  any observational study lands here.

## Weight, deadline and policy

See the syllabus. It governs what this milestone is worth, when it is due, whether the
weight can be shifted, and any late penalty. This page describes the task only.
