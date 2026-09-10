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
# P3 — Effect modification (interaction)

**Week 5 · applies L4 (Interaction) · optional and ungraded — no separate deadline, nothing to submit; M1 is assembled from these five increments**
**Keep in your group GitHub repo:** stratum-specific estimates + a formal interaction test + a short interpretation.

## The question this week
*Does your main exposure–outcome association differ across a scientifically
meaningful subgroup?* This week you take the main estimate you built in P2 — your
current best estimate, before the design-aware re-estimate at P4 — and ask whether one
number actually hides two, i.e. whether some group carries the effect.

## What to do
1. **Choose one effect modifier with a rationale.** Sex, age band, income, or a
   clinical subgroup — and say *why* modification is biologically/socially plausible.
   One well-argued modifier beats a fishing expedition.
2. **Estimate stratum-specific effects.** Fit the association separately within each
   level of the modifier and report the estimates side by side.
3. **Test interaction formally, on the right scale.**
   - *Multiplicative:* an exposure × modifier product term in your outcome model.
   - *Additive* (often more relevant for public health): compare **absolute risks**
     across strata — for a time-to-event outcome, contrast predicted risks at a fixed
     horizon rather than forcing a logistic-model RERI.
4. **Interpret.** Report the stratum-specific estimates and the interaction test with
   their intervals, and state which scale you tested and why. A crude stratum
   difference is not an interaction test, and a null test is not evidence of
   homogeneity — say what the data show at the precision you have, and do not claim to
   have identified what produced any crude difference.

## Deliverable
- Stratum-specific estimates + the interaction test → your M1 **effect-modification
  slide**.
- 2–3 sentences: is there modification, on which scale, and does it change the story?

## Worked example — MASLD/NHANES demonstration
- The paper reports **one** hazard ratio per phenotype and never tests modification.
  A natural P3 question: **does the central-adiposity → mortality association differ
  by sex?** (Group II is 56% female; Group I only 15% — so sex is entangled with the
  exposure and worth probing.)
- **Right tool for the outcome:** mortality is time-to-event with censoring, so put a
  `group × sex` term in the **Cox** model (multiplicative), and for additive
  modification compare **predicted 6-year mortality risk** by sex within group — *not*
  a logistic RERI on an "ever died" flag.
- A defensible result is often "no meaningful modification" — reported clearly, that
  is a complete P3.

## What good looks like
- **Exceptional:** a modifier chosen for a stated scientific reason; correct
  stratum-specific estimates; interaction tested on the appropriate scale for the
  outcome type; reports the interval, not just the p-value, and does not claim to have
  identified what produced a crude stratum difference.
- **Adequate:** a sensible modifier assessed with a product term and strata.
- **Weak:** a product term with no rationale; or a logistic RERI that discards
  follow-up time and censoring.

## Be ready to defend (M3)
> *"You report an interaction by sex. Is that genuine effect modification, or just
> what you'd expect from men and women having different baseline mortality? Defend the
> scale you tested it on."*

## AI co-pilot note
Because the interaction *lab* uses a binary-outcome RERI example, a co-pilot will
often copy that recipe — coding "ever died" and fitting logistic regression — which
throws away survival time. For a time-to-event paper you must move the interaction
into the survival model. Don't let the lab's convenient example dictate your project's
method.

## Lab → project handoff
You are applying **L4 (Interaction)** — product terms, stratum-specific estimates, and
additive vs multiplicative modification (EpiMethods `confoundingE2`). Assess it on the
scale your outcome demands.
