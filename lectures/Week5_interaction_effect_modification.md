# Week 5 — Effect modification and interaction: which question, which adjustment set, which scale

Duration: ~2.5 h (Tue 6 Oct, before the Thu 8 Oct lab). Deck:
`lectures/slides/Week5_interaction_slides.qmd`. Its numbers come from
`lectures/analysis/Week5_joint_exposure.R` (written to `Week5_joint_exposure.json`), and from
the P2, P3 and M1 result objects (`examples/_results/`). The code and output on its twelve
**"In R"** slides come from `lectures/analysis/Week5_code_outputs.R`, which runs each snippet
exactly as shown and records what R printed.

> **Timing.** Per-slide markers below sum to **132 min including the break**, against a
> 150-minute cap: 18 minutes of slack. The deck's speaker notes name the plan slide for every
> deck slide and carry the same minutes; Plan Slide 8 spans two deck slides, and the "In R"
> slides are lettered (9b–c, 10a, 12a, 15a, 16a–c, 20a, 22a, 23a). **If you retime a
> slide, retime it in the deck's notes too.** See *If you are running behind* at the foot of
> this file.

> **Built on Week 4, on purpose.** Week 4 taught confounding with **obesity alone** and
> handed this lecture the paper's real exposure: *"Next: Week 5 — the paper's four BMI × waist
> groups"*. Week 5 keeps Week 4's rows (**5,911**), its **pre-exposure adjustment set** (age,
> sex, race/ethnicity, smoking, sedentary time), its DAG conventions, its notation (A, Y, L,
> U; potential outcomes), its "Read more" lines, and four of its results as callbacks: the
> collapsibility table (read for modification), the g-computation idea (extended to
> standardised survival), the Table 2 DAG (Q1 and Q2 are today's two readings), and the Q2
> estimate for waist fat, **1.24 (0.93–1.67)**, which today splits by obesity.

> **Concrete after the break.** From the scale slides onward every idea is followed by an
> **"In R"** slide: the code that computes it, on our data or the toy tables, with R's real
> output underneath (reprex style, `#>`). Students see where each number comes from before
> they see it summarised. Nothing on those slides is typed: the code runs as shown, and a
> check fails if a slide's block differs from what R printed.

The lecture is one argument. **The paper's four phenotype groups are two exposures crossed,
and the 2 × 2 asks two different questions.** *Effect modification* — does waist fat's effect
on death differ between the obese and the not obese? — needs only waist fat's confounders.
*Interaction* — what do obesity and waist fat do together? — needs the confounders of
**both**, and obesity's include serious illness and earlier disease, which nobody measured.
So in MASLD the first question is answerable only under strong, stated assumptions, and the
second is not answerable even under those. Then the scale: the answer depends on whether you
compare ratios or differences, and the additive scale needs the lowest-risk cell as its
reference — which here is Group I, with **4 deaths**. Counting the cells first is the habit
the lecture exists to build, and the sex example shows what happens when nobody does.

> **Every DAG is drawn.** One new figure, `lectures/img/w5_two_questions.png`, in Week 4's
> visual language (colour = role; dashed outline = not measured; square = conditioned on; grey
> arrow with "?" = the effect we want; dashed red band = an open back-door path). Every
> adjustment-set claim, including each broken assumption on the second Slide 8, is checked
> with dagitty, and the deck prints the DAG as dagitty code in an appendix so students can
> check it themselves. Week 4's `w4_table2_panels_a.png` is reused on Plan Slide 9. The two
> data figures (`w5_four_groups.png`, `w5_em_forest.png`) read every number from the emitted
> JSON rather than having it typed in; the four-group figure draws comparisons as lines
> without arrowheads, so they cannot be read as causes.

> **Row-set discipline.** Every quantitative slide names its rows. Six sets appear:
> - **5,911** — Week 4's rows: the locked domain restricted to people complete on every
>   covariate of the paper's Model 2 and of the pre-exposure set. All of Part 4 (each slide
>   says so in its footer).
> - **6,048** — the locked domain itself. Only the retired crude IV-vs-I table by sex (Plan
>   Slide 22), on the rows P3's code uses. Group I has 375 people there, not 355.
> - **1,296** — P3's rows: Groups III + IV complete on Model 1 (Plan Slide 23, P3's numbers).
> - **1,291** — Groups III + IV within the 5,911 (Plan Slide 23, the pre-exposure row).
> - **5,939** — P2's Model-1 complete cases, for the 1.06 quoted in Plan Slide 18's notes.
> - **6,371** — the full file, only in the provenance note on Plan Slide 22.

> **What this week does NOT do.** Survey weights are Week 6: every number here is
> **unweighted**, and the design-aware sex ratio (M1) is quoted only as the hand-off.
> Propensity-score methods for subgroup effects (Karim, ch. 8, §8.6) come after the
> propensity-score weeks. Missing data is Week 7.

## Learning objectives

1. Distinguish **effect modification** (one exposure; its effect varies across levels of M)
   from **interaction** (the joint effect of two exposures), and from confounding and from a
   bare product term.
2. Choose the **adjustment set** each question needs, using a DAG: A's confounders for
   effect modification; both exposures' confounders for interaction — and state the
   assumptions the DAG makes.
3. Explain why effect modification is **scale-dependent**, compute RERI, AP and S, and know
   that all three are additive-scale measures.
4. **Count** people and outcomes per cell before trusting an interaction measure, and choose
   the lowest-risk cell as the reference.
5. Use the right **time-to-event** tools: a Cox product term (multiplicative) and
   standardised risks at a fixed time (additive).
6. Report a subgroup finding as evidence, not mechanism.
7. Write the R for each of these: stratum-specific HRs from a product term, the
   likelihood-ratio test, standardised risks, and RERI / AP / S / IC.

## Continuity

- **Last week (Week 4 / L3).** Confounding, with obesity as the only exposure. Crude HR 0.67
  moved to 0.95 with the pre-exposure set; the DAG decided what to adjust; collapsibility
  showed ORs and HRs move without confounding; Table 2 showed one model answers one question,
  and gave waist fat's own answer as 1.24 (0.93–1.67).
- **Today.** The paper's real exposure, obesity × waist fat. Same rows, same adjustment set,
  same figure style.
- **Thursday (L4).** EpiMethods `confoundingE2`: the **RHC** data again, a **binary**
  outcome, DNR as the modifier, logistic regression, RERI/AP/S. See *Thursday* below.
- **P3.** One pre-specified modifier on the student's own paper (optional, ungraded; enters
  M1).

---

## Opening · 9 minutes

## Slide 1 — Does waist fat matter more for some people? (4 min)

- The four groups as a 2 × 2, with people and deaths: **I 355 / 4 · II 4,265 / 362 ·
  III 732 / 67 · IV 559 / 101** (5,911 rows).
- Week 4 asked about obesity alone. Today: does waist fat's effect depend on obesity, and
  what do the two do together?
- Point at Group I's **4 deaths** now. The lecture comes back to it four times.

## Slide 2 — Our running example (3 min)

- A = high waist fat (WHtR ≥ 0.6); M = obesity (BMI ≥ 30, ≥ 25 for Asian participants);
  Y = death; L = Week 4's pre-exposure set.
- **Why not Model 1?** Week 4 showed some of its conditions are plausibly mediators, and
  reported the pre-exposure set as "the closest measured set to the DAG's".
- **Income** was in Week 4's L but is missing for 516 of the 5,911; it returns as an
  assumption on Slide 8.
- The paper compares every group with Group I and never asks either question.

## Slide 3 — Objectives (2 min)

## Part 1 · Two questions that sound alike · 14 minutes

## Slide 4 — Effect modification: one exposure (5 min)

- Definitions on both scales, with potential outcomes conditioned on M (Karim ch. 8, §8.4):
  RD~m~ = P[Y(1) = 1 | M = m] − P[Y(0) = 1 | M = m]; RR~m~ likewise.
- **M's own effect needs no causal story.** The exposure needs exchangeability, positivity
  and consistency (Week 4); the modifier does not (Karim §8.4.1). Sex can modify an effect;
  nobody can set it. **But M must be something A cannot change** (Slide 9a shows why).

## Slide 5 — Interaction: two exposures (5 min)

- Four potential outcomes Y(a, m). Synergy / antagonism. The deck keeps the letter M for the
  second variable throughout, as Karim does; EpiMethods writes B.
- Interaction is **symmetric**; effect modification is not — "waist fat by obesity" and
  "obesity by waist fat" are different questions (Slide 9).

## Slide 6 — Confounding, modification, interaction (4 min)

- Remove confounding; report modification; report all four combinations for interaction. A
  product term is a model device serving both — if the model has that question's adjustment
  set.
- The same variable can be both a confounder and a modifier: obesity confounds waist fat →
  death (Week 4, Table 2 Q2) and is today's modifier.

## Part 2 · What to adjust for · 26 minutes

## Slide 7 — Each question has its own adjustment set (4 min)

- EM of A by M: confounders of A → Y. Interaction of A and M: confounders of A → Y **and**
  M → Y (EpiMethods *Concepts*, "Implications for Confounding Control").
- **The EpiMethods effect-modification slides** run the classic example. Income as a
  modifier of smoking → hypertension: {age, gender}. Income as a second exposure: add diet or
  education — and the slides ask "but how?", because income has no arrow into hypertension
  (a real exposure, or a proxy for education?). Their "true" interaction is education as the
  second exposure, needing only {age, gender}. Today asks the same of obesity: a second
  exposure, or only a sorter?

## Slide 8 — In MASLD, one question needs less (10 min) · two deck slides · **do not drop**

![](img/w5_two_questions.png){width=100%}

**First deck slide — the figure.**

- **Panel A — effect modification.** Waist fat ← obese ← U → death passes through obesity;
  stratifying on obesity blocks it. **{L, obesity}** is the one minimal set **on this DAG**.
- **Panel B — interaction.** Obesity is now an exposure; obese ← U → death is open. No
  measured set closes it. With U measured, **{L, U}** would do.
- **U merges Week 4's two latent nodes** — serious illness, and disease that came before
  obesity. Week 4's appendix needed {Before, Ill, L} for obesity's effect for the same reason.

**Second deck slide — "What Panel A's ✓ assumes".** Each is dagitty-checked: break it and
Panel A's set disappears.

1. **Obesity comes before waist fat** (Week 4's Table 2 DAG; Week 4 flagged the arrow:
   "the DAG, not the data, decides"). If waist fat drives BMI, obesity is caused by the
   exposure and cannot be the modifier.
2. **U reaches waist fat only by moving people across BMI 30.** A strong assumption: illness
   can shrink the waist without changing the obesity category. Sensitivity: adding BMI
   itself to the model gives **2.80** and **1.07** (ratio **2.62**), against 2.99 and 1.09.
3. **Nothing unmeasured causes both obesity and waist fat** (a fat-distribution gene, say).
   Obesity is a collider of U and such a cause, so stratifying on it would open
   waist ← G → obese ← U → death.
4. **L is complete** — Week 4's L also had income, missing for 516 of the 5,911.
- **And under all of it, the FLI ≥ 60 selection.** FLI is computed from BMI **and waist**,
  so the cohort is selected on a child of both exposures. That biases even Panel A; Week 4
  named the direction for IV vs III — downward (the not obese with lower waist fat reach
  FLI ≥ 60 with higher triglycerides and GGT).
- **The honest summary:** modification is answerable only under these assumptions;
  interaction is not answerable even under them. In this DAG, the interaction question needs
  everything the modification question needs, plus obesity's confounders.

## Slide 9 — Which way round? Choosing the modifier (3 min)

- Reuses Week 4's Table 2 panels (Q1 obesity, Q2 waist fat). Waist fat by obesity: obesity
  is a confounder → stratifying helps. Obesity by waist fat: waist fat is a mediator →
  stratifying removes part of obesity's effect. The Week 4 figure was drawn without U; with
  it (Slide 8) obesity's own effect has no valid set either, so this reading fails twice.
- Which variable comes first decides which reading works. The next slide makes that a rule.

## Slide 9a — The exposure must not change the modifier (5 min)

![](img/w5_modifier_timing.png){width=100%}

- **The rule, stated so students can apply it:** *the modifier must be something the
  exposure cannot change.* "Waist fat's effect among people with M = m" asks what changing
  waist fat would do **to the people in that group**; that only makes sense if changing waist
  fat cannot move people into or out of the group.
- **The safe check is time:** sex, age, genes, a condition that began **before** the
  exposure. *Recorded at the same visit* is not enough — ask whether the exposure could have
  caused it. Diabetes at the NHANES exam fails; obesity passes only if it came before the
  waist fat. (Timing is the check, not the rule: something that arises later but cannot be
  affected by the exposure, such as calendar time, is also fine.)
- **Panel A (fine): sex.** Waist fat cannot change anyone's sex, so each stratum holds the
  same people whatever their waist size. The modifier may also cause the exposure or be a
  confounder; obesity is allowed, but only under the arrow obese → waist fat.
- **Panel B (not fine): diabetes,** plausibly caused by waist fat. Stratifying on it does two
  things at once (both dagitty-checked):
  1. it **blocks part of the effect** — the route waist fat → diabetes → death;
  2. it **compares unlike people** — among people with diabetes, those with lower waist fat
     got it some other way (genes, illness) that also raises the risk of death:
     waist fat → diabetes ← other causes → death is opened. That is collider bias, Week 4's
     FLI lesson in subgroup form.
- **If you care about a downstream variable,** the question is **mediation**: the effect
  with diabetes held fixed (a controlled direct effect, which needs diabetes' own confounders
  measured), or the effect among people whose diabetes would not change with waist fat (a
  principal stratum — not a subgroup you can see in the data).
- The "obesity paradox" has panel B's shape in heart disease (Banack & Kaufman, *Prev Med*
  2014) and in diabetes (Lajous et al., *Epidemiology* 2014); how much of it collider bias
  explains is debated. Timing unknown (Thursday's DNR order and catheterisation, both day 1)?
  State the assumption.

## Slides 9b–9c — In R: could waist fat cause the modifier? · what splitting by diabetes does (2 + 2 min)

- 9b: the diabetes × waist-fat table and its column percentages (13% vs 28%).

- 9c: one Cox model per diabetes stratum (Karim ch. 8, §8.4.3.2), adjusted for obesity and L.
  High vs lower waist fat: **1.23 (0.85–1.78)** without diabetes, **0.93 (0.56–1.54)** with it
  — a gap well within noise. Diabetes is twice as common with high waist fat (28% vs 13%).
- **Neither** number is waist fat's effect in a fixed group: waist fat moves people into one
  stratum and out of the other, so both strata cut the diabetes route and may compare unlike
  people. 1.23 being close to Week 4's 1.24 does not rescue it.
- The slide's footer carries the variable key and the script path; the "In R" slides are one
  R session, run in order.

## Part 3 · Which scale? · 19 minutes

## Slide 10 — Last week's table, read for modification (3 min)

- Week 4's collapsibility toy: OR 4.00 in both age groups, RD 0.30 in both, RR 1.60 vs 2.50.
  Age modifies the RR and neither the OR nor the RD. Hence **effect-measure modification**.
- Week 4's notes promised this callback.

## Slide 10a — In R: the same table, three scales (2 min)

- The toy table as a data frame; one line each for RD, RR and OR. The RR differs by age
  (1.6 vs 2.5), the OR (4) and the RD (0.3) do not.

## Slide 11 — Two scales, two questions (6 min)

- **Every term is defined on the slide:** R~am~ (risk with A = a, M = m), RR~am~ = R~am~ ÷
  R~00~, IC (interaction contrast), RERI (relative excess risk due to interaction), AP
  (attributable proportion), S (synergy index).
- Multiplicative: ratio of HRs = exp(product-term coefficient); 1 = none.
- Additive: RD~1~ − RD~0~; IC = R~11~ − R~10~ − R~01~ + R~00~; RERI = RR~11~ − RR~10~ − RR~01~ + 1
  (0 = none); AP = RERI / RR~11~ (0 = none); S = (RR~11~ − 1) / [(RR~10~ − 1) + (RR~01~ − 1)]
  (1 = none). **All three are additive-scale measures, and RERI and AP can be negative with no
  lower bound.**
- RERI is defined relative to the doubly unexposed cell, so it needs that cell to be the
  **lowest-risk** one; recode a protective exposure first (Knol et al. 2011). Thursday's lab
  does that recoding.
- **Pre-empt the lab text.** `confoundingE2` describes S as "greater than expected based on
  multiplicative effects" and "SI = 1: no multiplicative interaction". S is an additive
  measure. Say so here so the lab does not undo it.

## Slide 12 — Same data, two answers (3 min)

- Made-up 2 × 2: 5%, 10%, 15%, 30%. RR 2, 3, 6 = 2 × 3 → no multiplicative interaction;
  RERI = 2, IC = +10 points → positive additive interaction.
- When both exposures raise risk, no multiplicative interaction implies positive additive
  interaction: RERI = (RR~10~ − 1)(RR~01~ − 1) > 0. Report both scales, and say which scale
  each verdict refers to.

## Slide 12a — In R: RERI, AP, S and IC from four risks (3 min)

- The same four risks in R: ratio 1 (no multiplicative interaction); RERI 2, AP 0.33,
  S 1.67, IC +0.10 (positive additive interaction). Part 4 runs exactly these formulas on
  hazard ratios and standardised risks.

## Slide 13 — What to report (2 min)

- Knol & VanderWeele (2012), as the EpiMethods reporting table lays it out: cell counts with
  outcomes; every combination vs one reference; A within M (EM: this subset); M within A
  (interaction only); both scales with CIs; the adjustment set.

## Slide 14 — BREAK (10 min)

## Part 4 · The four groups, analysed · 33 minutes

## Slide 15 — Count first (3 min)

- The 2 × 2 again, as counts. Every comparison with Group I divides by **4 deaths**, and
  Group I is the **lowest-risk** cell, so it is the reference RERI needs.
- **Week 4's positivity check, for the new exposure.** Of 2,432 obese women, only **57** have
  lower waist fat; among the obese, the chance of high waist fat given L runs from
  27%–99.7% (3%–95% among the not obese). For obese women, the obese-stratum risks lean on
  the model more than on data.

## Slide 15a — In R: count first (2 min)

- `table(group, died)` and the obese-women count: two lines before any model.

## Slide 16 — One model, two ways to write it (4 min) · now with its R output

- `group + L` and `obese * central + L` are the same fit: the slide runs both and prints
  `all.equal(...)` = `TRUE`, then the three coefficients: `obese` 0.34 (obesity's HR among
  those with lower waist fat, = 1 ÷ 2.95), `central` 1.09, `obese:central` 2.74. EpiMethods `confounding9` shows the same equivalence on NHANES (obesity ×
  race/ethnicity, hypertension).
- In the product form, `central` is waist fat's effect among the not obese **only**. Reading
  it as "the effect of waist fat" is the Table 2 fallacy for a modifier's coefficient
  (Westreich & Greenland 2013).
- `interactionR`'s effect-modification table treats the **first** exposure named as the
  modifier — check which way round it prints (Thursday).

## Slide 16a — In R: which hazard ratio is which (3 min)

- Add coefficients for each stratum's HR (1.09; 2.99). For a CI, **flip the coding** so the
  other stratum is the reference (Karim ch. 8, §8.4.3.1): `central` in the flipped model is
  waist fat among the obese, 2.99 (1.11–8.09).

## Slide 16b — In R: does the product term matter? (2 min)

- `fit_main` (no product term) is Week 4's Q2 model: waist fat 1.24. `anova(fit_main,
  fit_prod)`: χ² 4.75, likelihood-ratio p 0.029.

## Slide 16c — In R: standardised six-year risks (3 min)

- `risk6()` sets everyone in a stratum to a group, predicts survival at 6 years, averages:
  obese 2.3% (I) and 6.4% (II); not obese 9.1% (III) and 9.8% (IV). Risk differences 4.1 and
  0.7 points; difference 3.4. This is Week 4's g-computation with `survfit()` in place of
  `predict()`.

## Slide 17 — Effect modification: waist fat, by obesity (4 min) · the summary of 16a–16c

![](img/w5_em_forest.png){width=100%}

- **The Week 4 link.** Week 4's Q2 model, waist fat adjusted for obesity and L with **no**
  product term, gave **1.24 (0.93–1.67)**: one HR for everyone. Let it differ by obesity:
- **Multiplicative.** **2.99 (1.11–8.09)** among the obese (II vs I), **1.09 (0.79–1.50)**
  among the not obese (IV vs III). Ratio, obese ÷ not obese, **2.74 (0.97–7.71)**:
  likelihood-ratio p = 0.03, Wald p = 0.06; profile-likelihood interval 1.10–9.18.
- **Additive.** Standardised six-year risks *within each stratum* (everyone in the stratum set
  to lower vs high waist fat): obese 2.3% → 6.4%; not obese 9.1% → 9.8%. Difference, obese −
  not obese, **+3.4 (−0.1 to +6.6)** points.
- **Verdict.** Both scales point the same way. With 4 deaths in the reference cell the
  likelihood-ratio test is the better guide than the Wald test, and it says p = 0.03; but the
  honest reading is "**borderline** — possibly larger among the obese, resting on four
  deaths". Do not let either threshold decide.
- Bootstrap: 500 percentile resamples; **10** drew none of Group I's deaths. They are kept.

## Slide 18 — The paper's IV vs I, taken apart (4 min)

![](img/w5_four_groups.png){width=100%}

- IV vs I changes **both** exposures. It splits two ways: **2.95 × 1.09** via Group III
  (not obese, then waist fat), or **2.99 × 1.08** via Group II (waist fat, then not obese).
  The product identity holds both ways; **the attribution does not** — because the two
  exposures interact. That is today's topic in one picture.
- Either way, the big step is the one that **leaves Group I** and its 4 deaths. The
  one-exposure-at-a-time contrast is the locked **IV vs III: 1.09**, and that is the reason
  the course locked it.
- **3.22 is our estimate of the paper's comparison**, adjusted for L. The paper reports 2.9
  (its Model 2, aHR 2.9). With the paper's Model 1 instead of L, P2's locked estimate is
  **1.06 (0.77–1.45)** on P2's 5,939 rows; the story is the same.

## Slides 19–20 — Interaction: four cells, one reference (5 min) · one deck slide

- Knol–VanderWeele table, every cell vs Group I: II **2.99 (1.11–8.09)**,
  III **2.95 (1.07–8.13)**, IV **3.22 (1.17–8.87)**; within-row and within-column simple
  effects, including IV vs II, **1.08 (0.86–1.35)**. With
  Group I as reference the two "exposures" are not being obese (A) and high waist fat (M):
  RR~10~ = III, RR~01~ = II, RR~11~ = IV — on the slide.
- Multiplicative: HR~IV~ / (HR~II~ × HR~III~) = **0.37 (0.13–1.03)** — the same product term
  as the forest plot's 2.74, coded the other way; the slide says so.
- Additive: RERI **−1.72 (−4.57 to 1.13)**, AP −0.53, S 0.56. Standardised six-year risks
  over everyone: **2.5%, 7.0%, 6.9%, 7.5%** → IC **−3.9 (−6.7 to −0.5)** points; the
  risk-based RERI (IC ÷ R~00~) is −1.56.
- **Verdict.** Point estimates less than additive — the same borderline evidence as before,
  coded the other way. Every comparison with Group I leans on its 4 deaths (1.09 and 1.08 do
  not). And it **cannot be read as causal**: U, obesity's confounder, was never measured
  (Panel B). The RERI interval includes 0 and the IC interval does not; different measures;
  no threshold picks between them.

## Slide 20a — In R: RERI, AP, S and IC for the four groups (3 min)

- The toy's formulas on `exp(coef(fit_joint))` (all vs Group I): RERI −1.72, AP −0.53,
  S 0.56; and `risk6()` over all 5,911 people set to each group: 2.5, 7.0, 6.9, 7.5% →
  IC −3.9 points. The slide reads the risks in pairs: waist fat adds 4.5 points if everyone
  were obese and 0.6 if no one were; 0.6 − 4.5 = −3.9.

## Part 5 · Time-to-event tools, and a subgroup claim · 17 minutes

## Slide 21 — The right tools for a time-to-event outcome (3 min)

- One table, two columns: **effect modification** (2.74; +3.4 points) and **interaction**
  (0.37; IC −3.9 points; RERI −1.72, risk-based −1.56). Each question keeps its own coding.
- Multiplicative: Cox product term. Additive: standardised risks at a fixed time (Week 4's
  g-computation with a survival curve; within strata for modification, over everyone for
  interaction). Shortcut: RERI from HRs, close to the risk-based RERI when deaths are
  uncommon over follow-up.
- **Not** "ever died" + logistic: that discards follow-up and censoring.
- A binary outcome with fixed follow-up (Thursday) is different: logistic is right. But ORs
  approximate RRs only when the outcome is rare — L4's death outcome is about 40% — so an
  RERI from ORs there is not the RERI from risks.

## Slide 22 — A dramatic subgroup claim (4 min)

- Crude IV vs I within each sex, 6,048 rows (P3's code; Group I has 375 people there): men
  **36.14 (8.86–147.48)**, women **4.11 (0.99–17.12)**. Group I: **2 / 317** men (0.6%) and
  **2 / 58** women (3.4%) died.
- Crude ratio, women vs men: **0.11 (0.02–0.85)** — "significant", for a contrast that
  changes both exposures, in a crude model, divided by four deaths.
- Say what each number rests on, not why it is large. No mechanism.
- **Provenance note.** The P3 exemplar's prose table once printed 28.2 / 4.08 — the same model
  on the full file (6,371) — above code that fits the 6,048 and prints 36.14 / 4.11. It now
  prints the code's numbers. The old Week 5 deck's "men ≈ 28" came from that mismatch.

## Slide 22a — In R: count Group I by sex first (2 min)

- `with(subset(dom, group == "I"), table(female, died = dead))`: 2 deaths in each sex.

## Slide 23 — The same question, asked properly (4 min)

- Locked contrast IV vs III, sex as modifier, one test of the product term (likelihood-ratio
  p throughout): crude **0.62 (0.26–1.43)**, p 0.278 (P3, 1,296 rows);
  Model 1 **1.00 (0.42–2.35)**, p 0.993 (P3); pre-exposure set **1.13 (0.48–2.66)**, p 0.78
  (1,291 rows).
- P3's six-year RDs, in points with their intervals: +0.8 (−3.3 to +4.2) in men, +0.5
  (−7.3 to +7.6) in women — small point estimates, wide intervals.
- The honest statement: no evidence of modification at this precision; the interval is
  compatible with the effect in women being less than half, or more than twice, that in men.
- **Withdrawn, and said once in the notes.** An earlier version of this lecture called the
  crude gap "confounding by baseline risk" and told students to report a common
  multiplicative effect. The data cannot say what produced the gap.

## Slide 23a — In R: one test for sex, on the locked contrast (2 min)

- Restrict to Groups III and IV; `IV * female` with L; ratio 1.13 (0.48–2.66),
  likelihood-ratio p 0.78 (the third row of Slide 23's table).

## Slide 24 — Honest subgroup reporting (2 min)

- Pre-specify one modifier with a reason; say which question (EM or interaction); count every
  cell; both scales with intervals and a named reference; a big crude gap is not evidence of
  modification and a null test is not evidence of none; no mechanism without evidence.
- This is the P3 checklist.

## Close · 4 minutes

## Slide 25 — Key takeaways; next week (4 min)

- Six takeaways (deck). **Next:** Week 6, survey weights; design-aware, P3's Model 1 sex
  ratio (1.00) becomes **2.53 (0.92–6.98)** (M1).
- **What today cannot fix:** unmeasured U; selection on FLI ≥ 60, computed from both of
  today's exposures, which need not bias every stratum equally and so can create or hide a
  difference between strata. M1 asks groups to rank these threats from their own evidence.
- Exit question: *one modifier for your own paper — and why it is fixed before your exposure.*

## Slide 26 — Where to read more; references; dagitty appendix (uncounted)

---

## Thursday — L4 (EpiMethods `confoundingE2`) · for the TA and the instructor, not in the deck

The Week 4 deck carries no lab bridge, and neither does this one. The L4 handout carries the
short version of these notes; they are worth five minutes at the start of Thursday's session.

- **Data.** The RHC data again (Week 4's L3): the 1,439 complete cases, restricted to
  DASI > 20 → **623** patients. Outcome: the binary death variable, **40%** died. Exposure:
  `no_rhc_status`; modifier / second exposure: `no_dnr_status`.
- **The exercise's reference cell.** The exercise text says it changes the reference levels
  "to `No RHC` and `No`"; its code does the reverse. Both indicators are coded 1 for "No", so
  the reference cell (0, 0) is **RHC and a DNR order** — the lowest-risk cell, as Slide 11
  says RERI needs.
- **Count first — that reference cell holds 3 patients.** Only **23** of the 623 have a DNR
  order (20 without RHC, 3 with). Run
  `with(high_dasi_data, table(rhc_status, dnr_status, death_status))`: the RHC + DNR cell has
  3 patients and 1 death. Everything in Problem 2 divides by it:
  - OR for no RHC among DNR patients **29.8 (1.14–781)**;
  - RERI **−28.5 (−125 to 68)**, AP −14.0, S 0.04 (0.002–0.80);
  - product term p = 0.056 (Problem 1's p = 0.048, with RHC's confounders only).
  - The only well-supported stratum estimate is no RHC among patients **without** a DNR
    order: OR **1.21 (0.78–1.86)**, 600 patients.
  This is Slide 15's lesson in the lab's data: Group I has 4 deaths; the lab's reference cell
  has 3 patients.
- **Read the intervals, not interactionR's p column.** interactionR (0.1.7) computes the
  RERI, AP and S p-values one-sided or on the wrong scale: S prints p = 0.98 while its own
  interval (0.002–0.80) excludes 1. The exercise tells students to compare those p-values
  with 0.05. S's interval excludes 1 while RERI's includes 0: different measures on one
  3-patient cell — Slide 19's lesson again.
- **interactionR prints the wrong way round in Problem 1.** With `em = TRUE` it treats the
  **first** name in `exposure_names` as the modifier, so as called it shows DNR's effect by
  RHC — the reverse of Problem 1's question (Slide 9). Read Problem 1 from the Publish rows
  (no RHC vs RHC: **33.0 (1.79–609)** with a DNR order, **1.22 (0.80–1.85)** without), or swap
  the order of `exposure_names`.
- **Statements in the exercise text to correct out loud:**
  1. "SI = 1: no multiplicative interaction" — S is an **additive** measure (Slide 11).
  2. "RERI < 0 … the exposures may be protective when combined" — a negative RERI means
     **less than additive**, not protective.
  3. Interaction as "a departure from multiplicativity" — differs from the *Concepts* page
     and from Tuesday (the joint effect of two exposures, on either scale).
- **Death is common (40%),** so ORs overstate RRs and the OR-based RERI is not the risk-based
  RERI (Slide 21).
- **The 1,439 are complete cases,** which Week 4 showed is selection on early survival (the
  ADL score). It carries into L4 unchanged.
- **DNR as the modifier fails Tuesday's own rule unless it came first.** DNR and RHC are both
  day-1 decisions, and which came first is not recorded. If a DNR order could follow
  catheterisation, DNR is a consequence of the exposure, and stratifying on it opens
  RHC → DNR ← severity → death. Ask the room whether a DNR order could follow catheterisation,
  and read Problem 1 as conditional on the answer. The same doubt complicates the interaction
  reading in Problem 2.
- To reproduce: the numbers above come from running the solution's two `glm()` calls on
  `rhc_data.rds` from `confoundingEx2.zip`, plus `interactionR::interactionR()` and
  `Publish::publish()` as the solution calls them.

---

## If you are running behind

Drop or shrink in this order. The first two cost the least.

1. **The toy "In R" slides (10a, 12a) — 5 → 1 min.** Show the output, skip the code; the
   MASLD "In R" slides carry the same formulas.
   **Slide 12 — same data, two answers (3 → 1 min).** Say the rule (harmful exposures, no
   multiplicative interaction ⇒ positive additive) and move on.
2. **Slides 22–22a — the dramatic subgroup claim (6 → 3 min).** Show the table; say "count
   first".
3. **Slides 16a–16b (5 → 2 min).** Keep the flip trick and the likelihood-ratio p.
4. **Slide 9 — which way round (3 → 1 min).** Go straight to 9a; never drop the rule
   itself.

**Never drop Slides 8 (both deck slides), 9a, 15, 16c, 17 or 18.** 9a is the rule students
apply in P3. The two-question DAG and its
assumptions, the cell counts, the effect-modification result and the IV-vs-I decomposition
are the argument; everything else supports one of the four.

## Reading map — each segment and where students can review it

| Segment | EpiMethods / course page | Key reference |
|---|---|---|
| Definitions (Slides 4–6) | `confounding0` *Concepts*, "Formal Definitions"; effect-modification [video](https://youtu.be/cxfwqBD1M1c) and [slides](https://docs.google.com/presentation/d/1q-RTYkiQV8tCbn71BGL3V11jjlGgq1oBfZwavLuWOks/edit?usp=sharing) | VanderWeele 2009; Bours 2021; Karim ch. 8 §8.2–8.5 |
| Adjustment sets (Slides 7–9) | `confounding0`, "Implications for Confounding Control" | Karim ch. 8, Fig. 8.1 |
| Scale (Slides 10–12) | `confounding0`, "The Role of the Scale"; `confounding5` (Week 4) | VanderWeele & Knol 2014 |
| RERI, AP, S; reference cell (Slides 11, 15, 19–20) | `confounding9`, "Additive interaction measures"; [interaction tutorial](https://ehsanx.github.io/interaction/) | Knol et al. 2011; Hosmer & Lemeshow 1992 |
| Joint variable vs product term (Slide 16) | `confounding9` | Westreich & Greenland 2013 |
| Reporting (Slides 13, 24) | `confounding0`, "Reporting guideline" | Knol & VanderWeele 2012; Karim ch. 8 §8.7 |
| Thursday | `confoundingE2`, `confoundingE2solution` | — |

**Three things to know before assigning the reading.**

- **Karim, ch. 8.** Sections 8.1–8.5 and 8.7 match today; §8.6 (propensity-score methods for
  subgroup effects) belongs after the propensity-score weeks. Three slips in the assigned
  sections: §8.4.3.1 gives the ratio of odds ratios as 1.27 "with a 95% confidence interval
  of 1.04 to 1.27" (Table 8.3: 1.04–1.56); the same paragraph calls OR~M=0~ = 2.93 "the
  low-income group" although §8.3 codes high income as M = 0; and §8.5.1 describes AP as the
  share "attributed to the exposure" rather than to the interaction.
- **The interaction tutorial** states that RERI "ranges from 0 to ∞" and AP "from −1 to 1".
  Both can be negative, and AP can fall below −1 (today's RERI is −1.72; the lab's AP is
  −14.0). Say so if students are pointed at that page.
- **The EpiMethods lab text** — see *Thursday* above.

## Appendix — the two questions as dagitty code

```
dag {
  Waist [exposure]  Death [outcome]  U [latent]
  L -> Obese  L -> Waist  L -> Death
  U -> Obese  U -> Death
  Obese -> Waist  Obese -> Death  Waist -> Death
}
```

With `Waist` as the only exposure dagitty returns {L, Obese}. Add `Obese` as a second
exposure and no set exists; remove the latent tag from `U` and {L, U} appears. Each of the
second Slide 8's assumptions, broken, removes Panel A's set: reverse `Obese -> Waist`; add
`U -> Waist`; add a latent `G -> Obese`, `G -> Waist`; add a latent income node; or add
`FLI [adjusted]  Waist -> FLI  Waist -> TG  TG -> FLI  TG -> Death`.

## References

- Banack HR, Kaufman JS. The obesity paradox: understanding the effect of obesity on mortality among individuals with cardiovascular disease. *Prev Med* 2014;62:96–102.
- Bours MJL. Tutorial: a nontechnical explanation of the counterfactual definition of effect modification and interaction. *J Clin Epidemiol* 2021;134:113–124.
- Hosmer DW, Lemeshow S. Confidence interval estimation of interaction. *Epidemiology* 1992;3:452–456.
- Karim ME. Effect modification in non-randomized studies: methods and applications with propensity scores. Chapter 8 (book chapter).
- Lajous M, Bijon A, Fagherazzi G, et al. Body mass index, diabetes, and mortality in French women: explaining away a "paradox". *Epidemiology* 2014;25:10–14.
- Knol MJ, VanderWeele TJ. Recommendations for presenting analyses of effect modification and interaction. *Int J Epidemiol* 2012;41:514–520.
- Knol MJ, VanderWeele TJ, Groenwold RHH, et al. Estimating measures of interaction on an additive scale for preventive exposures. *Eur J Epidemiol* 2011;26:433–438.
- Kueh MTW, et al. Body weight categories and fat distribution in relation to all-cause mortality among adults with metabolic dysfunction-associated steatotic liver disease. *BMJ Open* 2026;16:e113719.
- VanderWeele TJ. On the distinction between interaction and effect modification. *Epidemiology* 2009;20:863–871.
- VanderWeele TJ, Knol MJ. A tutorial on interaction. *Epidemiol Methods* 2014;3:33–72.
- Westreich D, Greenland S. The Table 2 fallacy: presenting and interpreting confounder and modifier coefficients. *Am J Epidemiol* 2013;177:292–298.
