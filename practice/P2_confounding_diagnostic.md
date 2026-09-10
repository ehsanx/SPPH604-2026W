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
# P2 — Confounding diagnostic (Table 1)

**Week 4 · applies L3 (Confounding) · optional and ungraded — no separate deadline, nothing to submit; M1 is assembled from these five increments**
**Keep in your group GitHub repo:** a reproduced Table 1 + a variable-role table + a crude-vs-adjusted comparison.

## The question this week
*How do your exposure groups differ, what causal role does each variable play, and
what does that imply for adjustment?* Table 1 is not a formatting exercise, and it is
not where you decide what to control for. It describes how the groups differ and
exposes sparse cells, positivity problems (a covariate level with almost nobody in one
group), and coding errors; the adjustment set comes from causal and temporal reasoning
about the variables it describes.

## What to do
1. **Reproduce Table 1** stratified by your exposure, including the p-value column if
   the paper printed one — reproducing what they published is the point of this step.
   Then read the table for what it can actually show: how the groups differ, cells too
   sparse to support a model, positivity problems, and values that are impossible or
   miscoded. No Table 1 comparison selects your adjustment set, and a p-value least of
   all — it turns significant on sample size alone. Read the descriptive contrasts as
   magnitudes instead: the differences in means and proportions, or a standardized
   difference (the group gap in pooled SD units), which does not move with N.
2. **State the primary contrast** (which two groups, which exposure–outcome
   association) in one sentence.
3. **Classify the important variables** by role — **confounder / mediator / collider
   / effect modifier** — using temporal and causal reasoning (a small DAG helps).
   Prespecify a defensible confounder set.
4. **Compare crude vs adjusted.** Fit an unadjusted association and one adjusted for
   your prespecified set, on the **same rows**, so any difference is attributable to
   adjustment. Report the move as what your adjustment set produces, and say what the
   comparison can and cannot establish: adjustment can remove confounding, but it can
   also remove real effect through a mediator or add bias through a collider, and this
   comparison cannot tell you which happened.

## Deliverable
- Reproduced Table 1 (CSV + rendered) → your M1 **Table 1 slide**.
- A variable-role table (variable · role · reason · in adjustment set? y/n).
- Crude and adjusted estimates side by side, with a 2–3 sentence interpretation.

## Worked example — MASLD/NHANES demonstration
- Continuous variables reproduce **exactly** (Age 51.0 (16.6), BMI 33.2, SBP/DBP
  identical) — a good sign your cohort is right.
- **Trap 1 — comorbidities are composites, not self-report.** Self-report alone
  under-counts: hypertension needs "self-report **or** measured BP ≥140/90" to reach
  the paper's 52.6% (54.1 reproduced); dyslipidaemia needs labs + meds to reach 57.7%.
- **Trap 2 — printed percentages that disagree with their own counts.** The income
  (PIR) percentages appear **interchanged**: the counts imply High 22.1% / Low 23.0%,
  but the paper prints 23.0 / 22.1. Catching arithmetic like this is exactly the P2
  skill.
- **The age spread is the question, not the answer:** group ages run 40 → 62 years.
  The table reports the spread. Age is a confounder here for a causal and temporal
  reason, not a numeric one: it raises phenotype membership *and* raises mortality,
  and it precedes the exposure — which is also what rules it out as a mediator.

## What good looks like
- **Exceptional:** adjustment set justified from a DAG/temporal logic (not
  "everything"); notices a definitional or arithmetic problem like the PIR swap;
  crude-vs-adjusted change reported as what the adjustment set produces, without
  claiming which mechanism produced it.
- **Adequate:** Table 1 reproduced; roles mostly correct; sensible adjusted model.
- **Weak:** "adjusted for all variables in the dataset"; roles unassigned; no interpretation.

## Be ready to defend (M3)
> *"Age differs hugely across your groups. Is it a confounder or is it on the causal
> path — and what would controlling for it do if you're wrong?"*

## AI co-pilot note
A co-pilot can produce a fluent, well-formatted Table 1 that is **silently wrong** —
in one tested reproduction, a `tableone` bug rendered *every* categorical comorbidity
as `FALSE` (0 events) and no one noticed from the output alone. Spot-check counts
against the raw variables.

## Lab → project handoff
You are applying **L3 (Confounding)** — moving from Table 1 to crude, conditional,
and marginal estimates (EpiMethods `confoundingE`). Justify the confounder set from
science, not from a stepwise algorithm.
