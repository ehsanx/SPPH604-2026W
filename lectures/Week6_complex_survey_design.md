# Week 6 — Complex survey design: the NHANES workflow, then the MASLD estimates

Duration: ~2.5 h (Tue 13 Oct, before the Thu 15 Oct lab). Deck:
`lectures/slides/Week6_survey_slides.qmd`. Its MASLD numbers come from
`lectures/analysis/Week6_design_aware.R` (written to `Week6_design_aware.json`) and from the
M1 and paper result objects (`examples/_results/`). The code and output on its code slides
come from `lectures/analysis/Week6_code_outputs.R`, which runs each block exactly as shown
and records what R printed. The two pooling examples for cycles outside 2007–2018 (Slides 20
and 22, and appendix A13) cannot run on our data; a check runs them on a small made-up file
and compares the weights they build with the slides' formulas.

> **The design.** Start with how NHANES actually draws its sample: strata first, then PSUs,
> segments, households and people. Then isolate what a weight does in a made-up town of
> 1,000, where the sample's answer and the town's can be checked by hand. Then the NHANES
> rules: which weight, how to pool cycles, design first and `subset()` second. Then MASLD as
> the **audit**: Weeks 4 and 5's own estimates, redone with the design on the same rows.

> **Timing.** The deck carries no timing marks; the minutes below are this plan's. They add
> up to **128 minutes** of content. With the 10-minute break after Slide 35 the total is
> **138 minutes**, leaving 12 minutes of the 150-minute class for questions. *If you are
> running behind* at the foot of this file gives the cut order.

> **Slide numbers.** Slide 1 here is the deck's first content slide, "Why Week 6 matters".
> The deck's own counter also counts the title slide and the five section dividers, so on
> screen it runs ahead of this plan: by 1 for Slides 1–7, 2 for Slides 8–23, 3 for Slides
> 24–35, 4 for Slides 36–50 and 5 for Slides 51–56. The appendix is A1–A18 (screen 63–80).

> **Built on Weeks 4–5.** Same rows (**5,911**), same pre-exposure adjustment set L (age,
> sex, race/ethnicity, smoking, sedentary time), same questions (Week 4's obesity HR and
> Week 5's waist-fat-by-obesity question). Week 4's notes promised that Week 6 would redo its
> analyses with the survey weights; Slides 40–43 do. `Week6_design_aware.R` stops if its
> unweighted numbers differ from the ones Weeks 4 and 5 emitted.

> **Row-set discipline.** Every quantitative slide names its rows.
>
> - **5,911**: Weeks 4–5's rows (the locked domain, complete on L and on the paper's Model 2
>   covariates). Every MASLD estimate: Slides 6, 18, 25, 30, 34–38, 40–45, 50 and the
>   appendix except A7.
> - **57**: Group I's women within the 5,911, the small domain on Slide 31.
> - **1,291**: Groups III + IV within the 5,911. Only the sex test in appendix A7.
> - **5,963**: complete on the nine interaction-model variables in the full fasting MASLD
>   domain; mentioned under Slide 32 for continuity with Week 7, not used in these comparisons.
> - **6,048**: the MASLD adults with a valid fasting weight (Slide 16).
> - **6,371**: our full analytic file. The count on Slide 16 and the paper-reproduction number
>   under Slide 39.
> - **The design frame** is the whole fasting subsample (WTSAF2YR > 0: 17,208 people of all
>   ages, 90 strata, 184 PSUs). It is not a row set we analyse. The design is declared on it,
>   and our rows are reached with `subset()`. The exam-weight sensitivity (Slides 44–45)
>   declares a second frame, the whole exam sample (WTMEC2YR > 0), and reaches the same 5,911
>   rows the same way.
> - **The town** (Slides 8–12, 34 and 47–49) is made up: 1,000 people, 200 sampled.

> **What this week does NOT do.**
>
> - It does not re-run the paper's Model 1. P4's worked example uses Model 1, labelled as the
>   paper's specification.
> - Missing data are Week 7. Slide 32 says only that complete cases are a domain, not a fix.
> - Replication variance (jackknife, BRR) is named in the appendix and not used.

## Learning objectives

By the end, students can work through the deck's five questions in order (Slide 7):

1. **Who?** Name the population an estimate describes: the people sampled, or the population
   the survey represents.
2. **Which weight?** Choose the weight of the smallest NHANES component that measured every
   variable, and pool cycles by what each supplied weight represents: ÷ 6 for 2007–2018, the
   NCHS four-year weight whenever 1999–2000 is included, and time fractions with the 3.2-year
   2017–March 2020 file.
3. **How sampled?** Declare the weight, strata (`SDMVSTRA`) and PSUs (`SDMVPSU`) with
   `nest = TRUE` on the whole file the weight belongs to.
4. **Which subgroup?** Reach the analysis rows with `subset()`, explain a lonely PSU, and report
   the unweighted n beside every weighted estimate.
5. **Which model?** Fit `svymean()`, `svyglm()` or `svycoxph()`, test on the design's degrees of
   freedom, and read a weighted–unweighted gap as a question, not a diagnosis.

They can also say why survey weighting is neither confounding adjustment (Slides 13 and 41)
nor inverse-probability-of-treatment weighting (Slide 27).

## Continuity

- **Last week (Week 5 / L4): effect modification vs interaction.**
  - In MASLD, waist fat's HR looked larger among the obese: ratio **2.74 (0.97–7.71)**,
    likelihood-ratio p **0.03** (Wald p 0.06), resting on Group I's 4 deaths.
  - Sex showed no clear modification of the locked IV-vs-III contrast: **1.13 (0.48–2.66)**
    with L.
- **Today.** Every one of those numbers was unweighted, so it described the sampled people.
  Today asks which population an estimate describes, and redoes Weeks 4 and 5 with the design.
- **Thursday (L5): EpiMethods `surveydataE`.** This is **not MASLD**: Flegal et al. 2016, one
  NHANES cycle, obesity, a weighted Table 1 and survey-weighted logistic regression. See
  *Thursday* below. P4 transfers the workflow to the student's own paper.

## Opening · 18 minutes

## Slide 1 — Why Week 6 matters (3 min)

- NHANES describes the US civilian, noninstitutionalized population, but it is not a simple
  random sample of people.
- **Two questions:** who does each respondent represent, and how should the uncertainty reflect
  the way the sample was drawn?
- **Say this.** Start from the practical goal in the box, not from vocabulary. The lecture
  keeps returning to one workflow (Slide 7).

## Slide 2 — NHANES: stratify first, then sample in stages (3 min)

- **The figure,** `w6_design_stages.png`. Candidate PSUs are grouped into strata *before*
  Stage 1. NHANES then samples PSUs → segments → households → people.
- Stratification is not a sampling stage. It organises the frame so that PSUs are drawn
  separately within each stratum.

## Slide 3 — What are a stratum and a PSU? (3 min)

- **Stratum:** a group of candidate PSUs made similar on geography, metropolitan status and
  population before PSU selection.
- **PSU:** usually a county or a group of adjacent counties, drawn at Stage 1.
- **Segment:** a block or group of blocks inside a PSU.
- **The question box.** A PSU is not "the neighbours". Counties are large; the segments are the
  neighbourhood-like units.

## Slide 4 — What the public NHANES file gives you (2 min)

- The true first-stage geography is confidential. The public file carries masked variance
  units: `SDMVSTRA` (pseudo-stratum) and `SDMVPSU` (pseudo-PSU).
- These are the variables the software uses for design-based variance. Our fasting-subsample
  frame has **90** strata and **184** PSUs (Slide 37 uses both).

## Slide 5 — Why sample this way? (2 min)

- **Efficiency:** interviewers and the mobile examination centre work in geographic clusters.
- **Precision for subgroups:** some groups are sampled at higher rates. Which groups varies by
  cycle.
- The analysis has to remember who was oversampled and who was sampled together.

## Slide 6 — One set of rows, two different mixes (3 min)

- **Our 5,911 rows, unweighted vs weighted** (WTSAF2YR / 6 with strata and PSUs, the design of
  Slides 28–30):

  | | Our 5,911 rows | Weighted |
  |---|---:|---:|
  | Non-Hispanic White | 42.2% | 66.8% |
  | Non-Hispanic Black | 20.2% | 11.3% |
  | Mexican American | 18.6% | 10.4% |
  | Other Hispanic | 11.7% | 6.1% |
  | Other or multiracial | 7.2% | 5.4% |
  | Mean age, years | 51.4 | 49.4 |

- **Say this.** The rows are the same; what changes is how much each row counts. Keep to
  representation: follow-up differs between people, so leave deaths for Part 3.

## Slide 7 — The workflow for today (2 min)

**Who? → Which weight? → How sampled? → Which subgroup? → Which model?** Software comes last:
`svydesign()` cannot choose the population or the weight.

## Part 1 · What a survey weight does · 37 minutes

## Slide 8 — A public-health town: younger and older adults (3 min)

- **The town.** 900 younger adults, 100 sampled (1 in 9, weight **9**); 100 older adults, all
  100 sampled (weight **1**).
- **For this toy,** weight = 1 ÷ probability of selection: each sampled younger adult stands
  for 9 townspeople.
- NHANES has oversampled older adults in some cycles for the same reason: enough of them to
  study.

## Slide 9 — In R: the toy weight (2 min)

The table as a data frame. The weights add back to the town: 100 × 9 + 100 × 1 = 1,000.

## Slide 10 — Hypertension prevalence: sample versus town (4 min)

- **The prevalences.** Younger 15%, older 40%.
  - Sample: (15 + 40) ÷ 2 = **27.5%**.
  - Town: [900 × 0.15 + 100 × 0.40] ÷ 1,000 = **17.5%**.
- **Neither is wrong.** 27.5% correctly describes the 200 people sampled. The town's
  prevalence needs the weights.

## Slide 11 — In R: build the town sample (2 min)

`mean(s$htn)` gives **0.275**, the prevalence among the 200 sampled people.

## Slide 12 — In R: let the weights reconstruct the town (2 min)

- `svymean()` on the weighted design gives **0.175** (SE 0.0327).
- `ids = ~1` because the toy has no clusters, so weighting can be understood on its own. The
  NHANES code from Slide 18 on adds strata and PSUs.

## Slide 13 — Age can matter for two different reasons (2 min)

- **Week 4, confounding:** is the exposure comparison fair? Tool: design and adjustment.
- **Week 6, sampling:** does the sample have the population's age mix? Tool: weights and
  design information.
- The same variable can matter for both reasons. Survey weighting is not confounding
  adjustment.

## Slide 14 — Back to NHANES: the final weight is more than 1 / probability (2 min)

The final weight also carries a non-response adjustment and calibration to population control
totals. NHANES supplies it; the analyst's job is to choose the right one.

## Slide 15 — Which NHANES weight? (3 min)

- **Components:** interview (`WTINT2YR`), examination (`WTMEC2YR`), fasting morning subsample
  (`WTSAF2YR`), and other subsamples with their own weights.
- **The rule:** use the weight of the smallest component that contains every variable in the
  analysis.

## Slide 16 — MASLD: follow the measurement path (4 min) · **do not drop**

- **The figure,** `w6_nested_samples.png` (NHANES 2007–2018, all ages):
  - interviewed **59,842** (WTINT2YR);
  - examined **57,414** (WTMEC2YR);
  - valid fasting weight **17,208** (WTSAF2YR > 0);
  - **6,048** of our **6,371** MASLD adults have a valid fasting weight, and **5,911** of
    those are complete.
- **Why the fasting weight.** The FLI uses fasting triglycerides, so the fasting-subsample weight
  is primary. The paper says "plasma triglycerides"; fasting is our reproduction's choice.
- **The other 323.** **323** analytic adults have a fasting weight of 0, so they are not valid
  fasting-subsample members.
- **Required here, not optional.** The fasting subsample keeps only about **43%** of examined
  adults, but our exposure needs it, so its weight is the primary one. The notes' caveat runs the
  other way: when no variable needs a subsample, using its weight is valid but inefficient.
- Choose by the measurement path, not by which weight gives the nicer answer (Slides 44–45 test
  it).

## Slide 17 — Combining ordinary two-year cycles (3 min)

- Six ordinary two-year cycles, so each two-year weight is divided by 6.
- Dividing every weight by the same constant changes totals. It does not change weighted
  percentages, means, most regression coefficients, or the SEs that do not depend on the
  weights' scale.
- The ÷ 6 rule works here because all six cycles are ordinary two-year cycles.

## Slide 18 — In R: `/ 6` changes totals, not the model coefficient (2 min)

- **The two totals.** Our 5,911 rows stand for **93.0 million** US adults with the ÷ 6 and
  **558.2 million** without it, more than the whole US population.
- **The hidden set-up.** `nhanes` is every 2007–2018 participant; `in_rows` marks our 5,911.
- Keeping WTSAF2YR > 0 is not "deleting rows": the people it drops were never in the fasting
  subsample (no fasting weight) or have a fasting weight of 0, so neither contributes to a
  fasting-weight estimate, and all 90 strata and 184 PSUs remain.
- **The title's second half** (the model coefficient does not change) is Slide 17's claim; the
  code shows only the totals. The companion R script checks it: every coefficient of the same
  interaction model on the same rows agrees within 1e-10 with and without ÷ 6.

## Slide 19 — First special case: analyses that include 1999–2000 (2 min)

- The 1999–2000 weights used a different Census base from 2001–2002 onward, so the two-year
  weights should not be pooled directly.
- For 1999–2002 use the NCHS four-year weight. For 1999–2004 (6 years): 2/3 × the four-year
  weight, 1/3 × the 2003–2004 two-year weight.

## Slide 20 — In R: pooling 1999–2004 (1 min)

`SDDSRVYR` 1 and 2 are 1999–2000 and 2001–2002 (four-year weight × 2/3); 3 is 2003–2004
(two-year weight × 1/3). This code is checked on a made-up file; our data start in 2007.

## Slide 21 — Second special case: 2017–March 2020 is a 3.2-year file (2 min)

2015–2016 (2 years) + 2017–March 2020 (3.2 years) = 5.2 years, so the weights are scaled by
2/5.2 and 3.2/5.2. Each component gets its share of the combined period.

## Slide 22 — COVID-era example in code (1 min)

- `SDDSRVYR` 9 is 2015–2016 (`WTMEC2YR`); 66 is the 2017–March 2020 pre-pandemic file
  (`WTMECPRP`).
- With 2013–2014 added the period is 7.2 years: 2/7.2 for each two-year cycle, 3.2/7.2 for the
  pre-pandemic file.
- Pooling is not only arithmetic: check that the variables are comparable across cycles.

## Slide 23 — Three pooling situations to remember (2 min)

Ordinary two-year cycles from 2001–2002 on: divide by the number of cycles. Anything with
1999–2000: start from the NCHS four-year weight. 2017–March 2020: time fractions. First ask
what period and population each supplied weight already represents.

## Part 2 · Weights, strata, PSUs, and subpopulations · 25 minutes

## Slide 24 — Three design ingredients, three jobs (2 min)

The weight changes the estimate and its uncertainty. PSUs (who was sampled together) and strata
(how the clusters were organised) change the uncertainty only.

## Slide 25 — Why strata and PSUs matter (2 min)

- Clustering usually widens intervals, stratification usually narrows them, and unequal weights
  can widen them. The net effect is empirical.
- **In the MASLD model** (appendix A1, waist fat among the not obese, variance ÷ the ordinary
  model's): strata and PSUs with equal weights **1.05**; weights without strata or PSUs
  **1.56**; the full design **1.37**.

## Slide 26 — Design-based and model-based inference: the useful distinction (2 min)

Ordinary models treat the rows as the analysis data; survey models also use how the rows were
sampled. This is not a claim that every unweighted coefficient is meaningless (Slide 46).

## Slide 27 — Survey weights are not treatment/IP weights (1 min)

Survey weights represent the target population. IP weights balance an exposure comparison.
Frequency weights count observations. Today is about survey weights.

## Slide 28 — Build the survey design before defining the analysis subgroup (2 min)

- The design is declared on the whole fasting subsample (17,208 people of all ages, 90 strata,
  184 PSUs), with the ÷ 6 weight.
- **`nest = TRUE`** because PSU codes repeat across strata: PSU 1 in one stratum is not PSU 1 in
  another.

## Slide 29 — A domain is just the subgroup you want to analyse (1 min)

Adults with MASLD, women, Group I, adults aged 60+, complete cases for a model: NHANES sampled
none of these as such. A domain analysis keeps the original design.

## Slide 30 — Wrong and right ways to analyse a subgroup (3 min) · **do not drop**

- **Left:** delete the other rows, then declare the design. **Right:** declare the design on the
  whole frame, then `subset()`. Both use `nest = TRUE`; only the order differs.
- **On all 5,911 rows the order happens not to matter.** Every one of the 184 PSUs keeps
  someone, so the SE of waist fat's log HR among the not obese is 0.1903 either way. Slide 31 shows when it does
  matter.

## Slide 31 — A small domain shows why the order matters (3 min)

- **Group I's women** are **57** people spread over **44** strata, and **38** of those strata
  keep only one PSU.
- Deleting first leaves those lonely PSUs, and `svymean()` stops with an error.
- `subset()` works: mean age **41.7** (SE 2.39).

## Slide 32 — Complete cases are another domain - but that does not fix missing-data bias (2 min)

- `subset()` gives the right survey variance for the complete-case domain. `update()` adds the
  new indicator to the design that already exists.
- It does not make complete-case analysis unbiased. Survey design and missing data are separate
  problems; Week 7 takes the second.
- **Which rows.** On the full data, the slide's nine variables are complete for **5,963** of the
  6,048 fasting-weighted MASLD adults. This lecture's models use Weeks 4–5's **5,911** rows
  (**534 deaths**), which are also complete on the paper's Model 2 covariates; switching to
  the 5,963 would change the rows as well as the design. Week 7 takes up the difference.

## Slide 33 — A weighted estimate can still be based on little information (2 min)

A subgroup can represent millions and still rest on a few respondents. Show the unweighted n,
the design effect, the design degrees of freedom and the interval width.

## Slide 34 — Design effect and effective sample size (3 min)

- **The town:** Kish's design effect for unequal weights is **1.64**, so the 200 interviews
  carry about the information of **122** equally weighted ones.
- **The design effect is estimate-specific.** For our 5,911 rows Kish's rule of thumb is
  **1.83** (about **3,224** equally weighted rows), but for waist fat's HR among the not
  obese the weights' actual cost is 1.56 (appendix A1).

## Slide 35 — Table 1 for a complex survey (2 min)

- **Unweighted n with weighted %**, our 5,911 rows: Group I **355** (6.1%), Group II
  **4,265** (71.7%), Group III **732** (14.0%), Group IV **559** (8.3%).
- The n says how much data was observed; the % says how common the group is in the population
  represented.

## BREAK (10 min), after Slide 35

## Part 3 · Survey regression in the MASLD example · 40 minutes

## Slide 36 — Fit the model on the design object (2 min)

Week 5's model (obesity × waist fat, adjusted for L) with `svycoxph()` on `des`: the 5,911 rows
reached by `subset()` from the fasting-subsample design. The design object, not the weight
column alone, carries the inference.

## Slide 37 — Tests use the survey design too (3 min)

- `regTermTest(fit_w, ~obese:central, df = degf(des))`: F **0.32** on 1 and **94** df,
  p **0.57**.
- **The design's degrees of freedom:** **184 − 90 = 94**, from the PSUs and strata, not from the
  5,911 rows.
- **Why `df = degf(des)`.** Without it, `regTermTest()` uses the model's residual df: the
  design df + 1 − the number of coefficients, 94 + 1 − 11 = 84 here. With 94 design df the
  choice barely matters; on one cycle it can (Thursday, item 5).

## Slide 38 — Weighting changes the real MASLD population mix only modestly (2 min)

- **Our 5,911 rows, unweighted → weighted:** women 47.2% → 45.5%; Groups I–IV 6.0%, 72.2%,
  12.4%, 9.5% → 6.1%, 71.7%, 14.0%, 8.3%.
- The phenotype mix barely moves, but age and race/ethnicity do (Slide 6).

## Slide 39 — What can we say about the published Cox analysis? (4 min) · **do not drop**

- **What the paper says.** It describes NHANES as a stratified, multistage survey designed for
  national inference.
- **What its methods report.** No weights, strata or PSUs. An ordinary Cox model reproduces its
  unadjusted Group IV vs I HR: **15.14** on our 6,371 rows vs the paper's **15.13** (the
  paper reports about 6,300 rows).
- **The careful statement** is in the box: the analysis should not be labelled design-based
  and nationally representative unless the design was used in an analysis not reported.
- **Fair to the paper.** An unweighted analysis is defensible for prognosis within the sample,
  if it is described that way.

## Slide 40 — Start with one comparison (2 min)

- **Waist fat among the not obese** (Group IV vs III), adjusted for L, 5,911 rows: ordinary Cox
  **1.09 (0.79–1.50)**, design-based **1.43 (0.98–2.07)**.
- A weighted–unweighted gap is a clue, not proof that either model fixed a bias.

## Slide 41 — Adjustment and survey design are different choices (4 min) · **do not drop**

- **Hazard ratio (95% CI), all on 5,911 rows; "adjusted" means set L:**

  | | Unweighted, crude | Unweighted, adjusted | Weighted, crude | Weighted, adjusted |
  |---|---:|---:|---:|---:|
  | Obese vs not | 0.67 (0.56–0.81) | 0.95 (0.78–1.14) | 0.76 (0.59–0.97) | 1.02 (0.79–1.30) |
  | Waist fat, not obese | 2.31 (1.69–3.14) | 1.09 (0.79–1.50) | 3.06 (2.10–4.46) | 1.43 (0.98–2.07) |
  | Waist fat, obese | 7.56 (2.82–20.25) | 2.99 (1.11–8.09) | 5.23 (1.16–23.63) | 2.21 (0.51–9.61) |

- **Reading the table.** Left to right within weighting is adjustment; unweighted to weighted
  within adjustment is the design.
- **Weighting has no fixed direction here:** obesity 0.95 → 1.02, waist fat among the obese
  2.99 → 2.21.
- **Intervals.** They are Wald intervals on z. On t with 94 df they barely change, e.g. 2.21
  becomes 0.50–9.80.

## Slide 42 — Week 5's effect-modification result, redone with the survey design (4 min) · **do not drop**

- **The figure,** `w6_week5_redone.png`, waist fat's HR adjusted for L on the 5,911 rows:
  - not obese **1.09 → 1.43 (0.98–2.07)**;
  - obese **2.99 → 2.21 (0.51–9.61)**;
  - ratio **2.74 → 1.55 (0.34–7.02)**.
- **The tests.** Design-based Wald F p = **0.57** on 1 and 94 df, against Week 5's Wald p 0.06
  (likelihood-ratio 0.03). Compare Wald with Wald.
- **Three things changed:** the estimate, the variance and the test. The wide interval is not
  evidence of no heterogeneity.

## Slide 43 — In R: the Week 5 interaction model, survey-aware (2 min)

`waist_hr(fit, 0)` and `waist_hr(fit, 1)` read waist fat's HR among the not obese and the obese
from one product-term model, ordinary and survey-aware.

## Slide 44 — The correct weight is chosen by the measurement process (3 min)

- **The exam weight as a labelled sensitivity** (WTMEC2YR / 6, same 5,911 rows, adjusted for L):
  - not obese **1.46 (1.00–2.14)**;
  - obese **2.10 (0.47–9.48)**;
  - ratio **1.44 (0.31–6.78)**;
  - the rows stand for **40.6 million** instead of 93.0 million.
- **The two weights move together.** They correlate at **0.99**; the fasting weight is 1.7 to
  3.6 times the exam weight (2.3 on average). Expect the choice to matter more for counts than
  for ratios.
- Each weight targets the US population on its own full sample. On the fasting-subsample rows
  the exam weight ignores the subsample's selection and its non-response adjustment, so the
  total shrinks to 40.6 million while the ratios barely move. It is not the primary weight here.

## Slide 45 — In R: sensitivity to the exam weight (2 min)

The same model on a design built from the exam sample, reached with `subset()`. This is the
sensitivity run P4 asks for.

## Slide 46 — Why can weighted and unweighted regression differ? (2 min)

- **The deck's three reasons:** sampling variation, effect heterogeneity across the sampling
  groups, and sampling variables missing from the outcome model.
- **For hazard and odds ratios, also non-collapsibility:** the averaged ratio can move even when
  the ratio is the same in every group.
- The size or direction of a gap does not say which reason is at work.

## Slide 47 — Why weighting can change an overall RR (4 min) · **do not drop**

- **The town again:** 90% younger / 10% older; the sample is 50:50. Half of each age group has a
  high-sodium diet, so age does not confound this comparison.
  - Same RR (2) in both age groups: **2.00** for sample and town.
  - RR 2 in younger, 3 in older: sample **2.67**, town **2.18**.
- **Why the RR is used here.** It is collapsible and exposure is equally common at each age, so
  the overall RR moves only because the effect differs by age, the sampling variable.

## Slide 48 — In R: build the high-sodium example (1 min)

Half of each age group exposed; incident hypertension 10% → 20% (younger) and 20% → 60% (older).

## Slide 49 — In R: sample RR versus town RR (2 min)

A log-link Poisson `glm()` on the sample gives **2.67**; `svyglm()` with a quasi-Poisson log link
on the weighted design gives **2.18**. The rows did not change; the population averaged over
did.

## Slide 50 — What survey design cannot fix (3 min)

- Confounding; the selection created by defining the MASLD cohort (FLI ≥ 60, Week 4); bias
  from complete-case analysis; a poorly defined exposure or estimand.
- **Sparse cells:** Group I has **4** deaths on these rows, before and after weighting.
- The design answers "for whom?" and "how uncertain?", not "is it causal?".

## Part 4 · Reporting and synthesis · 8 minutes

## Slide 51 — Report the same decisions you made (3 min)

Population, weight (name, reason, pooling), strata and PSUs with the variance method, domain and
complete-case restrictions with the unweighted n, and the survey estimator with its design
degrees of freedom. Unweighted n + weighted % is the usual descriptive pairing.

## Slide 52 — The algorithm to take into your own paper (2 min)

The seven steps and the five checks. This is P4's workflow.

## Slide 53 — Key takeaways (3 min)

- **The slide's six points:** NHANES is not a simple random sample; the weight of the smallest
  component; pooling by what each weight represents; design first, then `subset()`; a
  weighted–unweighted gap is a question, not a diagnosis; the design does not make a comparison
  causal.
- **Say this (not on the slide).** Exit question: which population does your paper's headline
  estimate describe, and which weight would make it describe the one the paper claims? Next:
  missing data (Week 7).

## Slides 54–56 — Sources and references (0 min)

Point students to the EpiMethods pages and the NCHS tutorials on Slide 54; do not present them.

## Appendix (uncounted, A1–A18)

- **A1 · Design effect in the MASLD model.** Variance ÷ the ordinary model's: 1.00, strata and
  PSUs with equal weights 1.05, weights alone 1.56, the full design 1.37.
- **A2 · R code for the variance decomposition.** `robust = TRUE` is essential in the
  weights-only fit.
- **A3–A4 · Variance estimation methods and design-adjusted tests.** Taylor linearization (used
  here) and replication; Rao–Scott and design-based Wald tests.
- **A5–A6 · Survey-weighted survival curves** (`w6_km.png`) and their code. Six-year deaths,
  sample → population, 5,911 rows:
  - Group I 0.7% → 1.2%;
  - Group II 6.5% → 5.1%;
  - Group III 7.6% → 4.5%;
  - Group IV 13.3% → 11.3%.

  Log-rank chi-square 77.9 → 41.6, both p < 0.001. Group IV is worst in both. Group I, with 4 deaths,
  moves the other way; Groups II and III are too close to rank.
- **A7 · Week 5's sex test, design-aware** (1,291 rows, Groups III + IV within the 5,911,
  adjusted for L; **168 deaths**). Women ÷ men: **1.13 (0.48–2.66)** unweighted (likelihood-ratio p 0.78; the
  Wald p is also 0.78) → **2.60 (0.89–7.58)** with the design (Wald p 0.08). M1 found the same direction with the paper's
  Model 1: P3's unweighted **1.00** → M1's design-weighted **2.54 (0.92–7.03)**, on 1,296 rows.
  Pair those two with each other, not with today's set-L numbers.
- **A8–A11 · Regression weights, trimming, SATE vs PATE, sample vs population targets.**
- **A12–A13 · The three-component COVID-era pooling example and its code.**
- **A14–A18 · Reliability standards, a lonely PSU that truly remains, other surveys, software,
  future extensions.**

## Thursday — L5 (EpiMethods `surveydataE`) · for the TA and the instructor, not in the deck

Say this out loud, twice: **L5 is not MASLD.** The numbers below were re-run on the lab's own
files on 2026-10-07. They are not emitted, so re-check them if the exercise changes.

1. **What it is.** Flegal et al. 2016 (*JAMA*), NHANES **2013–14 only**:
   - one cycle, so there is nothing to pool;
   - **5,455** adults;
   - obesity as a binary outcome;
   - an unweighted Table 1, a weighted Table 1, then survey-weighted logistic models among men.

   It rehearses design → `subset()` → `svyglm()`. The exercise fits no unweighted model; to show
   the sample-vs-population contrast, add one `glm()` on the same men.
2. **The weight.** The exercise uses `WTINT2YR`, the only weight in its file, for an
   exam-measured outcome (BMI).
   - **Slide 15's rule says the exam weight,** and Flegal et al. report using "the examination
     sampling weights".
   - **The difference here is tiny.** Weighted obesity is **37.96%** with WTINT2YR and
     **37.92%** with WTMEC2YR, merged from `DEMO_H`.
   - **Use it as a live example of the rule,** not as a reason students' answers are wrong.
   - **Correct Hint 3.** It blames second-decimal differences from the paper on SAS vs R; the
     weight and the interval method are likelier causes.
3. **Intervals.** One OR can come with three intervals:
   - `publish()` uses the normal distribution;
   - `confint()` uses the model's residual df, **5** for the men's model;
   - the design has **15** df for one cycle.
4. **2(c), AIC backward selection.** `step()` on `svyglm()` uses a design-based AIC, so the
   mechanics are survey-correct. Choosing the adjustment set by AIC is what Week 4 warned
   against. Flegal's Table 3 is descriptive, so present this as a prediction-style choice, not
   confounder selection.
5. **2(d), the age × smoking interaction.** The solution's `anova(fit.male, fit2)$p` is a
   Rao–Scott test of a 4-df interaction, and it prints p = **0.40**.
   - **The denominator df of 1 is not a bug.** `svyglm()`'s residual df is the design df + 1 −
     the number of coefficients: 15 + 1 − 15 = 1 for this model (and 15 + 1 − 11 = 5 for the
     men's main model in item 3).
   - **Tuesday's `df = degf(des)` is not a contradiction.** There the design has 94 df and the
     model 11 coefficients, so 84 or 94 barely matters. Here it is the difference between
     p 0.44 and 0.086, so report the df used.
   - **Other choices give other p-values:**
     - `regTermTest(fit2, ~age:smoking)` defaults to the same 1 df: p = **0.44**;
     - forcing `df = 15` gives p = **0.086**, the most liberal choice;
     - a Korn–Graubard adjusted F gives p = **0.16**.
   - **One cycle cannot support this many parameters.** Report the df used and the interaction
     ORs, do not present 0.086 as "the correct answer", and repeat Week 5's line: not
     significant is not "no modification".
   - **Week 5's extractor fails here.** `` anova(...)$`Pr(>|Chi|)` `` returns `NULL` on
     `svyglm()`.
6. **Housekeeping.**
   - The downloaded Rmd carries % grade weights, but L5 is Complete/Incomplete.
   - The L5 page asks for names in an `author:` field. The downloaded Rmd has none; it has a
     **Group name** line near the end. Accept either.
   - `family = binomial` on a survey design prints non-integer warnings; `quasibinomial` gives
     the same estimates silently.

## If you are running behind

Cut in this order. Each idea is said elsewhere.

1. Slide 20, the 1999–2004 code: Slide 19's formulas carry it (1 min). Keep Slide 22: it holds
   the three-component example and the comparability warning.
2. Slide 31, the small-domain demo: one sentence on Slide 30 (3 min).
3. Slides 48–49, the RR code: Slide 47's table carries the point (3 min).
4. Slides 44–45, the exam-weight sensitivity: one sentence, and P4 asks for it (5 min).
5. Slide 26: one sentence on Slide 24 (2 min).

Never cut Slides 16, 30, 39, 41, 42 or 47.

## Reading map — each segment and where students can review it

| Segment | EpiMethods | Reading |
|---|---|---|
| The NHANES design (Slides 1–7, 24–27) | [*Concepts (D)*: The Three Pillars](https://ehsanx.github.io/EpiMethods/surveydata0.html#the-three-pillars-of-complex-sampling) | Lumley 2010, ch. 1–2; NCHS Sample Design tutorial |
| What a weight does (Slides 8–14, 34) | [DEFF](https://ehsanx.github.io/EpiMethods/surveydata0.html#the-design-effect-deff-why-it-still-matters) | Kish 1992 |
| Which weight, pooling (Slides 15–23) | [Selecting the Correct Weight](https://ehsanx.github.io/EpiMethods/surveydata0.html#selecting-the-correct-weight); [Combining Survey Cycles](https://ehsanx.github.io/EpiMethods/surveydata0.html#combining-survey-cycles) | Johnson et al. 2013; NCHS 2021 (Series 2, No. 190) |
| Domains and subsets (Slides 28–33) | [Analyzing Subpopulations](https://ehsanx.github.io/EpiMethods/surveydata0.html#analyzing-subpopulations-the-correct-approach); [Properly subsetting a design object](https://ehsanx.github.io/EpiMethods/surveydata8.html) | Lumley 2010 |
| Models and tests (Slides 36–39) | [Hypothesis Testing in the Design-Based Framework](https://ehsanx.github.io/EpiMethods/surveydata0.html#hypothesis-testing-in-the-design-based-framework) | Binder 1992; Lumley & Scott 2017 |
| Weighted vs unweighted (Slides 40–50) | [A Word of Caution About "Weights"](https://ehsanx.github.io/EpiMethods/surveydata0.html#a-word-of-caution-about-weights) | DuMouchel & Duncan 1983; Solon et al. 2015 |
| Reporting (Slides 35, 51–53) | [PRICSSA](https://ehsanx.github.io/EpiMethods/surveydata0.html#preferred-reporting-items-for-complex-sample-survey-analysis-pricssa); [reliability standards](https://ehsanx.github.io/EpiMethods/surveydata9.html) | Seidenberg et al. 2023 |

## References

- Binder DA. Fitting Cox's proportional hazards models from survey data. *Biometrika* 1992;79:139–147.
- DuMouchel WH, Duncan GJ. Using sample survey weights in multiple regression analyses of stratified samples. *J Am Stat Assoc* 1983;78:535–543.
- Flegal KM, Kruszon-Moran D, Carroll MD, Fryar CD, Ogden CL. Trends in obesity among adults in the United States, 2005 to 2014. *JAMA* 2016;315:2284–2291.
- Heeringa SG, West BT, Berglund PA. *Applied Survey Data Analysis*. Chapman & Hall/CRC, 2017.
- Johnson CL, Paulose-Ram R, Ogden CL, et al. National Health and Nutrition Examination Survey: analytic guidelines, 1999–2010. *Vital Health Stat 2* 2013;(161):1–24.
- Kish L. Weighting for unequal P~i~. *J Off Stat* 1992;8:183–200.
- Korn EL, Graubard BI. *Analysis of Health Surveys*. Wiley, 1999.
- Kueh MTW, et al. Body weight categories and fat distribution in relation to all-cause mortality among adults with MASLD. *BMJ Open* 2026;16:e113719.
- Lumley T. *Complex Surveys: A Guide to Analysis Using R*. Wiley, 2010.
- Lumley T, Scott A. Fitting regression models to survey data. *Stat Sci* 2017;32:265–278.
- National Center for Health Statistics. *NHANES 2017–March 2020 Prepandemic File: Sample Design, Estimation, and Analytic Guidelines*. *Vital Health Stat 2* 2021;(190).
- Seidenberg AB, Moser RP, West BT. Preferred Reporting Items for Complex Sample Survey Analysis (PRICSSA). *J Surv Stat Methodol* 2023;11:743–757.
- Solon G, Haider SJ, Wooldridge JM. What are we weighting for? *J Hum Resour* 2015;50:301–316.
