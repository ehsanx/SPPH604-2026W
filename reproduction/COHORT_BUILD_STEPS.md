# Building the analytic dataset — step by step

*How the paper's Methods section becomes `data/derived/masld_analytic.rds`, one decision
at a time.*

This page answers a different question from the other three in this folder:

| Page | Answers |
|---|---|
| [`README.md`](README.md) | How do I run it, and what lives where? |
| [`VARIABLE_MAP.md`](VARIABLE_MAP.md) | What *is* this variable — codebook, cycles, reserved codes? |
| [`reproduction_report.md`](reproduction_report.md) | Did it reproduce, and what did we find? |
| **this page** | **What are the steps, in order — and why was each one decided that way?** |

`VARIABLE_MAP.md` is a dictionary: look a variable up in it. This page is the **recipe**:
read it top to bottom. Each step gives you the paper's own sentence, the NHANES
component and variables that sentence forces you to download, the judgment call we had
to make because the sentence did not fully determine an answer, and the number of rows
left afterwards.

> **The one habit this page is teaching.** A Methods sentence is not code. Between the
> sentence and the code there is always a decision, and the decision is usually invisible
> in the published paper. Your job in P1 is not to guess the authors' decision — it is to
> **make your own, write down why, and count what it cost you.** Every "Decision" box
> below is an instance of that, and the ones marked ⚠ are where we and the paper may
> genuinely differ.

---

## Step 0 — What you download, and what each file is for

`R/00_setup.R` declares six NHANES cycles and 18 component names; `R/01_download.R`
fetches them. Nothing analytic happens in either file.

Cycle letters, used throughout: **E** 2007-08 · **F** 2009-10 · **G** 2011-12 ·
**H** 2013-14 · **I** 2015-16 · **J** 2017-18. The *file* carries the suffix
(`BMX_H.xpt`); the *variable* inside usually does not (`BMXBMI` in all six).

### The three downloads

| # | What | From | Count |
|---|---|---|---|
| 1 | 18 components × 6 cycles | `wwwn.cdc.gov/Nchs/Data/Nhanes/Public/<year>/DataFiles/<COMP>_<suffix>.xpt` | 108 files |
| 2 | Multum drug lexicon `RXQ_DRUG.xpt` | same host, tried at 2015 / 2017 / 2013 | **0 — all three 404** |
| 3 | Linked mortality | `ftp.cdc.gov/pub/Health_Statistics/NCHS/datalinkage/linked_mortality/NHANES_<cycle>_MORT_2019_PUBLIC.dat` | 6 files |

About 204 MB in total. Every URL, byte size and status is recorded in
`data/raw/_download_manifest.csv` — check it before you debug anything else.

### Which component supplies what

| Component | Variables we keep | Feeds which step |
|---|---|---|
| `DEMO` | `RIDAGEYR` `RIAGENDR` `RIDRETH1` `RIDRETH3` `INDFMPIR` `WTINT2YR` `WTMEC2YR` `SDMVPSU` `SDMVSTRA` `SDDSRVYR` | 1 (age), 5 (Asian cut-point), 6 (PIR); design vars carried but unused |
| `BMX` | `BMXBMI` `BMXWAIST` `BMXHT` | 2 (FLI), 3 (adiposity criterion), 5 (both group axes) |
| `TRIGLY` | `LBXTR` `LBDLDL` **`WTSAF2YR`** | 2 (FLI), 3 (triglyceride criterion), 6 (dyslipidaemia); `WTSAF2YR` marks the fasting subsample |
| `BIOPRO` | `LBXSGTSI` `LBXSCR` | 2 (FLI — GGT), 6 (eGFR) |
| `GLU` | `LBXGLU` | 3 (glycaemia criterion) |
| `GHB` | `LBXGH` | 3 (glycaemia), 6 (T2DM) |
| `HDL` | `LBDHDD` | 3 (HDL criterion) |
| `BPX` | `BPXSY1`–`4` `BPXDI1`–`4` | 3 (blood-pressure criterion), 6 (hypertension) |
| `BPQ` | `BPQ020` `BPQ040A` `BPQ050A` `BPQ080` `BPQ090D` `BPQ100D` | 3 (antihypertensive / lipid-lowering "treatment" arms), 6 |
| `DIQ` | `DIQ010` `DIQ050` `DIQ070` | 3 (antidiabetic arm), 6 (T2DM) |
| `ALQ` | `ALQ130` `ALQ120Q` `ALQ120U` `ALQ121` `ALQ101` `ALQ110` `ALQ111` | 4 (alcohol exclusion) |
| `SMQ` | `SMQ020` `SMQ040` | 6 (smoking; Cox Model 2) |
| `MCQ` | `MCQ160B` `C` `D` `E` `F` `G` `K` `O` `MCQ220` `MCQ300A` | 6 (comorbidities) |
| `ALB_CR` | `URXUMA` `URXUCR` `URDACT` | 6 (CKD via albumin:creatinine) |
| `KIQ_U` | `KIQ022` | 6 (kidney self-report) |
| `PAQ` | `PAD680` | 6 (sedentary minutes; Cox Model 2) |
| `TCHOL` | `LBXTC` | 6 (lipid panel, descriptive) |
| `RXQ_RX` | — | **nothing.** Downloaded and never read by `02_build_analytic.R` |

> **Decision — we download more than we use.** `RXQ_RX` and the Multum lexicon were
> intended to classify medications by therapeutic class (SGLT2i, GLP-1). The lexicon
> 404s, so the medication covariates fall back to questionnaire self-report (`BPQ`,
> `DIQ`) instead. **Why we left the download in:** deleting it would hide the gap. The
> manifest showing three `MISSING` rows is the honest record that a planned covariate
> was not built. `KIQ022`, `LBXTC`, `MCQ160D/G/K` and `BPQ040A/090D` are likewise read
> into the frame and never used — kept because removing them would silently change what
> a future analyst can reach for without re-downloading.

### Then: stack and merge

`read_component()` (`R/02_build_analytic.R:43-53`) reads one component across all six
cycles, keeps `SEQN` plus the requested variables, and **pads any variable absent from a
cycle with `NA`**. The 16 domain frames are then `left_join`ed onto `DEMO` by `SEQN`
(`R/02_build_analytic.R:79-87`).

**N after merge: 59,842.**

> **Why this is safe here, and when it would not be.** `SEQN` is unique across all six
> cycles (verified: zero duplicates), and every component joined holds at most one row
> per person, so no join multiplies rows. `RXQ_RX` — one row *per prescription* — would
> have fanned the frame out badly, which is a second reason it is not joined.

> ⚠ **The NA-padding trap.** When a variable does not exist in a cycle, padding makes
> "this question was never asked" look identical to "this person did not answer". Nine
> variables we use are affected:
>
> | Variable | What it measures — the label inside the `.xpt` | Present in | Consequence |
> |---|---|---|---|
> | `RIDRETH3` | "Race/Hispanic origin **w/ NH Asian**" — the only ethnicity variable with a separate non-Hispanic Asian category | **G H I J** only | Asian status unknowable for 2007-2010 — see Step 5 ⚠ |
> | `DIQ070` | "Take diabetic **pills** to lower blood sugar" | **F G H I J** | in E, antidiabetic treatment rests on `DIQ050` (insulin) alone |
> | `MCQ160O` | "Ever told you had **COPD**?" | **H I J** only | the COPD prevalence has a different denominator from every other row of Table 1 |
> | `URDACT` | "First **albumin creatinine ratio** (mg/g)" | **F G H I J** | in E, ACR falls back to `URXUMA/URXUCR*100` |
> | `ALQ120Q` | "How **often** drink alcohol over past 12 mos" — a count | **E F G H I** | retired in the 2017-18 ALQ redesign |
> | `ALQ120U` | "# days drink alcohol **per wk, mo, yr**" — the unit that count is in | **E F G H I** | without it `ALQ120Q` is a bare number with no time base |
> | `ALQ101` | "Had at least **12 alcohol drinks/1 yr**?" | **E F G H I** | downloaded, never used — see Step 4 |
> | `ALQ121` | "Past 12 mo **how often** have alcohol drink" — frequency and unit fused into one coded item | **J** only | replaces `ALQ120Q`+`ALQ120U`; different coding, must be harmonised |
> | `ALQ111` | "**Ever** had a drink of any kind of alcohol" | **J** only | replaces `ALQ101`; downloaded, never used |
>
> Nothing in the code *fails* when this happens. That is exactly the problem, and it is
> why `VARIABLE_MAP.md` prints a cycle-availability column for every variable.

---

## Step 1 — Age eligibility

> **Paper:** "The study inclusion criteria were participants aged>18 years with evidence
> of MASLD."

| | |
|---|---|
| **Component → variable** | `DEMO` → `RIDAGEYR` |
| **Code** | `R/02_build_analytic.R:114` (`age <- RIDAGEYR`), filter at `:315` |
| **Rule applied** | `age >= 18` |

**N: 59,842 → 36,580** (ELIGIBILITY; 23,262 dropped)

> ⚠ **Decision — we used `>= 18`; the paper says `> 18`.** These differ by exactly
> **70 people**, and the difference is not a typesetting artefact: the published PDF
> contains 24 correctly encoded `≥` characters (`BMI≥30`, `WHtR≥0.6`, `FLI≥60`,
> `1≤PIR≤4`), so where the authors meant "at least" they wrote it. At the age criterion
> they wrote a plain `>`, meaning 19 and older.
>
> This matters more than 70 rows suggests, because it is the best available explanation
> of our N gap:
>
> | Rule | N | Deaths | Groups I/II/III/IV | Total abs. deviation |
> |---|---:|---:|---|---:|
> | Paper | 6,300 | 585 | 386 / 4,541 / 769 / 604 | — |
> | `age >= 18` (ours) | 6,371 | 586 | 391 / 4,585 / 787 / 608 | 71 |
> | `age > 18` (paper's words) | **6,301** | **585** | 379 / 4,534 / 781 / 607 | **29** |
>
> Strict `>18` lands one row off the published N and reproduces the death count exactly.
> **The counter-evidence:** the paper's Table 1 mean age is 51.0 (16.6), which is what
> the `>= 18` cohort gives; strict `>18` gives 51.4 (16.3). So this is a strong lead,
> not a settled answer — which makes it an unusually good classroom exercise. Run both,
> and say which you would defend.

---

## Step 2 — Hepatic steatosis via the Fatty Liver Index

> **Paper:** "The FLI was used to determine the presence of hepatic steatosis… A
> threshold of FLI≥60 was used to determine the presence of hepatic steatosis."

```
       exp(L)
FLI = -------- × 100,
      1 + exp(L)

L = 0.953·ln(TG) + 0.139·BMI + 0.718·ln(GGT) + 0.053·WC − 15.745
```

| Input | Component → variable | Units the formula requires | Units NHANES gives |
|---|---|---|---|
| Triglycerides | `TRIGLY` → `LBXTR` | mg/dL | mg/dL ✓ |
| BMI | `BMX` → `BMXBMI` | kg/m² | kg/m² ✓ |
| GGT | `BIOPRO` → `LBXSGTSI` | U/L | U/L ✓ |
| Waist circumference | `BMX` → `BMXWAIST` | cm | cm ✓ |

**Code:** `R/02_build_analytic.R:140-142`.

**N: 36,580 → 14,989** (FLI computable) **→ 6,376** (FLI ≥ 60)

Median FLI in the final cohort is 85.5 (IQR 73.7–94.7) — this cohort sits well above the
threshold, not clustered at it.

> **Decision — no unit conversion, and no reserved-code stripping.** All four inputs
> already arrive in the units Bedogni's equation expects, so the formula is transcribed
> verbatim. And **`LBXTR` and `LBXSGTSI` have no reserved codes** — a `77` in `LBXTR` is
> a triglyceride of 77 mg/dL, not a refusal. Stripping `77`/`99` "to be safe" would
> delete real measurements. Contrast Step 4, where the same digits *are* refusals. No
> input is ever zero or negative in these files, so `log()` never fails.

> ⚠ **Decision — we did NOT restrict to the fasting subsample.** Triglycerides come from
> the fasting subsample, which carries its own weight `WTSAF2YR`. The paper never says
> whether it restricted to that subsample. Two defensible row sets follow, and this
> pipeline keeps **both**, permanently:
>
> | Row set | FLI step | Final N | What it is |
> |---|---:|---:|---|
> | **Full analytic file** | 14,989 | **6,371** | every adult with all four FLI inputs, fasting weight or not. Saved as `masld_analytic.rds`; the steps below and every table in `output/` use it |
> | **Locked domain** | 14,170 | 6,048 | its subset carrying a valid `WTSAF2YR` |
>
> They differ because **819 adults have all four FLI inputs without a valid fasting
> weight**, of whom 323 survive to the end. **Why the full file is primary:** the paper
> does not report using survey weights, so 6,371 is the row set that reproduces it. **Why the locked domain
> exists anyway:** it is the only set on which a design-aware estimate is possible, and
> that is P4's job. 6,048 is a different denominator, not a correction to 6,371. Quote
> which one you mean, every time.

> **Decision — the fasting subsample is DESIGN, not missing data.** This is the single
> most-mistyped row in any NHANES funnel. **21,618 of the 36,580 adults are outside the
> fasting-weight frame** — most were never sampled for it, and `WTSAF2YR` exists to
> account for that selection stage — while only **792** are inside the frame and still
> lack an FLI input. The
> first number is answered by a weight and a sentence naming your population; the second
> is answered by P5's missing-data analysis. Adding them together and calling the sum
> "attrition" is the error the typed funnel in `logs/sample_funnel.csv` exists to prevent.
>
> **Say "outside the frame", not "never asked to fast".** A missing or zero `WTSAF2YR`
> conflates at least three states, and the weight cannot tell them apart:
>
> | | Adults |
> |---|---:|
> | No positive fasting weight | 21,618 |
> | …of whom carry a weight of **exactly 0** | 2,031 |
> | …of whom have a triglyceride value anyway | 966 |
> | …of whom have **all four** FLI inputs | 819 |
>
> Those last 819 were demonstrably measured fasting and still carry no usable weight. The
> variable marks *the analysable fasting domain*; it does not certify who was asked to
> fast. The funnel row is still correctly typed DESIGN — it is the *sentence describing
> it* that has to be careful.
>
> Check the arithmetic yourself, because it does not simply subtract: the full analytic
> file loses 21,591 rows at this step, not 21,618 − 792. The 819 adults who have all four
> FLI inputs *without* a valid fasting weight are kept, so 21,618 − 819 + 792 = 21,591.
> The locked domain, which drops them, is where the two numbers appear as separate rows.

---

## Step 3 — MASLD: steatosis plus ≥ 1 cardiometabolic criterion

> **Paper:** "MASLD was defined as the presence of hepatic steatosis, accompanied by at
> least one of the following cardiometabolic criteria…"

**Code:** `R/02_build_analytic.R:163-175`. **N: 6,376 → 6,374** (2 dropped)

| # | Paper's criterion | Component → variables | Our rule | Line |
|---|---|---|---|---|
| i | "BMI≥25 kg/m2 or waist circumference>94cm in men and>80cm in women" | `BMX` → `BMXBMI` `BMXWAIST`; `DEMO` → `RIAGENDR` | `bmi >= 25` OR `male & waist > 94` OR `female & waist > 80` | `:164` |
| ii | "fasting plasma glucose≥5.6 mmol/L or HbA1c≥5.7% or the use of antidiabetic medications" | `GLU` → `LBXGLU`; `GHB` → `LBXGH`; `DIQ` → `DIQ010` `DIQ050` `DIQ070` | `LBXGLU >= 100` OR `LBXGH >= 5.7` OR `dm_dx` OR `dm_tx` | `:169` |
| iii | "average blood pressure≥130/85 mm Hg or on antihypertensive treatment" | `BPX` → `BPXSY1-4` `BPXDI1-4`; `BPQ` → `BPQ050A` | `sbp >= 130` OR `dbp >= 85` OR `htn_tx` | `:170` |
| iv | "plasma triglycerides≥150 mg/dL or lipid-lowering therapy" | `TRIGLY` → `LBXTR`; `BPQ` → `BPQ100D` | `LBXTR >= 150` OR `lipid_tx` | `:171` |
| v | "HDL cholesterol≤40 mg/dL for men or<50mg/dL for women or specific treatment targeting HDL" | `HDL` → `LBDHDD`; `DEMO` → `RIAGENDR` | `male & LBDHDD <= 40` OR `female & LBDHDD < 50` | `:172` |

> **Decision — glucose in mg/dL, not mmol/L.** The paper states criterion (ii) in mmol/L;
> `LBXGLU` is in mg/dL, so someone has to convert, and the paper never shows the
> converted number. 5.6 mmol/L × 18.016 = **100.9 mg/dL**; we threshold at **100**, the
> conventional rounding. **212 people have a glucose between 100 and 100.9**, so our rule
> counts them as meeting the criterion where a strict reading would not. We therefore
> re-ran MASLD at ≥ 100.9 and counted who falls out: **0 people**. Keep 100 — and say
> you checked. *"It is only 0.9 mg/dL, it cannot matter" is a guess; "0 people change
> status" is a finding, and it cost one line of code.*

> **Decision — the asymmetric HDL operators are the paper's, not ours.** `≤40` for men
> and `<50` for women reads like a slip, but it is what the published text says, so we
> transcribed it. We did **not** implement "specific treatment targeting HDL cholesterol" —
> NHANES has no such variable. That is an unimplementable clause, and naming it is more
> honest than quietly folding it into `BPQ100D`.

> **Decision — blood pressure follows the NHANES averaging protocol, not `rowMeans`.**
> Per the Blood Pressure Procedures Manual §3.1.7.3: if more than one reading was
> obtained, **the first is always excluded**; an all-zero diastolic set averages to zero;
> a zero sitting alongside a positive diastolic reading is dropped. The helper at
> `R/02_build_analytic.R:97-112` implements exactly that, and `:150-160` asserts the
> all-zero records survive. **Why the care:** two earlier versions were wrong in opposite
> directions — `na_if(BPXDI*, 0)` deleted 277 measured zeros, and a plain `rowMeans`
> averaged zeros in alongside real readings *and* kept the first reading. The paper does
> not say what it did, so this is a documentation-informed choice, not a claim of
> computational identity.

> **Decision — a missing criterion counts as *not met*, not as *unknown*.** `n_crit`
> (`:173`) uses `rowSums(..., na.rm = TRUE)`, so an `NA` criterion contributes 0. That is
> the conservative direction: it can only keep someone **out** of MASLD, never let
> someone in.
>
> It also turns out to barely matter, and the reason is worth more than the rule:
>
> | | |
> |---|---:|
> | Meet criterion (i), adiposity | **6,329 of 6,371** |
> | Meet *exactly one* criterion | 354 |
> | …of whom, that one criterion is adiposity | **352** |
> | Dropped by this whole step | **2 of 6,376** |
>
> **Why.** FLI is built from BMI and waist, and criterion (i) *tests* BMI and waist, so
> selecting on FLI ≥ 60 strongly **enriches** the cohort for criterion (i). It does not
> *require* it — **89** cohort members have FLI ≥ 60 with a BMI under 25 (the minimum is
> 21.5), and 42 fail criterion (i) outright. Near-automatic by enrichment, not by
> construction, which is why the other four criteria rarely decide anything.
>
> **Report a filter by its effect, not its definition.** "MASLD required at least one
> cardiometabolic criterion" sounds like work; on this cohort it excluded **2 people**.
> Both sentences are true, and only the second is informative. The definition itself is
> the standard one — it is not wrong, it just does almost nothing once you have
> conditioned on the FLI.

---

## Step 4 — Alcohol exclusion: built, shipped, not applied

> **Paper:** "Individuals with significant alcohol consumption—defined as more than two
> drinks per day for men and more than one drink per day for women—were excluded from
> the analysis."

**Read this step in two halves, because they are different decisions.** First we *build*
the rule the paper describes — that is a measurement problem, and there are two ways to
get it wrong. Then we decide whether to *apply* it — that is a judgment call, and we
decide not to.

| | |
|---|---|
| **Component → variables** | `ALQ` → `ALQ130` (drinks per drinking-day), `ALQ120Q` + `ALQ120U` (frequency, cycles E–I), `ALQ121` (frequency, cycle J) |
| **Code** | `R/02_build_analytic.R:182-197`; the switch is `APPLY_ALCOHOL_EXCL` at `:40` |
| **Built** | `sig_alcohol`, a per-person flag. **427 people** in the cohort exceed the paper's threshold |
| **Applied?** | **No** — `APPLY_ALCOHOL_EXCL <- FALSE` |

**N: 6,371 → 6,371** — no rows dropped.

> **"Computed but never used" is not quite right.** `sig_alcohol` is computed, saved as a
> column in `masld_analytic.rds`, and the setting is written into
> `logs/sample_funnel.csv` as its closing row. What is *not* done is the `filter()`.
> The distinction matters: the exclusion is one flag away from being on, anyone can
> subset on the column themselves, and the funnel records which way it was set rather
> than leaving a reader to infer it. **A decision you can see and reverse is not the same
> as a decision never made.**

> **Decision — "drinks per day" means frequency × quantity, not `ALQ130`.** `ALQ130` is
> drinks per *drinking day*. Someone who has three drinks every Saturday reports
> `ALQ130 = 3` but averages 0.4 drinks/day. Using `ALQ130` alone over-excludes roughly
> 2,000 people. We reconstruct average daily intake as
> `(ALQ130 × days_per_year) / 365`, converting `ALQ120Q`/`ALQ120U` (per week / month /
> year → ×52 / ×12 / ×1) and mapping the redesigned `ALQ121` categories to days per year
> for 2017-18.

> **Decision — strip `777` and `999` first.** Both `ALQ130` and `ALQ120Q` use them for
> *refused* and *don't know*. **9 refusals** in this cohort would otherwise become people
> reporting 777 drinks a day, and every one of them would be reclassified as a heavy
> drinker. Compare Step 2, where identical-looking digits in `LBXTR` are real
> measurements. **There is no global NHANES missing-value rule; the codebook decides,
> variable by variable.**

> ⚠ **Decision — the exclusion is off, and the published justification for that is wrong.**
> The switch exists because applying the exclusion moves us *away* from the paper. But
> `reproduction_report.md` §6 currently says the +71 row gap is "almost entirely the
> alcohol-exclusion ambiguity", and the numbers do not support that:
>
> | Cohort | N | Deaths | Total abs. group deviation |
> |---|---:|---:|---:|
> | Paper | 6,300 | 585 | — |
> | Ours, exclusion **off** | 6,371 | 586 | 71 |
> | Ours, exclusion **on** (427 dropped) | **5,944** | 546 | **356** |
>
> Turning the exclusion on overshoots by 356 rows and loses 39 deaths. It cannot be what
> separates us from 6,300 — **Step 1's age rule is the better candidate.** Keeping the
> exclusion off remains the right call; the *reason* given for it in the report needs
> rewriting.

> **Known soft spot, if you switch it on.** `avg_drinks_day` is forced to 0 whenever
> frequency is missing (2,246 people) or when someone reports drinking days but no
> quantity (5 people). Missing intake therefore reads as abstinence — defensible when the
> exclusion is off, load-bearing the moment it is on. `ALQ101`/`ALQ110`/`ALQ111`
> (lifetime abstainer status) are downloaded and would let you separate genuine zeros
> from unknowns; nothing currently uses them.

---

## Step 5 — The four phenotype groups

> **Paper:** "Obesity was defined as BMI≥30kg/m² (≥25 kg/m² for Asians). High central
> adiposity was defined as a WHtR≥0.6. Group I included participants with obesity but
> low central adiposity; group II… obesity and high central adiposity; group III…
> non-obesity and low central adiposity; and group IV… non-obesity but high central
> adiposity."

| | |
|---|---|
| **Component → variables** | `BMX` → `BMXBMI` `BMXWAIST` `BMXHT`; `DEMO` → `RIDRETH3` |
| **Code** | `whtr` at `:121`, `obese`/`central` at `:201-202`, `group` at `:203-208` |

|  | WHtR < 0.6 | WHtR ≥ 0.6 |
|---|---|---|
| **Obese** | **I** (391) | **II** (4,585) |
| **Non-obese** | **III** (787) | **IV** (608) |

**N: 6,374 → 6,374** (nobody lost; BMI and waist are already required by the FLI step)

> **Sanity check that this is right.** Our per-group BMI medians are
> **30.9 / 35.2 / 27.6 / 28.8** — identical to all four published values. That is strong
> evidence the group construction matches, independent of the N gap.

> **Decision — `WHtR = BMXWAIST / BMXHT`, both in cm.** A ratio of two lengths, so the
> units cancel and there is nothing to convert. Five people sit exactly on 0.6 and are
> classified as high central adiposity, matching `≥`.

> ⚠ **Decision — the Asian cut-point cannot be applied to a third of the cohort.**
> `asian` is derived from `RIDRETH3 == 6`, and **`RIDRETH3` does not exist in 2007-08 or
> 2009-10**. Line `:117` then recodes the resulting `NA` to 0, i.e. *not Asian*, for
> **2,322 of 6,371 rows (36%)**. This is not hypothetical: where the variable does exist,
> the Asian rule moves **121 of 250** Asian participants from the non-obese arm to the
> obese arm.
>
> **Why the fallback is nevertheless bounded.** In 2007-2010 the only usable ethnicity
> variable is `RIDRETH1`, whose category 5 is "Other Race — Including Multi-Racial", which
> *contains* Asians but cannot isolate them. Just 71 cohort members fall in it, and only
> **17** of those have BMI in [25, 30) — the window where the Asian rule would change
> anything (11 now in group III, 6 in group IV). So at most 17 of 6,371 are misgrouped.
>
> **Say it out loud in your write-up.** The paper states one rule for 2007-2018; the data
> can only support it for 2011-2018. A small consequence is still an undocumented
> deviation, and "we checked, and it is bounded at 17" is a much better sentence than
> silence.

> **On the paper's own table headers.** Table 1 and Table 2 label the columns
> `BMI≥25 kg/m²` / `BMI<25 kg/m²`, contradicting the Methods text. The Methods are right
> and the headers are a typo: the paper's own group III and IV BMI medians (27.6 and
> 28.8) are impossible under a 25 cut. Coding to 30 reproduces them exactly; coding to 25
> does not. **Finding an internal contradiction like this, and resolving it against the
> data rather than picking one, is exactly what M2 asks for.**

---

## Step 6 — Covariates for Table 1 and the Cox models

> **Paper:** "The definitions of comorbidities in the NHANES study have been previously
> described." — and that is the entire specification.

**Code:** `R/02_build_analytic.R:216-244`.

| Derived | Component → variables | Rule |
|---|---|---|
| `htn` | `BPQ` → `BPQ020`; `BPX` → `BPXSY*` `BPXDI*` | self-report **or** SBP ≥ 140 **or** DBP ≥ 90 |
| `t2dm` | `DIQ` → `DIQ010`; `GHB` → `LBXGH` | self-report **or** HbA1c ≥ 6.5 |
| `dyslip` | `BPQ` → `BPQ080` `BPQ100D`; `TRIGLY` → `LBDLDL` | self-report **or** lipid meds **or** LDL ≥ 130 |
| `ckd` | `BIOPRO` → `LBXSCR`; `ALB_CR` → `URDACT` `URXUMA` `URXUCR` | eGFR < 60 (CKD-EPI 2021, race-free) **or** ACR ≥ 30 |
| `mi` | `MCQ` → `MCQ160E` `MCQ160C` | heart attack **or** coronary heart disease |
| `stroke` `hf` `copd` `cancer` | `MCQ` → `MCQ160F` `MCQ160B` `MCQ160O` `MCQ220` | self-report |
| `pir_cat` | `DEMO` → `INDFMPIR` | < 1 Low · 1–4 Middle · > 4 High |
| `current_smoke` | `SMQ` → `SMQ020` `SMQ040` | current smoker **among ever-smokers** |
| `sedentary_min` | `PAQ` → `PAD680` | minutes, with `7777`/`9999` stripped |

> **Decision — composites, not pure self-report.** Self-report alone badly under-counts
> hypertension, diabetes and dyslipidaemia relative to the paper's Table 1. The paper
> cites two prior studies instead of stating its definitions, so we could not copy them.

> ⚠ **Be honest about what "calibrated" means.** The comment at `:212` says these
> definitions are "calibrated to reproduce the paper's Table 1 prevalences." That is
> fitting a definition to a target number, which is circular, and it is why HTN, T2DM,
> dyslipidaemia and CKD still sit 1–3 points off. **Do not present a calibrated
> definition as a reproduction of the paper's definition.** Present it as: the paper did
> not specify, we chose X, here is the residual gap.

> **Decision — `NA` becomes "does not have it".** The `cf()` helper at `:215` maps
> missing to `FALSE` inside every composite. Combined with the cycle gaps from Step 0
> (`MCQ160O` in H–J only, `DIQ070` absent in E), this means some prevalences carry a
> different denominator from the rest of the row. The COPD figure is the clearest case.

> **`current_smoke` has a denominator you must state.** It is defined only among
> ever-smokers, so "40.6% current smoking" means 40.6% *of ever-smokers*, not of the
> cohort. That is what reproduces the paper's number — but it also makes the variable
> `NA` for never-smokers, which silently shrinks the complete-case N of Cox Model 2.

> **eGFR is CKD-EPI 2021, verified.** Constants at `:229-231` (142, κ 0.7/0.9,
> α −0.241/−0.302, exponent −1.200, 0.9938^age, ×1.012 female) match the published
> race-free equation; recomputing by hand agrees to two decimals. Note the epidemiology
> anyway: **one creatinine and one ACR cannot establish *chronic* kidney disease**, which
> needs ≥ 3 months. Every NHANES "CKD" prevalence in the literature carries this caveat.

---

## Step 7 — Linking the outcome

> **Paper:** "Mortality status was determined through linkage with the National Death
> Index, with follow-up censored on 31 December 2019, and cause of death classified using
> ICD-10 codes."

The outcome is **not in NHANES**. It is six fixed-width `.dat` files, parsed at
`R/02_build_analytic.R:253-266` and joined by `SEQN`.

| Field | Columns | Used for |
|---|---|---|
| `SEQN` | 1–6 | the join key |
| `ELIGSTAT` | 15 | 1 = eligible for linkage |
| `MORTSTAT` | 16 | 0 = alive at censoring, 1 = dead |
| `UCOD_LEADING` | 17–19 | leading cause recode (`001` diseases of heart … `005` cerebrovascular) |
| `PERMTH_INT` | 43–45 | person-months from **interview** |
| `PERMTH_EXM` | 46–48 | person-months from **MEC exam** |

**N: 6,374 → 6,371** (3 dropped: not linkage-eligible, or no follow-up time)

> **Decision — `PERMTH_EXM` is the clock.** `time_yr = permth_exm / 12` (`:272`).
> **Why:** the exposure (BMI, waist, the labs behind FLI) is measured at the MEC exam,
> not at the household interview, so follow-up should start when the exposure was
> measured. The paper does not say which it used. For the record: `PERMTH_EXM` gives
> mean follow-up 6.76 (SD 3.49) years and `PERMTH_INT` gives 6.83 (3.49), against the
> paper's 6.9 (3.5) — neither reproduces it exactly.

> **Verify the column positions before you trust anything.** A one-column offset here
> corrupts every downstream result silently. The check: after parsing, `ELIGSTAT` should
> be in {1, 2, 3}, `MORTSTAT` in {0, 1}, `UCOD_LEADING` in 1–10, `PERMTH_EXM` non-negative,
> and `SEQN` inside the cycle's known range. All five hold here.

> ⚠ **Decision — and a live inconsistency in this repository.** The paper's secondary
> outcome is cardiovascular mortality. `cv_death` at `:273` is
> `ucod_leading %in% c(1, 5)` — heart **plus** cerebrovascular — which gives **185**
> deaths. But the paper reports **158**, `README.md` says "diseases-of-heart", and
> `reproduction_report.md` finding #3 says heart-only is the definition that matches.
> `R/04_table2_cox.R:42` quietly defines its own `cv_heart` and uses that, so the
> published Table 2 is correct (1 / 112 / 19 / 26 by group).
>
> **The saved `masld_analytic.rds` therefore ships a `cv_death` column that three other
> documents contradict.** If you read the analytic file and use `cv_death`, you will get
> 185 CV deaths and disagree with every table in this repository. Use
> `mortstat == 1 & ucod_leading == 1` until this is fixed.

---

## Step 8 — Save, and count what you lost

`R/02_build_analytic.R:314-321` applies the chain and `:362-363` writes both files.

```r
s0 <- dat                                                     # 59,842
s1 <- filter(s0, age >= 18)                                   # 36,580   ELIGIBILITY
s2 <- filter(s1, !is.na(fli))                                 # 14,989   DESIGN + MISSINGNESS
s3 <- filter(s2, steatosis == 1)                              #  6,376   TARGET POPULATION
s4 <- filter(s3, masld == 1)                                  #  6,374   TARGET POPULATION
s5 <- filter(s4, !is.na(group))                               #  6,374   MISSINGNESS
s6 <- filter(s5, eligstat == 1, !is.na(mortstat), !is.na(time_yr))  # 6,371  OUTCOME
s7 <- if (APPLY_ALCOHOL_EXCL) filter(s6, sig_alcohol == 0) else s6  # 6,371  (switch)
```

Two files are written: `data/derived/masld_analytic.rds` (the 6,371-row cohort) and
`data/derived/merged_all.rds` (all 59,842 rows, pre-filter, so you can re-derive any step
without re-reading the `.xpt` files). The typed funnel — both row sets, every step
labelled — goes to `logs/sample_funnel.csv`.

> **Every funnel row carries a type, and the types are not interchangeable.**
> ELIGIBILITY · DESIGN · MISSINGNESS · TARGET POPULATION · OUTCOME ASCERTAINMENT.
> A funnel shows N falling; it does not show *why*, and the remedy differs for each. The
> 21,618 people outside the fasting subsample are a DESIGN fact answered by a weight; the
> 792 with a missing input are MISSINGNESS answered by P5; the people without steatosis
> are simply not who the paper is about. Summing them into one "attrition" number is the
> most common error in a first P1, and it is wrong three different ways at once.

---

## The decisions ledger

Every judgment call above, in one place. ⚠ marks a place where we may genuinely differ
from the paper.

| # | Decision | Why | Cost |
|---|---|---|---|
| 1 | ⚠ Age `>= 18`, though the paper writes `> 18` | consistency with the reported mean age | 70 rows; best single explanation of the N gap |
| 2 | Keep both the full file (6,371) and the locked domain (6,048) | paper reports no weights → 6,371 reproduces it; only 6,048 supports a design-aware estimate | 323 rows differ; both are logged |
| 3 | Fasting subsample typed as DESIGN, not missingness | NHANES sampled it deliberately and supplies `WTSAF2YR` | none — it changes the *interpretation*, not the N |
| 4 | FLI transcribed verbatim; no unit conversion | NHANES already supplies mg/dL, U/L, cm, kg/m² | none |
| 5 | No reserved-code stripping in `LBXTR`/`LBXSGTSI` | `77` there is a measurement, not a refusal | would have deleted real values |
| 6 | Strip `777`/`999` in `ALQ130`/`ALQ120Q` | there they *are* refusals | 9 refusals saved from becoming heavy drinkers |
| 7 | Alcohol = frequency × quantity, not `ALQ130` | `ALQ130` is per drinking-day, not per day | using `ALQ130` alone over-excludes ~2,000 |
| 8 | ⚠ Alcohol exclusion switched **off** | applying it gives 5,944 vs the paper's 6,300 | 427 rows if switched on; report §6's stated reason is wrong |
| 9 | Glucose threshold 100 mg/dL for 5.6 mmol/L | the conventional equivalent | 212 people in the gap, zero reclassified |
| 10 | Missing criterion counts as absent (`na.rm = TRUE`) | conservative; can only fail to admit | negligible — 6,329/6,371 already meet criterion (i) |
| 11 | NHANES BP averaging protocol, not `rowMeans` | documented CDC rule; two prior versions were wrong | changed SBP/DBP for 5,523 people; HRs moved in the 3rd s.f. |
| 12 | ⚠ Asian BMI cut applied only where `RIDRETH3` exists | it does not exist in E or F | ≤ 17 of 6,371 possibly misgrouped |
| 13 | Composite comorbidity definitions | paper cites prior work instead of specifying | 1–3 pt residual gaps; the calibration is circular |
| 14 | `current_smoke` denominator = ever-smokers | reproduces the paper's 40.6% | `NA` for never-smokers shrinks Model 2's N |
| 15 | `PERMTH_EXM` as the clock | exposure is measured at the MEC exam | 6.76 y vs the paper's 6.9 y |
| 16 | ⚠ `cv_death` = heart + cerebrovascular in the saved file | — | **185 vs the paper's 158; three other documents disagree with it** |
| 17 | Unweighted throughout | the paper reports no weights, strata or PSUs; reproducing ≠ endorsing | the design-aware estimate is P4's job |

---

## How to use this page in P1

1. **Work the loop, in this order:** paper sentence → operational concept → NHANES
   variable → component → *that cycle's* codebook → raw `.xpt` → your code → cohort
   consequence. Every step above is one turn of it.
2. **For each of your own steps, write the four lines** this page writes: the quoted
   sentence, the component and variables, the decision and its reason, the N afterwards.
3. **Type every funnel row.** If you cannot name a row's type, you do not yet know what
   the row means.
4. **Two of the decisions above are still open** (#1 and #8). Reproducing a number is
   not the goal; being able to say *why* your number differs is. An unexplained exact
   match is worth less than a discrepancy you can account for.

---

*Numbers on this page were measured against `data/raw/` and `data/derived/` on the
2019 linked-mortality release, not copied from the other documents. Regenerate the
variable-level detail with `Rscript R/07_variable_map.R`; regenerate the cohort with
`source("R/run_all.R")`.*
