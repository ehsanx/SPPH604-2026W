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
# P1 — Analytic cohort

**Week 3 · applies L2 (Analytic data) · optional and ungraded — no separate deadline, nothing to submit; M1 is assembled from these five increments**
**Keep in your group GitHub repo:** a script that rebuilds the cohort + a flow table + a short `P1_notes.md`.

## The question this week
*Can you rebuild your paper's analytic cohort from the raw source data, and account
for every person who is included or excluded?* Rebuilding the sample **is** the
first result — everything downstream depends on getting this right.

## What to do
1. **Find the source files.** List every raw data file (and version/cycle) your
   paper's cohort is built from, and the key you merge on.
2. **Reconstruct eligibility.** Translate the paper's inclusion/exclusion criteria
   and exposure/outcome definitions into code. Build the exposure and link the
   outcome.
3. **Make a flow table.** Report **N after each exclusion step**, ending at your
   analytic N.
4. **Compare to the paper and explain the gap.** State your N vs the paper's. Trace
   any difference to a specific decision. **Do not tune your code to hit the
   paper's number.**

## Deliverable
- Reproducible cohort-building script (runs start-to-finish on a fresh machine).
- A flow table (CSV or figure) → becomes your M1 **cohort flow diagram**.
- `P1_notes.md`: your one-sentence study question, and a numbered list of every
  eligibility decision with the reasoning where the paper was ambiguous.

## Worked example — MASLD/NHANES demonstration
- Six NHANES cycles + linked mortality merged on `SEQN`; FLI computed; four
  BMI/WHtR groups formed. **Not a target — a comparison.** The paper reports N ≈ 6,300,
  groups 386 / 4,541 / 769 / 604 and 585 deaths; our reproduction's **full analytic file**
  lands on **N = 6,371**, groups **391 / 4,585 / 787 / 608** and **586 deaths**, and its
  **locked domain** — the rows carrying a valid fasting weight — is **6,048**. Getting
  6,371 rather than the paper's number is not a failure: it is the finding, and tracing
  *why* the two differ is the skill being taught. An unexplained exact match is worth
  less than a discrepancy you can account for.
- **Trap 1 — one sentence, three cohorts.** "Significant alcohol (>2 drinks/day men,
  >1 women)" coded three defensible ways gives **N = 4,308 / 5,944 / 6,371**. The
  paper's numbers match *no effective exclusion*. Which did the authors use? You
  cannot tell from the paper — so you **document the ambiguity**, you don't force it.
- **Trap 2 — a table label that disagrees with the Methods.** The Table 1 headers say
  "BMI < 25", but the non-obese groups have BMI medians of 27.6 and 28.8. The
  operative cut is **30** (from the Methods). Coding to 30 reproduces the groups;
  coding to 25 does not.

## What good looks like
- **Exceptional:** full step-by-step funnel; the residual N gap is *traced
  and explained* (e.g., complete-case on covariates; here, exactly one person
  missing serum creatinine); ambiguities documented rather than tuned away.
- **Adequate:** cohort rebuilt and runs; N close; most exclusions justified.
- **Weak:** "N matches ✓" with no funnel, or code that hard-codes the target N.

## Be ready to defend (M3)
> *"Show me one person who is in your cohort but not the paper's — and tell me why."*

## AI co-pilot note
A co-pilot will happily write code that filters until N equals the paper's number.
That is the exact failure this increment tests. You must be able to show the funnel
and defend each cut.

## Lab → project handoff
You are applying **L2 (Analytic data)** — multi-source download, merge, cleaning,
eligibility, and exposure/outcome construction (EpiMethods
`accessingE3` and `accessingE2`). Same moves, your paper's data.
