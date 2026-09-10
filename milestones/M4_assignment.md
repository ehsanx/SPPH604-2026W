# M4 — Reanalysis Letter and Reproducible Repository

**Group · Reanalysis letter + code zip · Weight and deadline: see the syllabus**

---

## What M4 is

A short, densely written **reanalysis letter or commentary (~1,000–1,500 words)**,
accompanied by your fully reproducible repository.

M1 asked what the paper's analysis *does*. **M4 asks what it should have done, and what
difference that makes.** The distinction matters: a letter that only restates your
replication is an M1 deck in prose. A reanalysis says what you changed, why the change was
warranted, and what the result does when you make it — including when the answer is
"nothing much."

It is the capstone of the whole sequence: the paper locked at M0, replicated at M1,
critiqued by another group at M2, defended at M3, resolved here into a single statement of
what stands.

## What you submit

Two files, by the deadline in the syllabus:

1. **The reanalysis letter (PDF)**, ~1,000–1,500 words.
2. **A zip archive of your fully reproducible repository, downloaded from GitHub.**

Your letter must include a **cover note** on the final page, and the same text as
`COVER-NOTE.md` in the root of your repository zip. It contains a one-line contribution
note per member, any external-feedback disclosure — including any group whose conversation
or M1 review influenced a change you made — and an AI Use Statement.

## What the letter has to do

Four things, in whatever order the argument needs:

**1. Name the analytic decision you are contesting.** Not a list of everything imperfect
about the paper — the one or two choices your work actually bears on. State the paper's
choice, state yours, and say why yours is defensible.

**2. Show what the change does.** Re-estimate under your specification and report it
against theirs. Be specific about what you altered: the adjustment set, the estimand and
whether the contrast answers the question the paper asks, whether the estimate respects
the design and outcome structure the data actually have, how the missingness was
handled, whether an interaction was assessed on the scale the claim needs. A change
that moves the estimate and a change that leaves it intact are both results — report
whichever you got.

**3. Separate three kinds of finding.** A letter this short cannot say everything, so what
it does say has to be calibrated to the evidence:

- what is **corrected** — the original is wrong and you can show it;
- what is **re-priced** — the finding survives, but the uncertainty around it does not
  match what was claimed;
- what **stands** — you looked, and the original holds up.

**4. Carry forward the analysis you defended at M3**, and document anything that has
changed since. The letter inherits the best-defended version of your work, not a fresh
one: if the estimate, model or population differs from what you defended, say so and say
why. Account for the M2 critique too — what you accepted, what you rejected and on what
grounds — and for any change you made on your own initiative. A letter that never mentions
the critique has left out part of the work; rejecting a point with a stated reason is a
complete answer, ignoring it is not.

Avoid a bottom line stronger than the evidence supports. That is the most common way a
technically sound reanalysis loses marks.

## Writing it as a letter

This is a journal genre, not an essay. Letters to the editor and commentaries are read by
people deciding quickly whether the objection is substantial, so:

- lead with the claim, not the background;
- every paragraph earns its place — at this length there is no room for a literature
  review or a methods tutorial;
- cite the paper's own table and figure numbers when you contest them, so a reader can
  check you without hunting;
- write so the original authors could reply. Precise disagreement invites a response;
  vague criticism does not.

## Reproducibility

In health data science, code that only runs on your machine is considered unfinished. We
grade strictly on **auditability**: your code must run from start to finish **on a fresh
machine without manual intervention**.

Every number, figure and table in the letter must have been produced by code in that
repository — including the numbers you quote from the original paper for comparison, which
should be traceable to where you took them from. If you adapted the original authors'
published code, cite it in your repository README and identify in your cover note which
scripts or functions are derived from it and what you changed.

Your repository is part of the submission, not an attachment to it. A reader who disagrees
with your conclusion should be able to run it and see where you and the authors part
company.

## How it is graded

The usual three-band scale applies:

- **Exceptional** — deep insight, discrepancies traced to their root cause, or masterful
  engagement with counter-arguments.
- **Adequate** — the mechanics executed correctly, with sound epidemiological
  understanding.
- **Weak** — generic, superficial, or incorrect.

## Bonus — journal-submission pledge

Submit, **alongside M4**, a signed pledge committing to submit the work to a peer-reviewed
journal by the date the syllabus names.

If you act on the pledge, the per-member contribution notes you have been writing since M0
are exactly the contributorship statement a journal will ask you for.

## Weight, deadline and policy

See the syllabus. It governs what this milestone is worth, when it is due, whether the
weight can be shifted, and any late penalty. This page describes the task only.
