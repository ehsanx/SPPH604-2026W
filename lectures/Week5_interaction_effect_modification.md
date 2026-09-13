# Week 5 Lecture Plan — Interaction & Effect Modification

Duration: 2.5 h = 150 min (Tue, before the Thu lab). The Slide 1–16 markers below sum to **150** — the whole session, including the 10-minute break at Slide 8 — so this plan runs with **zero float**: the Learning objectives and Continuity blocks above are covered inside Slide 1's opening, and **Slide 15** (preview of the dominant threat, 6 min) is the designated cut if the conceptual run of Slides 3–7 goes long.

## Learning objectives
- Distinguish **confounding**, **effect modification**, and **statistical interaction** — three ideas students routinely collapse into one.
- Explain why effect modification is **scale-dependent** (additive vs multiplicative) and what each scale answers.
- Read the MASLD **sex** example correctly: a dramatic crude stratum difference is not an interaction test, and a null interaction test is not evidence of homogeneity.
- Choose the **right tool for a time-to-event outcome** — a product term in the Cox model plus absolute-risk contrasts — and say why a logistic **RERI** is the wrong instrument here.
- Preview the term's **dominant threat** (FLI circularity) that students will name at M1.

## Continuity
- **Last week (Wk4 / L3):** we built Table 1 and adjusted (P2). Adjustment moved the Group IV HR from ~15 to ~2.9 — adjustment changes *one* effect estimate.
- **Today:** a different question — does the effect *differ across subgroups*? We separate that from confounding and from bare statistical interaction.
- **Sets up Thursday (L4):** product terms and stratum-specific estimates, which each student then runs on their own paper as **P3**.

## Slide 1 — Where we are in the project (6 min)
- Timeline recap: Replicate → Interrogate → Improve → Defend; we are mid-Interrogate.
- P1 eligibility ✓, P2 Table 1 ✓; today feeds **P3 effect modification**.
- One-line reminder of the finding: Group IV (non-obese, high central adiposity) has the worst all-cause survival.
- **MASLD hook:** keep the four phenotypes on screen as our running example — n = 391 / 4,585 / 787 / 608 in our reproduction, against the paper's 386 / 4,541 / 769 / 604.

## Slide 2 — Today's roadmap (4 min)
- Three concepts → two scales → one worked MASLD example → the right time-to-event tool.
- Flag the trap up front: "big crude difference between men and women" is *not* proof of modification.
- **MASLD hook:** promise to return to the men-IV-28 vs women-IV-4 gap after the break — and to say what the data can and cannot tell us about it.

## Slide 3 — Three things people call "interaction" (10 min)
- **Confounding:** a nuisance common cause we adjust *away* to get one honest effect.
- **Effect modification (EMM):** the effect *genuinely differs* across levels of a third variable — a finding, not a nuisance.
- **Statistical interaction:** a *model* term (product coefficient) — a mathematical device that may or may not map to real EMM.
- **MASLD hook:** sex could plausibly be any of the three for the Group IV effect — today we test which.

## Slide 4 — Confounding vs effect modification (10 min)
- Different questions: "is my single estimate biased?" vs "should there even *be* a single estimate?"
- You *remove* confounding; you *report* effect modification (stratum-specific estimates).
- Diagnostic contrast: adjusting for a confounder moves the pooled estimate; a true modifier makes a *pooled* estimate misleading.
- **MASLD hook:** the paper adjusts sex as a confounder — we ask instead whether sex modifies.

## Slide 5 — Statistical interaction = a product term (10 min)
- Model form: outcome ~ exposure + modifier + **exposure×modifier**; the product coefficient *is* the interaction on that model's scale.
- The coefficient's meaning is inherited from the link (log-hazard, log-odds, risk) — so "significant interaction" is always scale-specific.
- A null product term does **not** mean equal absolute effects.
- **MASLD hook:** in Cox, the term is Group×Sex on the **log-hazard (multiplicative)** scale.

## Slide 6 — Additive vs multiplicative scales (12 min)
- Multiplicative: do the *ratios* differ across strata? (ratio of HRs / RRs)
- Additive: do the *risk differences* differ? — the scale that governs how many events you prevent.
- Public-health relevance: intervention planning lives on the **additive** scale.
- **MASLD hook:** men and women can share the same HR yet have very different absolute excess deaths because their **baseline** mortality differs.

## Slide 7 — Same data, two answers (8 min)
- Toy 2×2×2: show a setting with no multiplicative interaction but clear additive interaction (and vice versa).
- Takeaway: "is there effect modification?" is unanswerable without naming the scale.
- Reporting rule: state the scale, give stratum-specific estimates, don't hang everything on one p-value.
- **MASLD hook:** differing baseline mortality is one candidate explanation for the sex "signal" — foreshadow it as a hypothesis we will *not* be able to confirm.

## Slide 8 — BREAK (10 min)
- Stretch; queue the sex example on return.

## Slide 9 — The MASLD sex question (8 min)
- Motivating claim a reader might make: "the Group IV hazard is far worse in men."
- Set up the formal question: does sex modify the Group IV vs reference hazard ratio?
- Note the design: time-to-event, 586 all-cause deaths in our reproduction (the paper reports 585), median follow-up ~6.7 y.
- **MASLD hook:** we will test sex specifically for the **Group IV** contrast, the paper's headline.

## Slide 10 — Crude stratified hazard ratios (12 min)
- Sex-stratified crude Group IV HRs: **men ≈ 28 vs women ≈ 4** — visually dramatic.
- Warn: crude stratum HRs mix in confounding *and* differing baseline hazards and small male cell counts.
- Ask the room: is this modification, confounding, or noise? (hold the vote.)
- **MASLD hook:** these are the exact numbers a careless subgroup analysis would headline.

## Slide 11 — The formal interaction test (14 min)
- Fit Group×Sex product term in the **crude** Cox model, then in the **adjusted** model.
- Match the test to the estimand. A `group*sex` term across four groups is a **multi-df** test of whether *any* contrast varies by sex. For the locked IV-vs-III question the 1-df test gives a ratio of hazard ratios of **1.00 (0.42–2.35), p = 0.99** — no evidence of interaction, but an interval wide enough to be compatible with substantial heterogeneity. A null p-value does not prove homogeneity.
- Lesson: crude stratum contrasts are not an interaction test; the test must live in a model, adjusted.
- **MASLD hook:** on the locked contrast there is no evidence of interaction at the available precision — which is not the same as showing the men-28 / women-4 gap was illusory.

## Slide 12 — A crude stratum difference is not evidence of modification (12 min)
- **Do not explain the crude gap.** A p-value that moves when covariates enter tells you the *estimate* changed; it does not establish **what generated** the crude difference.
- **Withdrawn:** the earlier teaching that this gap was confounding by baseline risk rather than true modification, and with it the instruction to report a common multiplicative effect across sex. Differing baseline mortality is one candidate explanation among several, and this study cannot distinguish them.
- Interpretive discipline: a large stratum-specific estimate ≠ effect modification. Equally, a null test ≠ homogeneity.
- The honest statement is **1.00 (0.42–2.35)**: no evidence of interaction at the available precision, on an interval compatible with the effect in women being less than half that in men, or more than twice it.
- **MASLD hook:** M1 re-runs this test design-aware on the same rows and the picture moves. Flag that now so P3's null is read as provisional, not settled.

## Slide 13 — The right tool for time-to-event (12 min)
- Correct instrument: **product term in the Cox model** for the multiplicative test, plus **absolute-risk / survival contrasts** (predicted risk differences at fixed times) for the additive story.
- **Do not** dichotomize survival and run a logistic **RERI**: it discards follow-up time and censoring and answers the wrong question for this design.
- If additive interaction is the target, get it from model-based **absolute risks**, not a repurposed odds-ratio RERI.
- **MASLD hook:** to serve public-health readers, pair the Group IV HR with predicted 6-year risk differences by sex.

## Slide 14 — Honest subgroup reporting (8 min)
- Power: interaction tests are underpowered; a null is weak evidence of *no* modification (small male IV cell).
- Multiplicity: pre-specify the modifier; don't fish across every covariate.
- Report stratum estimates + interaction p + scale, not a single "significant subgroup."
- **MASLD hook:** the sex example is a cautionary template for what students must resist in P3.

## Slide 15 — Preview: the term's dominant threat (6 min)
- Seed the idea students will formally name at **M1**: **FLI circularity** — the phenotype groups (BMI, waist) and the FLI eligibility filter (BMI, waist) share inputs, so exposure and cohort selection are entangled.
- Why here: effect-modification claims are only as trustworthy as the exposure definition; a circular exposure taints subgroup contrasts too.
- Tease the check: a TyG-based sensitivity exposure that removes BMI and waist from the **steatosis surrogate** (MASLD's cardiometabolic criteria can still involve them). Note that the paper already reports this analysis — the interesting question is what it shows on *our* locked contrast.
- **MASLD hook:** flag it now so P3's subgroup work is read against the looming threat, not in isolation.

## Slide 16 — Bridge to today's lab (L4) and P3 (8 min)
- **In L4 (Thu, EpiMethods OER):** on the fixed NHANES teaching dataset, you will (a) fit a Cox model with an **exposure×modifier product term**, (b) extract **stratum-specific** hazard ratios, (c) read the interaction p-value on the multiplicative scale, and (d) compute **absolute-risk contrasts** at a fixed time — deliberately *not* a logistic RERI.
- **Deliverable P3:** run **one pre-specified effect-modification test on your own paper's exposure** — report the product-term p-value crude vs adjusted, the stratum-specific estimates, the scale, and a one-line verdict stated as evidence, not as a mechanism: whether the data show evidence of modification at the precision you have, and what the interval leaves open.
- **P3 is optional and ungraded** — no separate weight, no separate deadline, and nothing to submit. It applies L4's method to your own paper; keep it in your group GitHub repo, and remember that **M1 is assembled from these five increments** — the only place P3 is assessed.
- **MASLD hook:** your P3 should read like our sex example done honestly — report the interval, and resist headlining a crude gap you cannot account for.
