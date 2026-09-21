# Week 3 — Q2 in depth: from population to analytic cohort

Duration: ~2.5 h (Tue, before the Thu lab). Deck:
`lectures/slides/Week3_cohort_FLI_slides.qmd`.

> **Timing.** Per-slide markers below sum to **140 min including the break**, against a
> 150-minute cap — about 10 minutes of slack. The markers include the interactive moments
> (the vote on the alcohol codings, the type-the-funnel exercise on L2's code), so the
> total is what happens in the room rather than content plus unbudgeted discussion. The
> deck's speaker notes carry the identical split; **if you retime a slide, retime it in
> both files.** See *If you are running behind* at the foot of this file.

The lecture is one argument, and it is a continuation rather than a new topic: **Week 2
asked the six questions, and today is Q2 answered all the way down to code.** The spine is
conceptual definition → operational definition → the contest over the operations → the
funnel that makes the contest visible. A dedicated block at the end puts **Thursday's
actual L2 code** on screen, so the lab reads as the execution of Tuesday's lecture on a
second paper rather than as a change of subject.

> **Row-set discipline.** Every quantitative slide names the analysis set it quotes. The
> reconstruction has two and they are not interchangeable: **full reconstructed analytic
> file, N = 6,371** (what scripts 03–06 read) and **locked mortality-linked cohort,
> N = 6,048** (the `WTSAF2YR` subset). Saying "N" without saying which is the error this
> course exists to catch. Slide 17 puts the two side by side precisely so the habit has an
> object.

> **What this week does NOT do.** The survey mechanics belong to Week 6, the causal reading
> of adjustment to Week 4, and the missing-data methods to Week 7. Today the funnel's
> `MISSINGNESS` rows are named and counted, not treated.

## Learning objectives

1. Locate **target**, **source** and **analytic** populations in a published study, and
   name the **kind** of each narrowing step rather than treating all drops alike.
2. Reconstruct the MASLD case definition as data operations: **FLI ≥ 60** plus **≥ 1 of
   five** cardiometabolic criteria, each with its own threshold and variable.
3. Convert a prose eligibility paragraph into **executable logic with a comment citing the
   sentence it implements** — and recognise when the sentence does not determine the code.
4. Build and defend an **eligibility funnel** with N removed and N remaining at every step,
   and a **type** on every row.
5. State why you **never tune the cohort to hit the paper's N**, in terms of what the match
   would and would not demonstrate.
6. Recognise the same cohort-assembly moves in a **different paper** — the benzodiazepine /
   opioid exercise L2 runs on Thursday.

## Continuity

- **Last week (Wk 2 → L1):** the six questions for reading a Methods section; the NHANES
  anatomy (component families, `SEQN`, the fasting weight); and L1, which merged topic
  files into one clean person-level frame.
- **This week:** Q2 in depth. The frame becomes a **cohort**, and every step of that
  conversion turns out to be a defensible choice rather than bookkeeping.
- **M0 deadline today** — memos due 12 PM; feedback follows. The policy detail lives in the
  syllabus, not on a slide.
- **Sets up:** **L2** on Thursday (the same assembly, a different paper) and **P1** (the
  same assembly plus today's judgment, on the student's own locked paper).

### The division of labour, stated on Slide 2 and again on Slide 21

| | Teaches | On which paper |
|---|---|---|
| Tuesday (this lecture) | the **judgment** — prose eligibility → defensible logic | MASLD (Kueh) |
| Thursday (L2) | the **mechanics** — multi-cycle download, mortality linkage, eligibility steps | benzodiazepine / opioid |
| P1 | both, transferred | the student's locked paper |

**Say this out loud, twice.** L2 is EpiMethods `accessingE2` — NHANES 1999–2014,
benzodiazepine ± opioid use and all-cause mortality. It is **not** the MASLD build, and
that is deliberate: a student who has only ever assembled this one cohort cannot tell which
steps were general and which were ours. An earlier version of this deck told students L2
would "build the MASLD analytic dataset from the L1 frame," which is false on both counts —
L2 is an independent download of a different year range with a mortality linkage L1 never
touched.

---

## Frame · 6 minutes across the slides below

## Slide 1 — Title (1 min)
- The timing note lives in the speaker notes; nothing to say aloud beyond the framing line.

## Slide 2 — Q2, in depth, and this week's division of labour (4 min)
- Name it explicitly: **today is Q2** of last week's six.
- Put the framing question to the room — *"if two teams read the same methods paragraph,
  would they build the same cohort?"* — and take two answers before moving on. Most say
  "yes, obviously". Slide 12 is the refutation.
- Walk the Tue/Thu/P1 table. This is the first of two places Thursday's different paper is
  named; do not skip it to save a minute.

## Slide 3 — M0: deadline today (1 min)
- Memos due 12 PM; feedback on whether the teaching team agrees with their reading of the
  six criteria follows soon.
- **Keep it to that.** An earlier version of this slide recited the lock rule, the
  replacement clause and the late policy at students from the front of the room. Those
  belong in the syllabus and in the feedback they get back, not in a lecture slide.

## Part 1 — The case definition · 35 minutes across the slides below

## Slide 4 — Target, source, analytic, and what each step costs (6 min)
- Draw the nested circles if it helps, but the **labels on the arrows** matter more.
- Recall Week 2's five types by name: `ELIGIBILITY`, `DESIGN`, `MISSINGNESS`,
  `TARGET POPULATION`, `OUTCOME ASCERTAINMENT`. Only one is a missing-data problem.
- **Handle with care.** An earlier version of this course taught every drop as a preview of
  selection bias. That was wrong, and the measured balance in the blockquote is why:
  adults in and out of the fasting subsample differ by 0.2 years, 0.02 kg/m², 0.07 cm. The
  transferable habit is that the kind of each drop was **checked**, not assumed.

## Slide 5 — MASLD: a concept that has to become data operations (4 min)
- Note the NAFLD → MASLD renaming so they recognise both in the literature.
- The move to teach is left-to-right across the table: a conceptual ingredient becomes a
  data operation, and everything downstream inherits that operation's properties.
- **Do not let this land as criticism.** Every NHANES population study of MASLD this decade
  faces the same constraint.
- The concrete version of the point, and the one to say aloud: **nobody in this dataset was
  diagnosed with MASLD, so there is no column to read** — case status is the output of a
  calculation, and membership therefore depends on how the inputs are handled. An earlier
  draft of this slide said "anything computed can be recomputed, and can therefore
  disagree", which asserts the conclusion without showing the mechanism. The slide now
  promises the two demonstrations — the FLI boundary flip (Slide 8) and the alcohol
  sentence (Slide 12) — so deliver it as a promise, not as an aphorism.

## Slide 6 — Steatosis: the FLI, and where its inputs live (5 min)
- Say that the input table is the **same one from Week 2's Q2**, so it reads as a callback.
- The new column is *Fasting?*. One input needs a fasting lab, and that one binds the whole
  index to the fasting subsample — which is what Slide 18's feasibility point turns on.
- Structural dependence (`BMXBMI`, `BMXWAIST` build both the gate and the exposure) is
  **named, not diagnosed** — hold it exactly where Week 2 left it. M1 dissects it.

## Slide 7 — FLI, worked: one subject (6 min)
- Do the arithmetic **on screen**. Subject: TG 150 mg/dL, BMI 28.5, GGT 30 U/L, waist 99 cm
  → y = 0.681 → **FLI 66.4** → steatosis.
- Ask which term does the most work before revealing the column. Most guess BMI; it is
  waist (5.247 vs 3.962).
- The log terms are why you cannot eyeball who is over the cut.

## Slide 8 — The same subject, one lab value later (6 min)
- Change **only** TG: 150 → 110 gives FLI 59.5. The cut flips at **TG = 112.4 mg/dL**.
- The point: the one input that forced the cohort into the fasting subsample is also the
  one that decides case status at the margin — 40 mg/dL of TG is the whole difference
  between case and non-case.
- **Sourcing note.** The slide deliberately does not claim fasting TG varies by that much
  within a person between visits. Very likely true; not established by anything here. Bring
  a citation if you want to say it aloud.
- Ask what they would do about it. Honest answers: sensitivity at 55 and 65, or keep FLI
  continuous. Neither is available here because the definition is the paper's — and that
  constraint is itself worth naming.
- Flag that the BMI × WHtR 2×2 has exactly the same property.

## Slide 9 — Metabolic dysfunction: five criteria, ≥ 1 required (8 min)
- Give this the time. The table is the codebook-before-coding discipline in finished form,
  and it is what P1 asks them to produce for their own paper.
- **Five, not four.** Criteria 4 (TG) and 5 (HDL) are both lipids but are coded,
  thresholded and sexed separately. A student coding from a bullet that says
  "dyslipidaemia" writes one indicator where the definition needs two. This is the level-of-
  abstraction error the slide exists to prevent.
- ≥ 1 criterion drops **2 people (6,052 → 6,050)** here. Reassuring for this cohort,
  dangerous as a habit: a non-binding filter is still a reported filter.

## Part 2 — Eligibility as executable logic · 33 minutes across the slides below

## Slide 10 — Exclusions are scientific claims (6 min)
- Reframe "exclusion criteria" from a chore list into a set of claims, each needing a
  stated rationale.
- The comment-citing-the-sentence rule sounds trivial and is not: **it is the only thing
  that makes the next slide's problem visible**, because the ambiguity surfaces when you
  try to write the comment and find the sentence does not tell you what to type.
- **The age rule is the worked example, and it must be quoted correctly.** The paper states
  eligibility as **"aged > 18 years"**; we implement **`age >= 18`**. NHANES age is an
  integer, so those differ by everyone aged exactly 18. Week 2 already records this as a
  deliberate divergence (`Week2_nhanes_slides.qmd:327`, `:450`).
- An earlier draft of this slide put a **fabricated quote** in the code comment
  ("participants aged 18 years and older") and implemented `>= 18` against it, which both
  misquoted the paper and hid the divergence — on the slide teaching students to quote the
  sentence. If you edit this slide, check the quote against the paper.

## Slide 11 — The sentence (4 min)
- Read the criterion aloud — *"> 2 drinks/day (men), > 1 (women)"* — then let the silence
  sit. Almost everyone hears it as unambiguous on first pass. That reaction is the lesson.
- Take the three open questions one row at a time and ask the room to answer each before
  moving on: which variable, per what, and what happens to the missing.
- If you have the paper open, put its full Methods paragraph up alongside. The criterion on
  the slide is the operative clause as recorded in `reproduction/reproduction_report.md` §2.

## Slide 12 — One sentence, three cohorts (10 min) · **do not drop**
- The centre of the lecture. **Vote before revealing:** which reading would you defend?
  Take a count on each row.
- Then reveal: crude `ALQ130` removes 2,063 → N 4,308; frequency-weighted removes 427 →
  N 5,944; no effective exclusion → N 6,371. A swing of a third of the cohort.
- Walk the **distance column** — −1,992, −356, **+71** against the paper's ≈ 6,300. That is
  the evidence, and it lets the room draw the inference rather than being told it.
- State the claim at the strength the numbers support: the published figures are **far more
  compatible with no effective exclusion** than with either other reading. **Do not say
  they "match"** — 6,371 is not 6,300, and the residual +71 is accounted for on Slide 17.
- Resist supplying a resolution. There isn't one available from the paper.

## Slide 13 — The trap inside the trap: reserved codes (5 min)
- `777` = refused, `999` = don't know. Strip before any threshold rule.
- Left in, `ALQ130 > 2` reclassifies nine refusals as heavy drinkers: 2,063 → 2,072.
- **Say explicitly which trap owns which number.** The ~2,000 belongs to the
  drinks-per-drinking-day error; the nine belong to the reserved codes. An earlier version
  of this course fused them and was wrong by a factor of two hundred.
- The nine change no estimate, and that is why this is worth teaching: a wrong
  implementation that survives the result-didn't-move defence.

## Slide 14 — What we did, and why we are telling you (8 min)
- Our choice: `APPLY_ALCOHOL_EXCL <- FALSE` (`02_build_analytic.R:40`). It reproduces the
  published cohort and is the most transparent about the discrepancy.
- It is a **switch, not a hidden default** — the funnel prints
  `Alcohol exclusion applied = FALSE` as a row, so the setting lives in the artifact and
  cannot be forgotten by the next person to run it.
- This slide is what makes the previous three honest: we asked them to publish their coding
  decision, so here is ours, with the alternatives quantified.
- Ask what their own paper's equivalent switch is going to be.

## Slide 15 — BREAK (10 min)
- Leave the restart prompt up: *which of the three codings would you defend, and what would
  you write in the paper?*

## Part 3 — The funnel · 34 minutes across the slides below

## Slide 16 — The funnel, with a type on every row (9 min) · **do not drop**
- Put it on screen and leave it there. This is not a picture of the funnel; it **is** the
  funnel, emitted to `reproduction/logs/sample_funnel.csv`.
- Walk the **type** column, not the N column. The Ns are arithmetic; the types are the
  analysis.
- Row 2 is the one to dwell on: the second largest drop in the table is a `DESIGN` feature
  with a documented fix (`WTSAF2YR`), not missing data to impute away. Row 3 is the genuine
  missingness, and it is 792 people, not 21,618.
- Report removed **and** remaining on every line. A lone final N is not reproducible.

## Slide 17 — Two row sets, and they are not interchangeable (7 min)
- Read the two columns as two different objects, not as a right answer and a near miss.
- Read the paper's row separately, and say the group counts **in pairs** — 386/391,
  4,541/4,585, 769/787, 604/608, deaths 585/586 — so that when these anchors reappear in
  the survival weeks nobody hears ours as theirs.
- The habit being built is the row-set label, which every quantitative slide carries.

## Slide 18 — What the funnel reveals (5 min)
- **Keep the scoping exact: "after eligibility."** The unscoped version of this sentence is
  false against the table on the previous slide — age ≥ 18 drops 23,262, more than the
  fasting subsample's 21,618. The per-step drops are printed so a student can check rather
  than trust.
- Feasibility, before committing: is the exposure computable for enough of the target
  population? Within the fasting subsample, FLI is computable for 94.7% of adults.

## Slide 19 — Why you never tune the cohort to hit the paper's N (7 min)
- It follows directly from Slide 12 rather than being asserted: if one sentence moves N by
  2,063, an exact match is about as likely to mean *you guessed their ambiguity* as *you
  implemented it correctly*.
- Reframe success explicitly: at M1, a gap traced to a named step scores above a match that
  cannot be explained. The grading criteria say so.

## Slide 20 — Reviewing someone else's eligibility (6 min)
- The stance they bring to M2 and to their own defence at M3.
- The BMI header ("< 25" in Tables 1–2 against ≥ 30 in the Methods, with non-obese medians
  of 27.6 and 28.8) is the cleanest small example in the course of a typographic slip with
  real consequences — code to 25 and the groups do not reproduce.
- Note the hedge *"appear to be"*: we report what we can check and we do not diagnose
  intent.

## Part 4 — Thursday · 20 minutes across the slides below

## Slide 21 — L2 assembles the same object from a different paper (5 min)
- **Open by naming it**: the lab is a different paper, so nobody spends the block waiting
  for MASLD to appear.
- Then show that the first move is identical to L1's: eight cycles stacked, merged on
  `SEQN`. Ask what `all = TRUE` does to the row set — they answered exactly this question
  in Week 2 about `full_join` versus `inner_join`.
- Mortality is a separate linked file here too.

## Slide 22 — And L2 writes a funnel, it just does not know it yet (7 min) · **do not drop**
- The payoff slide for the whole lecture. They are looking at a real funnel in the wild in
  its crudest form: `dat1` … `dat6`, six eligibility steps with N in comments, ending at
  4,049.
- **Ask the room to supply the type row before revealing it.** Arguing about whether `dat2`
  (MEC participation) is `DESIGN` or `MISSINGNESS` is exactly the right argument.
- Then point at `dat4`: the complete-case step prints **no N**. The uncounted step is the
  one most likely to be doing quiet work — in this lab and in most papers.

## Slide 23 — One more thing to notice on Thursday (4 min)
- L2's eligibility required at least one of three drug classes, so its reference category
  "Neither" contains **only SSRI users** — an active comparator, not an unexposed group.
- The same shape as our Group I, which is **obese**. The eligibility rule and the reference
  category are the same decision seen twice: who you let in determines what the comparison
  can mean.
- Two different papers showing the same property is the evidence that it is general rather
  than a quirk of ours.

## Slide 24 — P1: the same two things, on your paper (4 min)
- L2 is the guided mechanics on a neutral paper; P1 is the same mechanics plus today's
  judgment, on theirs.
- Deliverables: a script that rebuilds the cohort, a typed flow table, and `P1_notes.md`
  with the one hardest adjudication.
- P1 is **optional and ungraded** — no deadline, nothing to submit; it is assembled into
  M1. Say this plainly so nobody hunts for a Canvas dropbox.
- The M3 question — *"show me one person who is in your cohort but not the paper's"* — is
  the real standard, and it cannot be answered from a final N.

## Close · 2 minutes

## Slide 25 — Where we landed (2 min)
- Close on the **transfer** claim, not on MASLD.
- Ask on the way out: what is the one sentence in your own locked paper that you already
  suspect will not survive being written as code?

## Slide 26 — Reference (uncounted)

---

## If you are running behind

Drop in this order. The first two cost the least.

1. **Slide 20 — reviewing someone else's eligibility (6 min).** M2 owns peer review; the
   BMI-header example can be reduced to one sentence on Slide 17.
2. **Slide 8 — the boundary flip (6 min).** The point survives as the last bullet of
   Slide 7, though you lose the best demonstration of dichotomisation in the lecture.
3. **Slide 18 — what the funnel reveals (5 min).** Fold the "after eligibility" scoping and
   the 94.7% into the Slide 16 walkthrough.
4. **Slide 5 — concept to data operations (4 min).** Week 2 covered the substance; go
   straight from Slide 4 to the FLI.

**Never drop Slides 12, 16 or 22.** The alcohol contest, the typed funnel, and L2's own
funnel are the lecture; everything else supports one of the three.
