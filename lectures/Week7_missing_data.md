# Week 7 — Missing data: the ideas on a made-up town, then multiple imputation step by step in MASLD

Duration: ~2.5 h (Tue 20 Oct, before the Thu 22 Oct lab). Deck:
`lectures/slides/Week7_missing_slides.qmd`. Its MASLD numbers come from
`lectures/analysis/Week7_missing_data.R` (written to `Week7_missing_data.json`). The code and
output on its "In R" slides, and three of its pictures (the convergence plot, the
observed-vs-imputed plot and the four-copy table), come from
`lectures/analysis/Week7_code_outputs.R`, which runs each block exactly as shown and records
what R printed. A checker confirms that the deck and this plan quote those outputs verbatim.

> **The design.** Three parts, the same shape as Weeks 5 and 6.
>
> - **Part 1, the ideas on a made-up town** of 1,000 adults whose smoking status is hidden three
>   ways (MCAR, MAR on age, MNAR on smoking). The truth is known, so complete cases can be
>   checked: a share and a risk ratio come out differently. Then single fill-ins on real MASLD
>   data, how `mice()` works, and Rubin's rules.
> - **Part 2, multiple imputation step by step on MASLD**, with the R code students reuse in P5:
>   look (Step 0), set up (Step 1), impute and check (Step 2), analyse (Step 3), pool (Step 4),
>   and add Week 6's survey design (Step 5, in words; its code is Thursday's lab).
> - **Part 3, special cases, limits and reporting**: missing outcomes (MID), MNAR sensitivity
>   analysis, what no method fixes, and a methods paragraph students can adapt.

> **Timing.** The deck carries no timing marks; the minutes below are this plan's. They add
> up to **136 minutes** of content. With the 10-minute break after Slide 23 the total is
> **146 minutes**, leaving 4 minutes of the 150-minute class for questions. *If you are running
> behind*, near the foot of this file, gives a cut order.

> **Slide numbers.** Slide 1 here is the deck's first content slide, "Where Week 6 left us".
> The deck's own counter also counts the title slide and the part dividers, so on screen it
> runs ahead of this plan: by 1 for Slides 1–4, 2 for Slides 5–23, 3 for Slides 24–48 and 4 for
> Slides 49–57. The two reading slides are uncounted. The appendix is A1–A5 (screen 63–67).

> **Built on Weeks 4–6.** Same model (Week 5's waist fat within each obesity stratum, adjusted
> for the pre-exposure set **L**: age, sex, race/ethnicity, smoking, sedentary time), same
> design (Week 6's: WTSAF2YR / 6, strata and PSUs, declared on the whole fasting frame, then
> `subset()`). Week 6 ended with a warning that complete cases are a domain, not a fix for
> missing-data bias; Slide 2 starts there. `Week7_missing_data.R` stops unless Weeks 4–6's
> numbers reproduce on the 5,911 rows.

> **Row-set discipline.** Most quantitative slides name their rows; where one does not, say it.
> Slide 1 matters most: its two HRs are on Weeks 4–6's 5,911 rows, not today's 5,963, and the
> slide does not say so. (Slides 12–13 and 41–42 leave theirs implied: all 6,048.)
>
> - **6,048** — the locked domain (MASLD, a positive fasting weight, linked to the death
>   index); everyone imputation uses.
> - **5,963** — complete on L: what `coxph()` keeps by default (Slide 2), and today's complete
>   cases.
> - **5,911** — Weeks 4–6's rows: complete on L *and* on the paper's Model 2 covariates
>   (cancer history). Its HRs equal the 5,963's to two decimals, so the deck compares
>   imputation with the 5,963.
> - **6,018** — the harmonised-smoking sensitivity (A1).
> - **The funnel** (Slide 26) runs from all 59,842 NHANES 2007–2018 participants to the 5,963
>   complete on L.
> - **The design frame** is the whole fasting subsample (17,208 people aged 12 and over, 2,246 of
>   them aged 12–17). It is not analysed; the design is declared on it and the cohort reached
>   with `subset()` (Step 5).
> - **The town** (Slides 7–10, 22–23, A5) is made up: 1,000 adults. Slides 18 and 21 use other
>   made-up numbers (one person's smoking and sedentary time; three log HRs).
> - **The fill-in and Little's-test demonstrations** (Slides 12–13, 16) use the 6,048 adults' BMI
>   and waist, both complete, with waist values hidden on purpose.

> **What this week does NOT do.**
>
> - It does not re-run the paper's Model 1. P5's worked example uses Model 1, labelled as the
>   paper's specification (Slide 57).
> - It does not impute the 792 adults without an FLI input: that would decide who enters the
>   cohort (Slide 26).
> - It does not impute outcomes (the 2 adults not linked to the death index are outcome
>   ascertainment). MID is explained for Thursday's lab (Slide 49).
> - It does not show Step 5's code. The slide gives the recipe in words; Thursday's lab (L6)
>   runs the same recipe in R.

## Learning objectives

By the end, students can follow the deck's workflow (Slide 4) on their own paper:

1. **Look (Step 0).** Count the missing values, type every loss (P5's funnel), compare complete
   and incomplete rows, and say *why* each value is missing: never asked, asked differently, not
   answered, or never sampled.
2. **Judge the mechanism.** Explain MCAR, MAR and MNAR in plain words; say what data can and
   cannot show about them (Little's test); and say why the same missingness can bias a share
   but not a risk ratio.
3. **Set up (Step 1).** Build an imputation model at least as rich as the analysis model:
   the outcome (for a Cox model, `dead` and the Nelson–Aalen `H`), every analysis variable
   including interactions, auxiliaries, design information; never the ID.
4. **Impute and check (Step 2).** Tell `m` from `maxit`; read a trace plot and an
   observed-vs-imputed plot; say why one completed copy is not enough.
5. **Analyse and pool (Steps 3–4).** Fit the model in every copy with `with()` and pool with
   Rubin's rules (`pool()`), reading `estimate`, `ubar`, `b` and `t`.
6. **Add the design (Step 5).** Say why the design is declared on the whole fasting frame in
   every completed copy before the MASLD domain is analysed and the results combined.
7. **Report** complete cases and imputation side by side, with the assumption, the model, a
   sensitivity analysis and the population each describes.

They can also say why single imputation (mean, regression) is not enough, and why the outcome
belongs in the imputation model.

## Continuity

- **Last week (Week 6 / L5): the survey design.** On the same 5,911 rows, the design moved
  waist fat's HR among the not obese from **1.09 (0.79–1.50)** to **1.43 (0.98–2.07)**. Its
  last warning: complete cases are a domain, not a fix for missing-data bias.
- **Today.** Those rows were themselves a missing-data decision: the 6,048 locked domain minus
  everyone with a blank. Weighting fixed representation; it did not fill in missing values.
- **Thursday (L6): EpiMethods `missingdataE`.** It is **not MASLD**: Williams et al. 2021,
  NHANES 2015–2018, survey-weighted *logistic* regression, with MID in question 3 (see
  *Thursday* below). Its survey step is today's Step 5, in code, with `svyglm()`. P5 transfers
  the workflow to the student's own paper.

## Last year's materials, and where they are now

The instructor's 2020–2025 material (EpiMethods *Concepts (M)*, the *Missing data* slides,
the *FAQ* and the *Reporting* add-on) is kept in substance:

| Last year | This deck |
|---|---|
| Consequences: bias, wrong SE, power | Slide 5 |
| MCAR / MAR / MNAR; "cannot distinguish MAR and MNAR" | Slides 6, 8, 11 |
| MCAR tests and their limits (FAQ; `missingdata6`) | Slides 11–13 (real `mcar_test()` output) |
| Ad hoc methods: mean, missing indicator, LOCF (Vach; Greenland & Finkle) | Slide 14 |
| Single imputation: mean, regression, stochastic, hot deck/PMM; "no variation" | Slides 15–16 (method table; real MASLD data), A4 |
| MI steps s0–s3; the Lumley `mice()`/`with()`/`pool()` picture | Slide 17 and Part 2 |
| How MICE works (starting values, sequential models); `maxit` vs m | Slides 18–20 |
| `mice(maxit = 0)`, predictor matrix, method vector (FAQ Step 0) | Slides 33–34 |
| Choosing m (Rubin; Schafer; White et al.; Austin et al.); `maxit`; trace plots | Slides 35, 37–38 |
| Diagnostics: compare before/after imputation | Slide 39 |
| `pool()` output: estimate, ubar, b, t; within vs between in numbers | Slides 21, 22, 42 |
| Outcome in the imputation model | Slide 32 |
| Auxiliary variables; survey features as predictors | Slide 32 |
| MID for outcome (von Hippel; Sullivan et al.) | Slide 49 |
| MNAR and delta adjustment; best/worst case (FAQ), now "selected extreme scenarios" | Slides 47, 50 |
| Variable selection with MI (majority, stack, Wald) | A2 |
| Non-normal data, PMM, pooling ratios on the log scale | A3, A4 |
| Survey data: MI steps extend naturally (Lumley ch. 9) | Slide 44 |
| Reporting a MICE analysis (rates, reasons, assumption, m, software, model, pooling, discrepancies) | Slides 52–54 |

New this year: apart from Part 1's made-up town and the made-up numbers on Slides 18 and 21,
everything runs on the MASLD paper, with the course's typed funnel and the
"never asked / asked differently / not answered / never sampled" distinction, which the
MASLD data force on us.

## Opening · 11 minutes

## Slide 1 — Where Week 6 left us (2 min)

Waist fat's HR among the not obese (Group IV vs III), adjusted for L: the ordinary Cox model
of Weeks 4–5, **1.09 (0.79–1.50)**; Week 6's design-based Cox model, **1.43 (0.98–2.07)**. Both
are on Weeks 4–6's 5,911 rows.

## Slide 2 — R drops incomplete rows without asking (3 min)

- **The code:** Week 5's model fitted on all 6,048 rows. R uses **5,963** rows and 534 deaths,
  and drops **85**, without being asked.
- **The box:** `coxph()`, `glm()` and `svycoxph()` keep only complete cases by default. That is
  a missing-data decision made by the software.
- **Week 6's warning** on screen: complete cases are another domain, but that does not fix
  missing-data bias.
- **Say this.** Weeks 4–6 also required cancer history, which is not in this model, so 52 more
  went: 6,048 − 85 − 52 = 5,911. From here on, today's complete cases are the 5,963.

## Slide 3 — This week (week 7) (3 min)

- **Kept vs left out** on L: complete 5,963, incomplete 85. Mean age **51.1** vs **32.0**;
  died **9.0% (534)** vs **3.5% (3)**.
- **Two questions** for the day: did leaving them out change **who** the estimates describe,
  and did it **bias** Weeks 4–6's hazard ratios? The answers turn out to be different
  (Slide 48).

## Slide 4 — The workflow for today (3 min)

- **One line** (the deck's): 0 Look → 1 Set up → 2 Impute and check → 3 Analyse → 4 Pool →
  5 Design → Report both.
- **The six steps** in a table, in words only; each R function appears on the slide that uses
  it. Part 2 walks through them in this order.
- **Box:** software comes last; `mice()` cannot say why a value is missing, or whether imputing
  it is worth doing.

## Part 1 · The ideas, in a made-up town · 53 minutes

## Slide 5 — Why missing data matter (2 min)

Bias, wrong precision, lost power. How much is missing mainly affects precision; why it is
missing decides bias. A small amount can still bias an estimate.

## Slide 6 — Three reasons a value can be missing (3 min)

- **MCAR**, **MAR**, **MNAR** (Rubin 1976), each in plain words with a smoking example.
- **The grey box:** "missing at random" means random *once we account for what was observed*.
  Under MAR the observed data contain what is needed to correct the problem; under MNAR they do
  not.

## Slide 7 — A town of 1,000, and its smokers (3 min)

- **Young 600:** 120 smokers, of whom 12 die (10%); 480 non-smokers, of whom 24 die (5%).
- **Old 400:** 200 smokers, of whom 80 die (40%); 200 non-smokers, of whom 40 die (20%).
- **The truth:** **32%** smoke, and the RR is **2** in each age group. Age is a confounder: the
  old smoke more and die more. A new town, not Week 6's.
- **Ask** which question the class expects to be easier from incomplete data, the share or the
  RR. Most will say the share.

## Slide 8 — Ways smoking goes missing (3 min)

- **The figure** is `w7_mechanisms1.png`: three panels, the same population and the same
  arrows among age, smoking and death; only the arrow into "smoking hidden?" changes. MCAR: none
  (chance). MAR: from age. MNAR: from smoking itself.
- **For each scenario:** can complete cases estimate the share who smoke (*p*) and the risk
  ratio (*RR*)? Slide 9 answers *p* for all three; Slide 10 answers the *RR* for MNAR only. If
  asked about the others: under MCAR and MAR on age the complete-case RR stays 2.00 in each age
  group, because neither depends on death given age and smoking.

## Slide 9 — Complete cases: estimating smoking prevalence (4 min)

- **The table:** smokers remaining, people remaining, estimated prevalence. Truth 320 / 1,000 =
  32%; MCAR (half of everyone) 160 / 500 = 32%, right; MAR (half of older adults) 220 / 800 =
  27.5%, wrong; MNAR (half of smokers) 160 / 840 = 19%, wrong.
- **Why MAR is wrong here:** older adults smoke more (50% vs 20%). All 600 young remain with
  their 120 smokers; half the 400 old remain with 100 smokers: (120 + 100) / (600 + 200) =
  220 / 800 = 27.5%.
- **The box:** the amount missing does not decide bias. MCAR hid 500 people and was right;
  MNAR hid 160 and was wrong.

## Slide 10 — Same missing data, different conclusions (4 min)

- **MNAR, half the smokers hidden, regardless of death.** The share: 320 / 1,000 = 32% becomes
  160 / 840 = 19%, biased. The RR among the old: (80 / 200) / (40 / 200) = 2.0 stays
  (40 / 100) / (40 / 200) = 2.0, unbiased.
- **Why:** equal shares of the smokers who died and who survived were hidden, so the risk among
  the remaining smokers is unchanged.
- **The rule behind it** (for the instructor): for an adjusted RR or HR, complete cases are
  unbiased when missingness does not depend on the outcome given every variable in the model,
  including the incomplete one — here even under MNAR (White & Carlin 2010; Hughes et al.
  2019). A sufficient condition, if the model is right. Bias depends on what is estimated.

## Slide 11 — Can the data tell us which mechanism? (2 min)

- **Against MCAR: sometimes** (compare complete and incomplete rows; Little's test, next
  slide). **For MCAR:** a non-significant test is not proof. **MAR vs MNAR: no test exists.**
- Argue the mechanism from how the data were collected: who was asked, who answered, who was
  never asked, and why.

## Slide 12 — In R: Little's test on MCAR and MAR data (3 min)

`naniar::mcar_test()` on the MASLD BMI/waist data, twice. Waist hidden for 1,814 adults at
random: statistic 0.175 on 1 df, p = 0.676. Waist hidden for about 60% of adults with BMI above
35: statistic 1838.456, p < 0.001. The slide states the null hypothesis and how to read p.

## Slide 13 — In R: Little's test on MCAR and MAR data (2 min)

The two results as a table: p = 0.676, no evidence against MCAR (not proof of it); p < 0.001,
evidence against MCAR. The box: the test cannot prove MCAR, cannot tell MAR from MNAR, and
cannot say whether complete cases are biased. The notes read `missing.patterns = 2`.

## Slide 14 — Quick fixes that cause trouble (2 min)

Complete cases without thinking; the mean; a "missing" category or indicator (Vach & Blettner
1991; Greenland & Finkle 1995); last value carried forward. Any single filled-in value treated
as measured makes standard errors too small.

## Slide 15 — Single imputation: four ways to fill a gap (2 min)

The method table: mean (`"mean"`), regression prediction (`"norm.predict"`), stochastic
regression (`"norm.nob"`), predictive mean matching (`"pmm"`); what fills each gap, and what
goes wrong when it is done once. Box: any of these done once is single imputation; MI repeats
proper draws (which also redraw the model's coefficients) and pools.

## Slide 16 — Single imputation, in a picture (3 min)

- **The figure** is `w7_single_imp.png`: the MASLD adults' BMI and waist, with 1,814 waist
  values hidden at random and filled in once three ways.
- **SD of waist:** truth 13.0 cm; mean fill 10.9; regression 12.4; stochastic 13.0.
- **Correlation with BMI:** truth 0.83; mean 0.70; regression 0.87; stochastic 0.83.
- **The box reads one panel at a time:** the mean shrinks the spread and weakens the
  correlation; regression exaggerates the correlation; noise keeps both, but one copy still
  hides the uncertainty.

## Slide 17 — Multiple imputation in three steps (3 min)

- **The figure** is `w7_mi_workflow.png`: incomplete data → `mice()` → m copies (`mids`) →
  `with()` → m results (`mira`) → `pool()` → one result (`mipo`). Last year's Lumley picture.
- **The table:** each verb, its R line, the object R prints and what it holds;
  `complete(imp, 1)` returns copy 1 as an ordinary data frame.

## Slide 18 — How MICE works: one person, one iteration (3 min)

Made-up numbers: one person missing both smoking and sedentary time. Start 0 / 300 min; update
smoking (predicted probability 20%, the random draw says smoker) → 1 / 300; update sedentary
time from the new smoking (PMM borrows an observed 410 minutes) → 1 / 410; repeat with the
latest values. Each filled-in value helps predict the other.

## Slide 19 — How MICE works: iterations (`maxit = 10`) vs. imputations (`m = 20`) (3 min)

Within each copy, every incomplete variable is updated 10 times (`maxit`); only the last round
is kept. Twenty separate chains give 20 completed copies (`m`). Iterations let a chain
stabilise (the trace plot checks it, Slide 37); copies carry the uncertainty about the missing
values. More iterations do not replace more copies.

## Slide 20 — How `mice()` fills several variables (2 min)

The figure is `w7_chained.png`: random starting values; smoking from everything else;
sedentary time from everything else including the new smoking; repeat; one copy; all of it m
times. Observed values never change. Slide 18's one person was one pass of it (the box says so).

## Slide 21 — Within and between: three copies, by hand (3 min)

Made-up numbers: log HRs 0.40, 0.70, 1.00, each with SE 0.20. Pooled 0.70; within Ū = 0.04;
between B = 0.09; T = 0.04 + (1 + 1/3) × 0.09 = 0.16; SE = 0.40, double each copy's. Pool
variances, not SEs, on the log scale.

## Slide 22 — Rubin's rules: combining the copies (3 min)

- **The figure** is `w7_rubin_town.png`: the town's copies disagree, so the pooled interval is
  wider than any single copy's. The width of each grey line is within; how far the dots wander
  is between. The MASLD panel comes at Slide 43.
- **The formula:** pooled estimate = the average; total variance = Ū + (1 + 1/m) B.
- **Grey box, in numbers** (m = 100, log RR among the old): Ū = 0.03802, B = 0.02400,
  T = 0.03802 + 1.01 × 0.02400 = 0.06226, so the SE grows from 0.195 to 0.250. The full
  calculation in R is A5.
- **Say this.** The figure and the box use a fourth version of the town that the deck no longer
  shows: smoking hidden for half of those who died. Death is recorded for everyone, so that is
  MAR, and imputing smoking from age and death recovers the RR. One sentence is enough.

## Slide 23 — What the town taught us (3 min)

Three lessons: bias depends on what is estimated (the share was wrong, the RR right); complete
cases are not always biased, even under MNAR; MI is not automatically better (under MAR it can
reduce bias if the model includes the outcome; under MNAR it can still be biased). Box: ask what
you are estimating, why values are missing, and what your method assumes. The notes call the
break.

## BREAK (10 min), after Slide 23

## Part 2 · Multiple imputation, step by step, in MASLD · 56 minutes

## Slide 24 — The MASLD analysis we will impute (3 min)

- **The model:** Week 5's, adjusted for L. **The headline:** waist fat's HR among the not
  obese, Group IV vs III. The 2 × 2 group table is on the slide (WHtR < 0.6 vs ≥ 0.6, not obese vs
  obese; Group III the reference). Say it if asked (not on the slide): obese = BMI ≥ 30 (≥ 25
  for Asian participants); high waist fat is the paper's "central adiposity".
- **The rows:** 6,048 (everyone imputation uses) and 5,963 (complete on L, today's complete
  cases). The notes: the 5,911 and the 5,963 give the same HRs to two decimals.

## Slide 25 — In R: the set-up for Part 2 (2 min)

- **What the code adds:** `smk` (Weeks 4–6's `smk_current` as a factor, so `mice()` uses
  logistic regression rather than PMM), `cycle` and `agegrp` as factors, `ccL` (complete on L),
  and `fm`, Week 5's model with `smk`. `fast` is cut to its design columns.
- **Output:** 6,048 rows, 5,963 complete on L, a fasting frame of 17,208.
- **Bullets:** `smk_current` (100 cigarettes and smokes now; the 4 refused or "don't know"
  answers coded non-smoker, as in Weeks 4–6); `sed` standardised (SD 1 = 207 minutes); `fast` is
  Week 6's fasting frame, `subset(nhanes, WTSAF2YR > 0)` with `wt = WTSAF2YR / 6`.
- **Say it (not on the slide):** the frame is everyone with a fasting weight, aged 12 and over,
  so its 17,208 include 2,246 aged 12–17.

## Slide 26 — Step 0: type every loss first (2 min)

- **The figure** is `w7_funnel1.png`, with P5's types: 59,842 participants; adults 36,580
  (eligibility); fasting subsample 14,962 (design); all four FLI inputs 14,170 (missingness: 792
  lack an input); FLI ≥ 60 and MASLD 6,050 (target population); linked 6,048 (outcome: 2 not
  linked); complete on L 5,963 (missingness: 57 asked differently + 28 not answered, imputed
  today).
- **Notes:** read the types, not the numbers. The 792 without an FLI input decide who enters
  the cohort; imputing them is not attempted.

## Slide 27 — Step 0: today's missing-data problem, 85 rows (2 min)

6,048 − 57 (smoking asked differently: aged 18–19, interviewed 2007–2012) − 28 (sedentary time
not answered) = 5,963 complete on L, with L spelled out.

## Slide 28 — Step 0: How much is missing? (2 min)

`colSums(is.na())` on the five variables of L: smoking **57**, sedentary time **28**, age, sex
and race complete; `complete.cases()` gives 5,963, so 5,963 of 6,048 (98.6%) are complete on L.
This block is typed on the slide rather than run by the outputs script; its numbers are the
emitted counts.

## Slide 29 — Step 0: why is each value missing? (3 min)

| Kind | MASLD | What it needs |
|---|---|---|
| Never asked | cancer: all 109 18–19-year-olds | a narrower population, or an assumption |
| Asked differently | smoking: the 57 18–19-year-olds of 2007–2012 (youth questionnaire; 55 answered) | harmonise first |
| Not answered | sedentary time: 28 ("don't know" 22, blank 6) | a mechanism argument |
| Never sampled | everyone outside the fasting subsample | the weight (Week 6): design, not a missing-data method |

NHANES codebooks (notes): MCQ220 (cancer) targets 20 and over in every cycle 2007–2018; SMQ020
(smoking) targeted 20 and over until 2011–12, and from 2013–14 18–19-year-olds answer the adult
smoking questions. **The box:** name the kind *before* choosing a method; a count of `NA`s shows
all four as the same blank. For the presenter (not in the deck): the old Week 7 and P5 called
the 109 "item-missing" or ordinary MAR; they are a questionnaire skip, and MCAR/MAR/MNAR apply
to the missingness rows only.

## Slide 30 — In R: who is missing, and why (2 min)

One table: among the 18–19-year-olds, smoking is missing for everyone in cycles 5–7
(2007–2012: 16, 25, 16) and for no one in cycles 8–10 (2013–2018: 18, 21, 13 answered).

## Slide 31 — Step 0: Who has missing data? (3 min)

- **On L:** complete **5,963**, incomplete **85**. Mean age **51.1** vs **32.0**; died
  **9.0%** vs **3.5%**. Missingness is related to what we can see, so MCAR is unlikely.
- **The box, the Cox rule:** a difference is a reason to investigate, not proof of bias. For an
  adjusted Cox model the question is whether being a complete case depends on the event process
  given the model's covariates.
- **Notes:** a share dying is not a hazard; only three deaths among the 85, so mortality
  comparisons are imprecise.

## Slide 32 — Step 1: What goes into the imputation model? (3 min)

- The analysis variables (the obesity–waist groups, age, sex, race, smoking, sedentary time),
  the outcome (`dead` and the Nelson–Aalen cumulative hazard `H`; White & Royston 2009),
  auxiliaries (survey cycle, age groups) and design information (the log weight); never the ID.
- **The line:** `dat$H <- nelsonaalen(dat, time_yr, dead)`. Raw time stays for `Surv()` but is
  not a predictor.
- **For the TA:** strata as a factor, and PSU indicators within strata (never the raw PSU
  number), are fuller design options (Reiter et al. 2006). The choices are not equally complete:
  say which and why.

## Slide 33 — In R: Step 1, a dry run (2 min)

`mice(dat, maxit = 0)` sets up without imputing. The method vector: **logreg** for smoking (a
two-level factor), **pmm** for sedentary time; `""` for complete columns. The table of methods
by variable type is in the appendix (A4).

## Slide 34 — In R: Step 1, the predictor matrix (2 min)

An extract of the matrix: rows `smk` and `sed`, columns `SEQN`, `time_yr`, `dead`, `H`,
`group`, `age`, `cycle`; 1 = use, 0 = leave out. `SEQN`, `time_yr`, `obese` and `central` are
zeroed (`H` replaces time, `group` replaces the two indicators); death and `H` stay in.

## Slide 35 — Step 2: how many copies and iterations? (2 min)

- **Rules for m:** 3–5 (Rubin 1987); at least the % of incomplete rows (White, Royston &
  Wood 2011); 20–100 (Austin et al. 2021).
- **Ours:** 1.4% of rows incomplete on L (2.3% on Weeks 4–6's variables): m = 20 meets all
  three rules. `maxit` = 10 (mice's default is 5; the trace plot decides).
- More copies reduce simulation noise; they do not fix the model or MNAR.

## Slide 36 — In R: Step 2, impute (1 min)

`mice(dat, m = 20, maxit = 10, method = meth, predictorMatrix = pred, seed = 607)`: 57 and 28
gaps filled in each copy. Set the seed: imputation is random.

## Slide 37 — Step 2, check 1: did it converge? (2 min)

`w7_trace.png`, drawn by `plot(imp, c("smk", "sed"), layout = c(2, 2))`: one line per copy over
10 iterations. For a factor, mice plots the level codes (1 = non-smoker, 2 = smoker); sedentary
time is in SDs.

## Slide 38 — Step 2, check 1: How to read the trace plots (2 min)

Good: lines fluctuate around a stable level, overlap, no trend. Concerning: drift, or chains
that stay apart. The trace plot judges `maxit`, not m; convergence does not show the imputed
values are right.

## Slide 39 — Step 2, check 2: observed vs filled in (2 min)

`w7_density.png`, drawn by `densityplot(imp, ~ sed)`: the red curves (28 filled-in values per
copy) are wider than the blue and differ from copy to copy; the blue observed curve is the
bumpier one. PMM borrows real observed values, so tails beyond the
blue are smoothing, not impossible values. They need not match under MAR; a red curve far
outside the blue is a warning. The x-axis is in SDs, not minutes.

## Slide 40 — Why do we need multiple completed datasets? (3 min)

- **The table** (real output of `complete(imp, k)` for copies 1–4): three people whose smoking
  was missing (A, B, C) are smokers in some copies and non-smokers in others; D, observed, is a
  non-smoker in every copy. No copy is the right one: all 20 are analysed and pooled.
- **The second box:** two different checks, convergence (Slides 37–38) and plausibility
  (Slide 39). A model can converge and still impute badly.
- The slide is set in smaller type to fit both boxes.

## Slide 41 — Step 3: analyse each copy (2 min)

`with(imp, coxph(...))`: 20 fits in one `mira` object. The HR for waist fat among the not obese
ranges from 1.095 to 1.097 across copies.

## Slide 42 — Step 4: pool with Rubin's rules (3 min)

- `pool(fits)`, then the `central` row's `estimate`, `ubar`, `b` and `t`, in a teaching table:
  0.09137 (HR 1.10); Ū 0.02614; B about 0; T = 0.02614, SE 0.162. The same arithmetic as
  Slide 21's three copies.
- **The box:** B about 0, so the copies agree on this coefficient under this imputation model;
  not evidence of no bias; in the town B was 0.024.
- **Notes only:** `lambda` and `fmi` (about 0; **fmi** prints 0.004 because mice adds a
  small-sample term, 2/(df + 3) with df about 524: it is not information lost to the gaps).

## Slide 43 — In R: Step 4, the pooled hazard ratio (2 min)

- **`summary(pooled, conf.int = TRUE, exponentiate = TRUE)`, the `central` row:** 1.10
  (0.80–1.51), a t interval (df about 524); with ± 1.96 SE, 0.80–1.50.
- **The MASLD panel of the Rubin figure** (`w7_rubin_masld.png`): the 20 copies agree, unlike
  the town's.
- **The box: practice with `pool()`, unweighted.** Waist fat among the not obese (IV vs III):
  imputed, all 6,048 rows, **1.10**; complete on L, 5,963 rows, **1.09**. The box gives no
  intervals: the imputed one with ± 1.96 SE, 0.80–1.50, is in the footer, and the complete-case
  0.79–1.50 is shown on Slide 47. The footer adds the obese stratum (3.03 vs 2.99) and the ratio
  (2.76 vs 2.74).

## Slide 44 — Step 5: Multiple imputation with NHANES survey data (3 min)

- **The recipe, in words:** for each of the 20 copies, rebuild the full fasting frame (17,208:
  the 6,048 MASLD adults plus the 11,160 others), declare Week 6's design (weights, strata,
  PSUs), fit `svycoxph()` in the MASLD domain; then combine the 20 results with Rubin's rules.
- **The box:** multiple imputation does not replace the survey design.
- **For the TA:** in R this is `complete(imp, "long")`, add back the rest of the frame,
  `svydesign(..., data = imputationList())`, `subset()`, `with(svycoxph())`, `MIcombine()`:
  Thursday's lab runs exactly this with `svyglm()` (Slide 57). The weighted results are on
  Slide 46.

## Slide 45 — Our missing-data workflow (1 min)

Steps 0–5 recapped: Steps 3–4 were the unweighted demonstration; Step 5 brings the design in
before fitting and pooling.

## Slide 46 — Complete cases vs imputation, side by side (2 min)

- **A two-row table:** design-weighted, waist fat among the not obese (IV vs III), adjusted for
  L: complete on L, 5,963 rows, 1.43 (0.98–2.07); imputed (m = 20), 6,048 rows, 1.43
  (0.99–2.07).
- **Say this:** under this imputation model the estimate changed very little; that is a finding
  about these 85 gaps, learned by checking, and says nothing about MNAR.

## Slide 47 — Sensitivity analysis: What if our imputations are wrong? (3 min)

- **Selected extreme fills of the 85**, unweighted, waist fat among the not obese: complete
  cases (5,963) 1.09 (0.79–1.50); all 57 non-smokers and all 28 at 0 minutes, 1.10 (0.80–1.50);
  all 57 smokers and all 28 at 1,200 minutes, 1.10 (0.80–1.51).
- **The box:** the HR is not sensitive to these fills; that does not prove it unbiased. The
  footer: fixed fills ignore imputation uncertainty and are not bounds.

## Slide 48 — What did multiple imputation change in MASLD? (2 min)

- **Weighted:** complete cases, 5,963, 1.43 (0.98–2.07); multiple imputation, 6,048, 1.43
  (0.99–2.07).
- **Who changed:** MI kept 85 more adults (the 57 aged 18–19 of 2007–2012 and 28
  non-responders). **What changed:** the HR barely moved. **The limitation:** imputing the 57's
  smoking extrapolates (no one aged 18–19 in 2007–2012 answered the adult question).
- **Fair to the paper** (say it, not on the slide): nothing here makes its numbers wrong; the
  analysis is ours.

## Part 3 · Special cases, limits and reporting · 16 minutes

## Slide 49 — When the outcome is missing: MID (2 min)

Impute everything including the outcome; delete the rows whose outcome was imputed; analyse and
pool (von Hippel 2007). Useful when many outcomes are missing. **Not a default:** MID can be
biased when an auxiliary variable predicts both the outcome and whether it is missing; then keep
the imputed outcomes (Sullivan et al. 2015). L6's question 3 uses MID; its code issue is TA
note 5, not on the slide. Our outcome is complete: the 2 adults not linked are outcome
ascertainment.

## Slide 50 — When MNAR is plausible: a sensitivity analysis (2 min)

Delta adjustment (shift the filled-in values by a delta, e.g. 30 minutes = 0.15 on the
standardised scale; for smoking, add the delta to the log-odds in its imputation model before
the values are drawn; refit and pool at each delta). **One value, worked:** a filled-in 300
minutes becomes 330 under delta = +30; an observed 250 stays 250; repeat for delta = −30, 0,
+30, +60 (not run today). In `mice`:
`post` for sedentary time, method `"mnar.logreg"` for smoking. Slide 47's extreme fills are
selected scenarios, not bounds; more imputations do not fix MNAR.

## Slide 51 — What missing-data methods cannot fix (2 min)

Never sampled (the weight; its nonresponse adjustment also covers the 323 with a fasting
weight of 0), never asked, asked differently, MNAR, selection on FLI ≥ 60, unmeasured
confounding.

## Slide 52 — How to report missing data (2 min)

The six items (Sterne et al. 2009; the EpiMethods blueprint and RAISE-MI).

## Slide 53 — Reporting our missing data (1/2) (2 min)

The methods paragraph as a numbered list, each sentence followed by the reporting item it
answers: 1 how much (85, 1.4%: 57 smoking, 28 sedentary); 2 why (youth questionnaire; "don't
know" or blank); 3 complete cases as the primary analysis; 4 the MAR assumption, the imputation
model and the extrapolation for the 57; 5 method, m, iterations, software, seed. It quotes
R 4.5.1 and mice 3.18.0, the versions the code ran with.

## Slide 54 — Reporting our missing data (2/2) (2 min)

6 checks; 7 analysis and pooling (survey-weighted Cox, Rubin's rules); 8 results side by side
(1.43 and 1.43); 9 which population each describes, and the harmonised-smoking sensitivity
(A1: 6,018 adults, unweighted, against unweighted complete cases).

## Slide 55 — The algorithm to take into your own paper (1 min)

The workflow line again, with four questions to ask before trusting a result.

## Slide 56 — Key takeaways (2 min)

- Five takeaways, ending with MASLD: complete cases changed **who** the estimates describe;
  imputation barely moved waist fat's HR.
- **Exit question:** which missing values were never asked, which asked differently, and which
  not answered?

## Slide 57 — Thursday's lab (L6) and P5 (1 min)

- **On the slide:** L6 is not MASLD; the same recipe as Step 5, now in code; design information
  in the imputation model differs between today (log weight), Thursday (strata) and P5's example
  (weight and strata), and the choices are not equally complete.
- **P5's worked example is labelled on the slide** as using the paper's Model 1: Model 1, 5,939
  rows, Group IV vs III, weighted, complete cases 1.29 (0.89–1.86), MI 1.28 (the slide gives no MI interval; it is
  0.89–1.85); ours is L, 1.43 on 5,963 rows. Its 109 cancer blanks are imputed under a stated assumption (an
  extrapolation); narrowing to adults 20+ is the alternative.
- **Next week (speaker notes only; say it):** M1 presentations.

## Appendix (A1–A5, screen 63–67; the deck does not print the labels)

A1 harmonising the 57: imputed, 13% of them are current smokers; their own youth answers (55
answered) give 36% on any of the past 30 days and 13% on all 30; counting "any day" as current
smoking, waist fat's HR among the not obese is 1.08 (0.79–1.48) and the ratio 2.79 on 6,018
rows, unweighted, against 1.09 (0.79–1.50) for the unweighted complete cases on L. A2 variable
selection with MI; A3 skewed variables and ratios; A4 methods by variable type; A5 Rubin's rules
by hand in the town (the MAR-on-death version, log RR 0.69890).

## Thursday — L6 (EpiMethods `missingdataE`) · for the TA and the instructor, not in the deck

Say this out loud, twice: **L6 is not MASLD.** Points 1–7 were checked against the exercise's
own code and data on 2026-10-07; the solution page was re-read on 2026-10-16.

1. **What it is.**
   - **Data:** Williams et al. 2021 (*Prev Med*), NHANES 2015–2018. **4,746** adults with
     diabetes or hypertension; **4,716** have complete outcomes and exposures.
   - **Model:** survey-weighted logistic regression (`svyglm`), not a Cox model.
   - **Missing confounders:** income 13.1%, BMI 6.4%, comorbidity 3.0%. **20.2%** of rows are
     incomplete.
   - **Workflow:** impute (`mice`, m = 5), `complete(..., "long")`, stack the ineligible rows
     (`eligible = 0`), `svydesign(..., imputationList(split(...)))` on the whole file,
     `subset(eligible == 1)`, `with()`, `MIcombine()`. That is today's Step 5 with `svyglm()`.
2. **Odds ratios.** Missingness that depends on the outcome but not on the exposure leaves an OR
   unbiased (Bartlett et al. 2015).
3. **m = 5 is a time-saving shortcut.** The "m ≥ % incomplete" rule gives **21** for these data.
4. **Design variables in the imputation model.** The exercise text says to use strata but not the
   weight, PSU or ID; its code drops only DIQ010 and BPQ020, so `id`, `survey.weight`, `psu` and
   `strata` all become predictors.
   - **Fix:** `pred <- make.predictorMatrix(dat_for_imputation); pred[, c("id", "psu")] <- 0`.
     The raw `psu` code (1, 2, ...) means nothing outside its stratum, so it is no predictor; a
     fuller model would use stratum-by-PSU indicators.
   - **The weight:** keep it, as Tuesday did (log weight), or zero it, as the lab's text says.
     The choices are not equally complete (Reiter et al. 2006); say which and why. **Strata:** a factor.
   - **The fix barely changes the result** (advice OR 1.846 → 1.845).
5. **Question 3 ("MID") imputes no outcomes or exposures.** It reuses question 2's `meth`, which
   gives those variables method `""`. **Fix:** build `make.method()` on the question 3 data;
   record a missing-outcome indicator before `mice()`.
6. **Only the advice row answers the question.** The other rows are adjustment terms (Week 4's
   Table 2 fallacy).
7. **Housekeeping.** The setup chunk loads `DataExplorer`, which the L6 page does not install;
   the page says `set.seed(504)` and the solution uses `mice(seed = 123)`; `bmi` is a 3-level
   factor, so PMM on it is a lab choice (A4's table gives `polyreg`).

**The L6 page (`labs/L6_missing_data.md`) — report only; lab pages are not edited unless the
instructor asks.** It says the lab "implements MI inside the survey framework from last week"
and "runs inside the survey design you declared in L5". L5 used a different file, and
design information enters the imputation model (Slide 32) and the design is declared for each
completed copy (Slide 44). Its install line omits `DataExplorer`. Its lecture links already point at this
deck's file names.

## Upstream (EpiMethods)

- **`missingdata0`'s summary table** says complete-case analysis is biased under MAR and MNAR.
  True for a share; not for a regression coefficient when missingness does not depend on the
  outcome given the covariates (Slide 10). Add the White & Carlin / Hughes qualification.
- **`missingdataEsolution`:** fix the predictor matrix; fix question 3's `meth`; set m to at
  least 21 or say why 5; install `DataExplorer`.
- **`missingdata12` (survival):** `method = 'pmm'` as one string imputes every incomplete
  column, so the 134 missing outcome times and statuses are filled although the text says the
  outcome is not imputed. Use a method vector with `""` for the outcome.

## If you are running behind

The content is 136 minutes, 4 under the class with the break. If questions run long, cut in
this order (12 minutes in all):

1. Slide 13 (Little's test table), 2 min: say its two p-values on Slide 12
2. Slide 14 (quick fixes), 2 min: Slide 15's method table covers the mean fill
3. Slide 30 (who is missing, in R), 2 min: on Slide 29 say its result: missing smoking is
   exactly the 18–19-year-olds of 2007–2012
4. Slide 38 (reading the trace plots), 2 min: one sentence on Slide 37
5. Slide 45 (workflow recap), 1 min: Slide 55 repeats it
6. Slide 51 (what methods cannot fix), 2 min: one sentence on Slide 50
7. Slide 55 (the algorithm), 1 min: it repeats Slide 4; point back to it from Slide 56

Never cut Slides 8–10, 17, 22, 29, 32, 42, 44, 46 or 48.

## Reading map — each segment and where students can review it

| Segment | EpiMethods | Reading |
|---|---|---|
| Mechanisms, MCAR tests (Slides 5–13) | [Concepts (M)](https://ehsanx.github.io/EpiMethods/missingdata0.html); [MCAR tests](https://ehsanx.github.io/EpiMethods/missingdata6.html) | Little & Rubin 2019; White & Carlin 2010; Hughes et al. 2019 |
| Ad hoc and single imputation (14–16) | [Concepts (M)](https://ehsanx.github.io/EpiMethods/missingdata0.html) | Vach & Blettner 1991; Greenland & Finkle 1995 |
| MI, MICE, Rubin's rules (17–23, 32–43) | [Imputation](https://ehsanx.github.io/EpiMethods/missingdata1.html); [Imputation in NHANES](https://ehsanx.github.io/EpiMethods/missingdata2.html) | White, Royston & Wood 2011; van Buuren 2018; Austin et al. 2021 |
| Survival outcomes (32–34) | [Survival analysis](https://ehsanx.github.io/EpiMethods/missingdata12.html) | White & Royston 2009 |
| Survey design (44) | [Subpopulations](https://ehsanx.github.io/EpiMethods/missingdata5.html) | Lumley 2010, ch. 9; Reiter et al. 2006 |
| MID (49) | [Missing in outcome](https://ehsanx.github.io/EpiMethods/missingdata3.html) | von Hippel 2007; Sullivan et al. 2015 |
| MNAR, extreme fills (47, 50) | [Concepts (M)](https://ehsanx.github.io/EpiMethods/missingdata0.html) | Leacy et al. 2017; van Buuren 2018, ch. 9 |
| Reporting (52–54) | [Reporting blueprint](https://ehsanx.github.io/EpiMethods/missingdata0.html#a-blueprint-for-reporting-multiple-imputation) | Sterne et al. 2009 |

## Known differences from P5's materials

- **Specification and rows.** The P5 handout and worked example use the paper's Model 1 on 5,939
  rows. This lecture uses L on 5,963 and 6,048 rows (and recalls Weeks 4–6's 5,911).
- **The 109 missing cancer values.** P5 treats them as ordinary missingness, "MAR given the
  Model-1 covariates and the outcome", and runs an "all have cancer" extreme. They are a
  questionnaire skip: every one is an 18–19-year-old, and the question starts at age 20.
- **"Exactly one Model-1 covariate carries any missingness."** The P5 handout and worked example
  say this, and the M1 exemplar repeats it through P5.json. The data say otherwise: `mi` has 109
  never-asked values coded "no"; `htn` has 96 people without a BP reading coded "not
  hypertensive".
- **P5's population sentence** should say that its complete-case estimate covers adults aged
  20+.
- **Strata in P5's imputation model.** SDMVSTRA enters as a number. Strata are labels: use a
  factor or leave them out.
- **P5's worked-example funnel** orders the steps differently (fasting frame before adults), uses
  "DISEASE", and calls 6,052 → 6,048 "disease + small missingness". The handout and this deck
  (Slide 26) type the 2 unlinked as outcome ascertainment.

Align P5, and the M1 exemplar's missingness slide that inherits from it, in a separate round.

## References

- Austin PC, White IR, Lee DS, van Buuren S. Missing data in clinical research: a tutorial on multiple imputation. *Can J Cardiol* 2021;37:1322–1331.
- Bartlett JW, Harel O, Carpenter JR. Asymptotically unbiased estimation of exposure odds ratios in complete records logistic regression. *Am J Epidemiol* 2015;182:730–736.
- Greenland S, Finkle WD. A critical look at methods for handling missing covariates in epidemiologic regression analyses. *Am J Epidemiol* 1995;142:1255–1264.
- Hughes RA, Heron J, Sterne JAC, Tilling K. Accounting for missing data in statistical analyses: multiple imputation is not always the answer. *Int J Epidemiol* 2019;48:1294–1304.
- Leacy FP, Floyd S, Yates TA, White IR. Analyses of sensitivity to the missing-at-random assumption using multiple imputation with delta adjustment. *Am J Epidemiol* 2017;185:304–315.
- Little RJA, Rubin DB. *Statistical Analysis with Missing Data*. 3rd ed. Wiley, 2019.
- Lumley T. *Complex Surveys: A Guide to Analysis Using R*. Wiley, 2010.
- Reiter JP, Raghunathan TE, Kinney SK. The importance of modeling the sampling design in multiple imputation for missing data. *Surv Methodol* 2006;32:143–149.
- Rubin DB. Inference and missing data. *Biometrika* 1976;63:581–592.
- Rubin DB. *Multiple Imputation for Nonresponse in Surveys*. Wiley, 1987.
- Sterne JAC, White IR, Carlin JB, et al. Multiple imputation for missing data in epidemiological and clinical research: potential and pitfalls. *BMJ* 2009;338:b2393.
- Sullivan TR, Salter AB, Ryan P, Lee KJ. Bias and precision of the "multiple imputation, then deletion" method for dealing with missing outcome data. *Am J Epidemiol* 2015;182:528–534.
- Vach W, Blettner M. Biased estimation of the odds ratio in case-control studies due to the use of ad hoc methods of correcting for missing values for confounding variables. *Am J Epidemiol* 1991;134:895–907.
- van Buuren S. *Flexible Imputation of Missing Data*. 2nd ed. Chapman & Hall/CRC, 2018.
- von Hippel PT. Regression with missing Ys: an improved strategy for analyzing multiply imputed data. *Sociol Methodol* 2007;37:83–117.
- White IR, Carlin JB. Bias and efficiency of multiple imputation compared with complete-case analysis for missing covariate values. *Stat Med* 2010;29:2920–2931.
- White IR, Royston P. Imputing missing covariate values for the Cox model. *Stat Med* 2009;28:1982–1998.
- White IR, Royston P, Wood AM. Multiple imputation using chained equations: issues and guidance for practice. *Stat Med* 2011;30:377–399.
- Williams AR, Wilson-Genderson M, Thomson MD. A cross-sectional analysis of associations between lifestyle advice and behavior changes in patients with hypertension or diabetes: NHANES 2015–2018. *Prev Med* 2021;145:106426.
