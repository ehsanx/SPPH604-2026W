# M3 — Live Individual Oral Defense

*Model submission. We are **Group A**. This is the improved analysis and the individual
defense of it. Our M1 is in `../M1_replication/`; the critique we received is in
`../M2_critique/`; every number below is re-derived in
[`M3_defense_evidence.qmd`](M3_defense_evidence.qmd).*

*Read the presentation slides first, then the Q&A. The slides show **what** we did. The
Q&A is where it has to hold up.*

---

## Slide 1: What we are defending, and what has moved

Our locked estimand is unchanged: **Group IV vs Group III, weighted Model 1**, on the
paper's own covariate set. What has changed since M1 is how we account for two things
around it.

| | Source | Outcome |
|---|---|---|
| How we describe cohort selection | **Reviewer (M2)** | **Changed** — split into two mechanisms |
| Corroboration from the paper's Table 2 | **Reviewer (M2)** | **Changed** — demoted to consistency |
| The TyG item on "what would change our mind" | **Reviewer (M2)** | **Changed** — restated |
| Which threat dominates | **Reviewer (M2)** | **Retained**, with a revised reason |
| Missing cancer status in Model 1 | **Ourselves** | **Tested, no change** |
| Estimand, adjustment set, design, variable definitions | — | **Unchanged** |

Speaker notes: Lead with the traceability table, not with the reviewers. Two of the six
rows are ours rather than theirs, and one is a "we tested it and kept it" — the point of
M3 is that all three are legitimate.

---

## Slide 2: What the critique got right, and where we push back

**Right, and we adopted it.** Our M1 cited the paper's published Table 2 — Group III 3.175
and Group IV 3.155 against Group I, implying about 0.99 — as though it corroborated our
locked result. The reviewers are correct that this is not independent confirmation: it is
the same data, and our own detail note already conceded no interval is recoverable because
the covariance of the two published coefficients is not reported. **We have demoted it to
a consistency observation.**

**Right, and we adopted it.** Our "what would change our mind" list included a design-aware
re-run of the authors' TyG sensitivity. The reviewers are right that this could not settle
the locked question whatever weights were used, because that analysis is against Group I.
**We have restated the item** to say what a TyG re-analysis would actually have to
estimate.

**Partly right — and it forced the most useful change we made.** They nominate selection
into the cohort as the dominant threat. We accept selection is consequential and that our
M1 under-described it. But their slide treats it as **one** mechanism, and it is two. See
Slide 3.

**Where we push back.** They rank selection above estimand–adjustment-set alignment on the
grounds that an unstated estimand is "a repairable reporting failure." We think that
understates it: if the target quantity is not named, there is no fact of the matter about
whether the adjustment set is right, so the alignment problem is *prior* to the selection
problem rather than smaller than it. We retain our ranking, on a narrower argument than we
gave at M1 — see Slide 5.

---

## Slide 3: Reviewer-prompted work — the selection is two mechanisms, not one

The evidence pack counts them separately:

| | n |
|---|---:|
| adults 18+ | 36,580 |
| (1) sampled into the fasting subsample | 14,962 |
| (2) of those, FLI computable | 14,170 |
| lost at step (2) | 792 |

- **(1) is selection by design.** NHANES decided who was asked to fast. It is known and
  planned, and `WTSAF2YR` exists to account for it — which is why we weight by it and
  subset the design rather than the rows. Under the survey design this step is *handled*.
- **(2) is item-level availability.** Among people already sampled to fast, FLI still needs
  triglycerides, GGT, BMI and waist all present. No design weight accounts for that, and
  whether it is ignorable depends on why those measurements are absent — which the public
  files do not tell us.

**They bound different things.** (1) bounds the **target population**: our estimate speaks
to fasting-sampled US adults, and the weights carry it there. (2) is a potential
**selection bias within** that population, and it is the one that could distort the
contrast itself.

Speaker notes: This is the change we are proudest of and it came from the review. Be
explicit that we are not conceding the ranking by adopting the distinction — adopting a
better description of a threat is not the same as agreeing it dominates.

---

## Slide 4: Self-initiated work — could incomplete cancer status explain the result?

**No reviewer asked for this.** Cancer status is the only Model-1 covariate carrying any
missingness, and we were not willing to defend an estimate that rests on dropping people
without testing it. On the locked contrast, design-aware, with the paper's Model 1
unchanged:

| Locked estimand, weighted Model 1 | HR (95% CI) |
|---|---|
| complete case | 1.29 (0.90–1.86) |
| all missing assigned **no cancer** | 1.29 (0.89–1.85) |
| all missing assigned **cancer** | 1.29 (0.89–1.85) |
| MI (m = 10), outcome in the imputation model | 1.29 (0.89–1.85) |

- **All four agree to the displayed precision.** That is the finding, and it is a result:
  the estimate we defend does not depend on how the incomplete records are handled.
- **We did not widen the adjustment set to produce a comparison.** Adding covariates until
  the missingness bites would have changed the estimand and answered a question nobody
  asked.
- **The two extreme assignments are transparent global scenarios, not bounds.**

**What this does not do.** It says nothing about selection. It concerns incomplete cancer
status among people **already in the cohort**; it cannot speak to anyone who never entered
it. Stability under missing-data sensitivity is not transportability, and we are not
offering it as an answer to Slide 3.

Speaker notes: The last paragraph is the one to say slowly. The tempting move is to let
"1.29 held" absorb the reviewers' selection objection, and it does not touch it.

---

## Slide 5: The analysis we defend

- **Estimand, adjustment set, survey design and variable definitions: unchanged from M1.**
  Nothing in the critique or in our own re-analysis gave us a reason to move them, and
  changing them would have made M1 and M3 incomparable.
- **The locked estimate stands at 1.29 (0.90–1.86)**, complete case, design-aware, with
  three sensitivity analyses agreeing.
- **Dominant threat: we retain estimand–adjustment-set alignment**, on a narrower argument
  than M1 gave. Not "the estimand is unstated and that is bad", but: *until the target
  quantity is named, no adjustment set can be shown to be the right one, and the
  attenuation has no unique interpretation.* Selection then bounds where the answer travels
  — which is why we now report the two mechanisms separately rather than folding them into
  one bullet.
- **What would still change our mind:** a stated target quantity with a causal model
  supporting the adjustment set; evidence on why FLI components are missing at step (2);
  or a pooled sample large enough to resolve the interaction.

Speaker notes: Close on what is unchanged, not on what moved. A defense that lists only
changes implies the original was mostly wrong, and it was not.

---

## Q&A Transcript

**Examiner:** Your headline number is identical across four missing-data approaches. Is
that reassuring, or does it just mean the sensitivity analysis had nothing to work with?

**Student (AB):** Both, and the second is the honest half. Only 109 observations are
incomplete, and only on one covariate, so no reasonable handling of them could move a
hazard ratio far. What the analysis rules out is a specific alternative explanation — that
our estimate is an artefact of dropping those records. It does not demonstrate robustness
in general. If someone wants to know whether the estimate is fragile, missing cancer status
is the wrong place to look; selection at step (2) is the right one, and we cannot test it
with these data.

**Examiner:** Your reviewers said selection dominates. You kept your own ranking. Convince
me that is not just defending your original position.

**Student (CD):** We changed our description of selection because they were right about it,
and we changed two other things they asked for. Where we differ is on ordering. Their
argument is that an unstated estimand is repairable in a sentence. Ours is that the
sentence is not cosmetic: without a named target quantity, "is this adjustment set
correct?" has no answer, so we cannot even say whether the attenuation reflects confounding
control or over-adjustment. Selection tells you where an interpretable estimate travels.
Alignment tells you whether you have an interpretable estimate to travel with. We think the
second comes first. We would have conceded if they had shown that naming the estimand
leaves the analysis unchanged — that is the argument that would move us.

**Examiner:** You ran a missing-data analysis nobody asked for. Why was that a good use of
your time rather than a detour?

**Student (EF):** Because we would have been asked today, and "we did not check" is a worse
answer than any number we could have got. It also disciplined the rest of the work: once we
had decided to test the locked contrast rather than a convenient wider model, it was
obvious that the widening was the thing to avoid. An earlier draft of ours added income and
systolic blood pressure so the comparison would show movement. That would have been a
different adjustment set and a different estimand, and it would have manufactured a finding
rather than tested one. We deleted it.

**Examiner:** Which part of this was yours?

**Student (EF):** The missing-data work on Slide 4, including the decision to keep the
outcome in the imputation model rather than imputing on covariates alone, and the decision
to drop the wider model. CD wrote the response on ranking; AB re-ran the design-aware fits
and checked that the domain is subsetted rather than the rows.

**Examiner:** If you had one more week?

**Student (AB):** Step (2). We would try to characterise who loses an FLI component and
why — whether it tracks anything measured — because that is the mechanism that could bias
the contrast rather than just relocate the population. Everything else we would leave
alone.
