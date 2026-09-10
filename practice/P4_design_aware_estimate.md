---
output:
  pdf_document:
    latex_engine: xelatex
  html_document: default
geometry: margin=1in
header-includes:
  - '\usepackage{newunicodechar}'
  - '\newunicodechar{→}{\ensuremath{\rightarrow}}'
  - '\newunicodechar{≈}{\ensuremath{\approx}}'
  - '\newunicodechar{≥}{\ensuremath{\geq}}'
  - '\newunicodechar{≤}{\ensuremath{\leq}}'
  - '\newunicodechar{×}{\ensuremath{\times}}'
  - '\newunicodechar{·}{\ensuremath{\cdot}}'
  - '\newunicodechar{½}{\ensuremath{\tfrac{1}{2}}}'
  - '\newunicodechar{…}{\ldots}'
---
# P4 — Design-aware main estimate

**Week 6 · applies L5 (Survey analysis) · optional and ungraded — no separate deadline, nothing to submit; M1 is assembled from these five increments**
**Keep in your group GitHub repo:** the reproduced main estimate + a design-aware re-estimate + a comparison.

## The question this week
*What is your best estimate of the main association once you respect how the data
were actually generated?* First reproduce the paper's headline number; then
re-estimate it the way the study **design** demands, and explain any difference.

## What to do
1. **Define the estimand** in one sentence (which contrast, which outcome, what time
   horizon).
2. **Replicate the paper's main model** exactly as they fit it.
3. **Respect the feature you named at M0 criterion 5.** For a complex survey, use the
   weights, strata and clusters — and **subset the design object**, never treat the
   analytic sample as a simple random sample; that gives you a design-aware
   re-estimate.
   For a time-to-event outcome, keep follow-up time and censoring in a survival model,
   don't collapse to "ever died" — then interrogate the *specific* structural choice
   you named at M0 (time scale, censoring rule, index date, competing events) by
   refitting under a defensible alternative to it.
4. **Compare and interpret — but only what is comparable.** For a survey paper: point
   estimate, uncertainty and interpretation, naïve/published vs design-aware. That is a
   like-for-like contrast because the two fits are the same estimand on the same scale
   and differ only in the design. For a time-to-event paper with no weights there is no
   such pair: report the reproduced survival estimand, then what the alternative
   structural choice does to it, and say in one sentence what the paper's choice
   assumed. Never set a survival model beside a binary "ever died" model and call the
   gap a design correction — those are different estimands on different scales, and the
   gap measures the collapse, not the design.

## Deliverable
- The replicated main estimate (matches the paper) → your M1 **Table 2 / KM slide**.
- The design-aware re-estimate + a side-by-side comparison table.
- 2–3 sentences on what changed and why — this feeds your **M1** synthesis, and it is
  the kind of design choice you will be asked to evaluate when you review another
  group's M1 at M2.

If your paper is not a complex survey, the feature you respect is the one you named at
M0 criterion 5 — follow-up time and censoring — and the deliverable is a different
shape. You have no weight to switch on and off, so there is no naive-vs-correct pair to
table. What you keep in the repo is: the paper's survival estimand, reproduced with
follow-up time and censoring intact; a refit under a defensible alternative to the one
structural choice you named at M0; and 2–3 sentences on what that choice was doing to
the paper's conclusion. That is a structural interrogation rather than a numeric
correction — a different deliverable, not a lesser one.

## Worked example — MASLD/NHANES demonstration
- **Replicate first — the paper is *unweighted*.** An ordinary Cox model reproduces
  the headline: Group IV all-cause HR ≈ **15.1 unadjusted → ~2.9 fully adjusted**
  (the reproduction matches to 2–3 significant figures). Reproducing the *unweighted*
  result is the replicate step.
- **The improvement is the design the paper does not apply.** The cohort is the NHANES
  **fasting subsample** (FLI needs fasting triglycerides), so a design-aware estimate
  needs the **fasting-subsample weights (`WTSAF`)** pooled across six cycles, even
  though FLI also draws on non-fasting (GGT) labs.
- **Which weight is a rule, not a judgment call.** CDC's least-common-denominator rule:
  when an analysis draws on variables from different components, use the weight of the
  **smallest** applicable subsample. If your exposure needs a fasting analyte, the
  fasting weight governs — a larger-sample weight would weight to a population in which
  your exposure cannot be constructed. The exercise is to *name the straddle and apply
  the rule*, not to argue the choice open. Then report a `WTMEC`-weighted run beside
  it, **labelled as a sensitivity analysis** — it is not a defensible primary, but it
  shows how much the rule changed the answer.
- **Ask the comparison the paper didn't.** Estimate Group IV vs **II** and IV vs
  **III** directly, not only each vs Group I.

## What good looks like
- **Exceptional, survey route:** replicates the paper's model, then a correct
  design-aware re-estimate; names the weight/strata/cluster used and *why*; interprets
  the change.
- **Exceptional, time-to-event route:** reproduces the paper's survival estimand with
  follow-up time and censoring intact; names the structural choice identified at M0 and
  *why* it is contestable; refits under a defensible alternative and interprets what
  the paper's choice was doing. Offering a binary "ever died" model as the corrected
  estimate is not this band — it is the Weak band below.
- **Adequate:** main estimate reproduced; and either a reasonable design adjustment
  attempted (survey route), or the M0 structural choice named and probed even if the
  refit is incomplete (time-to-event route).
- **Weak:** refits with `svyglm` on "ever died," discarding follow-up time and
  censoring; or ignores the design entirely.

## Be ready to defend (M3)
> *"Which design feature did you respect, and why that one — and what turns on it?"*

For a survey paper the answer is a number: your headline estimate with the weight
versus without it. For a time-to-event paper it is not a number: it is what the paper's
structural choice assumed — the time scale, the censoring rule, the index date, how
competing events were treated — and what a defensible alternative does to the
conclusion. A binary "ever died" model is not an answer to this question.

## AI co-pilot note
A co-pilot often reaches for the *simplest* model that "works" — e.g. logistic
regression on a binary "died" flag — because it avoids the survival/design
machinery. That silently throws away follow-up time, censoring, and the sampling
design. Insist on the model the data structure requires.

## Lab → project handoff
You are applying **L5 (Survey analysis)** — contrasting ordinary sample summaries
with survey-design estimates, and subsetting the *design* rather than the data
(EpiMethods `surveydataE`).
