# M2 — Critique of another group's M1 (Milestone 2 slide deck)

*Model submission. We are **Group B**. We were assigned **Group A's M1** on Kueh et al.,
BMJ Open 2026;16:e113719 — the deck reproduced in `../M1_replication/`. Read that deck
first; this one is the review of it.*

*Written with Group A's deck and repository in front of us and nothing else. We do not
know what they will do with any of this at M3.*

---

## Slide 1: What we reviewed, and where we land

- **Reviewed:** Group A's M1 deck (8 slides) and their repository zip.
- **Their headline:** the paper reproduces; they hold **two estimands apart** throughout —
  the replication contrast (IV vs I) and their locked scientific contrast (IV vs III) —
  and they name **estimand–adjustment-set alignment** as the dominant threat.
- **Our overall view:** a disciplined replication. The four-cell diagnostic on Slide 4,
  computed on one fixed row set, is better practice than most published sensitivity
  analyses, and their missing-data slide reports a null result honestly instead of
  dressing it up.
- **We have two objections about evidence, and we nominate a different dominant threat.**
  We are not asking them to start over.

Speaker notes: Open with the verdict. Note what we are *not* doing: we are not
manufacturing a missingness objection, because Slide 6 already shows the locked estimate
is unchanged under complete case, both extreme assignments and MI. Re-litigating a
question the authors already answered would be padding, and reviewers who pad get read
less carefully on the points that matter.

---

## Slide 2: Did their code run?

- **Yes**, end to end from raw data. We regenerated the sample funnel, the group sizes,
  the death count and both headline contrasts, and they match the deck.
- **The design question is answered in the code, and answered correctly.** They build the
  survey design on the full frame and `subset()` it to the MASLD-eligible domain, rather
  than filtering rows before `svydesign()`. We looked specifically because this is the most
  common NHANES error in the applied literature; they did not make it.
- **Their numbers are not typed into the deck.** Every figure is substituted at build time
  from emitted result objects, so a stale number cannot survive a rebuild. We could not
  produce a discrepancy between deck and code because the deck cannot disagree with the
  code by construction.
- **One gap:** their README does not list every package the pipeline loads, so a clean
  install stops twice before completing.

Speaker notes: "It ran" is not a finding. Say what was regenerated and what was checked
deliberately. The design-subsetting check is worth naming explicitly *because* it came back
clean — a reviewer who only reports faults gives the authors no information about what has
been verified.

---

## Slide 3: Objection 1 — the published table cannot carry the weight placed on it

- Slide 4 supports the alignment argument partly with the paper's own Table 2: published
  Model 1 gives Group III **3.175** and Group IV **3.155** against Group I, an implied
  IV-vs-III ratio of about **0.99**.
- Their own detail note concedes the interval for that implied ratio **cannot be
  recovered**, because the covariance of the two published coefficients is not reported.
- So the deck cites a point estimate with **no uncertainty statement** as corroboration for
  a claim about compatibility with no difference. Two hazard ratios rounded to three
  figures can imply a ratio near 1.00 across a wide range of underlying values.
- **What we are asking for:** keep the observation, demote the claim. "The published table
  is consistent with our estimate" is defensible; "the paper's own Table 2 points the same
  way" reads as independent confirmation, and it is not independent — it is the same data,
  without an interval.

Speaker notes: This is a reasoning objection, not a coding one, so running the pipeline
would never surface it. We are not saying the implied ratio is wrong. We are saying it is
being used as evidence when it is at best consistency, and the deck's own detail note
already knows this.

---

## Slide 4: Objection 2 — the TyG check is listed as a remedy but is not one

- Slide 8 lists "a design-aware re-analysis of the TyG sensitivity on the locked contrast"
  under *what would change our mind*.
- The authors' TyG sensitivity reports about **3.1** for both Group III and Group IV
  against Group I. That is the **replication contrast**, unweighted — precisely the two
  properties the deck spends Slide 4 arguing are the wrong ones for the locked question.
- Re-running it design-aware would not fix that. The contrast would still be against Group
  I, so it cannot adjudicate IV versus III whatever weights are applied.
- **What we are asking for:** either drop it from the list, or state what a TyG re-analysis
  would actually have to estimate — the IV-vs-III contrast under a TyG-based exposure
  definition — which is a different analysis from the one the authors ran.

Speaker notes: This is the point we expect most pushback on, and it is fair pushback: they
might reply that a design-aware TyG check speaks to exposure misclassification rather than
to the contrast. If so, say that on the slide, because as written the item reads as though
it would resolve the dominant threat, and it would not.

---

## Slide 5: We agree alignment matters — we do not think it dominates

- We accept that the target quantity is unstated and that this is consequential. We are
  **not convinced the evidence presented resolves it**, for the two reasons above.
- But an unstated estimand is a **reporting** gap, and it is repairable by the authors
  in a sentence. We think a **structural** limitation outranks it.
- **Our nomination: selection into the analytic cohort.** The cohort is reachable only
  through the fasting subsample — of roughly **36,580** adults, about **14,989** have a
  computable FLI, and everything downstream is conditioned on that. Fasting status is not
  a random subsample of the population the conclusion is addressed to.
- That is not fixable by relabelling the estimand. It bounds what any contrast estimated
  here can be said to be about, including the locked one.
- **Why this outranks alignment:** naming the target quantity makes the estimate
  interpretable; it does not make it transportable. The selection is upstream of every
  contrast in the deck.

Speaker notes: A reviewer is entitled to disagree about which threat dominates — that is
reviewing rather than auditing the authors' self-diagnosis. Be explicit that we are not
saying they were wrong to be worried about alignment; we are saying they ranked a
repairable reporting problem above an unrepairable structural one.

---

## Slide 6: Recommendations, in priority order

1. **Demote the Table 2 corroboration** to a consistency observation, and say why no
   interval is available (Slide 3).
2. **Restate or drop the TyG item** on the "what would change our mind" list, since as
   written it cannot settle the locked contrast (Slide 4).
3. **Address selection explicitly** — state the population the locked contrast is about,
   given that entry requires a computable FLI, and say what would be needed to speak
   beyond it (Slide 5).

**An answer to their open question.** Their Slide 8 asks reviewers whether "the estimand is
unstated" is a finding or a refusal to commit to a causal model themselves. Our answer: it
is a finding, but a weaker one than the deck treats it as. Declining to name a target
quantity is a real limitation in the paper. It becomes a *dominant* threat only if naming it
would change what the analysis can support — and here, we think selection would still be
binding afterwards.

Speaker notes: Three actionable items, ordered, none of which requires them to start over.
Closing on their own question is deliberate: they invited the challenge, and a review that
ignores an explicit invitation has not engaged. We expect them to push back on the ranking
in Slide 5, and that is the argument worth having at M3.

---

## Slide 7: Cover note

**Contribution.** AB: ran their pipeline, reproduction log, Slides 1–2. CD: the two
evidence objections, Slides 3–4. EF: the dominant-threat disagreement and the
recommendations, Slides 5–6, deck assembly.

**External feedback.** None received.

**AI Use Statement.** Tool and version: Claude (Opus 5), in a browser. Where we used it:
resolving two package-installation failures on our own machines while setting up to run
Group A's repository, and tightening the wording of Slides 3 and 5 after we had written
them. What we did with the output: we rewrote both slides from the tightened draft and
checked every claim back against Group A's deck and their scripts. **No part of Group A's
deck, repository, output or results was pasted, uploaded, screenshotted or retyped into
any AI tool**; where an error message quoted their code, we described the problem in our
own words instead. The critique, including the ranking on Slide 5, is ours.

Speaker notes: M2 submits slides only, so there is no `COVER-NOTE.md` to file — this
slide is the whole cover note. The two hard limits at M2 are worth stating on the slide
itself rather than assuming the reader takes them on trust.
