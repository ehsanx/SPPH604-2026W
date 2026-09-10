# Week 3 Lecture Plan — Building the Analytic Cohort: Case Definitions, Eligibility, and the Funnel

Duration: ~2.5 h (Tue, before the Thu lab)

## Learning objectives
- Distinguish a **target population**, a **source population**, and an **analytic cohort**, and locate each in a published study.
- Reconstruct the MASLD case definition from its parts: non-invasive **steatosis** (Fatty Liver Index ≥ 60) **plus ≥ 1 cardiometabolic criterion**.
- Turn a prose eligibility paragraph into an explicit, reproducible **inclusion/exclusion algorithm**, and see how one ambiguous sentence can move N by thousands.
- Build and report an **eligibility funnel** with an N at every step, and defend it as a design choice.
- State why you **never tune the cohort to reproduce the paper's N**, and how peer review should interrogate eligibility.

## Continuity
- **Last week (Wk 2 → L1):** we wrangled raw NHANES files — merged cycles, harmonized variable names, handled the messy joins. We now have a clean, person-level frame but *not yet* a study cohort.
- **This week:** we convert that frame into the *analytic cohort* the MASLD paper analyzed — the step that decides who is even in the study. **M0 closes today:** the memo is due at 12 PM, and the paper locks at that deadline.
- **Sets up:** L2 (build the analytic dataset) and **P1** (your own eligibility funnel for your locked paper).

## Slide 1 — Where we are in the project (recap + M0 closing)
- Term arc: **Replicate → Interrogate → Improve → Defend**; we are still in *Replicate*.
- L1 gave us a clean merged NHANES frame; today we decide *who counts as a subject*.
- Announce the **M0 deadline**: the memo is due at 12 PM today, and papers lock at that deadline.
- MASLD hook: the Kueh paper's whole story rides on 4 phenotype groups drawn from *one* cohort; get the cohort wrong and every downstream number is wrong.
- (4 min)

## Slide 2 — Today's roadmap and the one big idea
- Case definition → eligibility → exclusions → funnel → feasibility.
- Big idea: **eligibility decisions are load-bearing** — they are analysis choices, not bookkeeping.
- Framing question for the room: "If two teams read the same methods paragraph, would they build the same cohort?"
- (3 min)

## Slide 3 — Target vs source vs analytic population
- Target = adults with MASLD (who we want to speak about); source = NHANES 2007–2018 respondents; analytic = those who survive all inclusion/exclusion filters *and* have measurable exposure/outcome.
- Each narrowing step trades **generalizability** for **measurability**.
- Every drop is a potential selection bias, not just a smaller N.
- MASLD hook: NHANES samples the US civilian population, and the analytic cohort is the MASLD subset of the **designed fasting subsample**. Foreshadow the typed funnel: every step down has a *kind*, and only some kinds are missing data.
- (10 min)

## Slide 4 — The MASLD case definition, unpacked
- MASLD (formerly NAFLD) = **hepatic steatosis + metabolic dysfunction**, with other causes not dominant.
- Two ingredients we must operationalize in data: (1) steatosis, (2) ≥ 1 cardiometabolic criterion.
- No biopsy, no imaging in NHANES → steatosis must be ascertained **non-invasively**.
- MASLD hook: the paper uses the **Fatty Liver Index (FLI)** as its steatosis proxy — a modeling choice we will scrutinize all term.
- (12 min)

## Slide 5 — Ascertaining steatosis: the Fatty Liver Index
- FLI is a published logistic score predicting fatty liver from routine measures.
- Inputs: **triglycerides, BMI, GGT, waist circumference** — remember these four; only triglycerides needs a fasting lab (GGT is MEC-wide standard biochemistry, BMI and waist are anthropometry), and that single fasting input binds the whole index.
- Output: 0–100 score; the paper applies the conventional **FLI ≥ 60** rule-in cut.
- MASLD hook: note *now* that FLI already contains **BMI and waist** — the same anthropometry used later to define the phenotype groups. Flag it; we return to it as the "circularity" threat at M1.
- (12 min)

## Slide 6 — The FLI formula, worked
- Show the formula shape: a logistic function of `0.953·ln(TG) + 0.139·BMI + 0.718·ln(GGT) + 0.053·waist − 15.745`, mapped to 0–100.
- Walk one hypothetical subject through it live; show that TG and GGT enter on the log scale.
- Emphasize: a *cut* on a continuous score creates a hard boundary — small measurement error near 60 flips case status.
- MASLD hook: FLI ≥ 60 is both the **disease gate** and, because it needs fasting TG, the **reason the cohort shrinks** to the fasting subsample.
- (10 min)

## Slide 7 — The cardiometabolic criteria (the "M" in MASLD)
- Require **≥ 1** of: elevated BMI/waist, hyperglycemia/diabetes, hypertension, dyslipidemia (low HDL / high TG or treatment).
- Each is itself an operationalization: which threshold, treated vs untreated, which NHANES variable.
- Document each criterion's variable and cut in a codebook *before* coding.
- MASLD hook: in this cohort ≥ 1 criterion is almost always met, so it rarely changes N — but you still must report it, because *your* paper's population may differ.
- (10 min)

## Slide 8 — Eligibility and exclusions are design, not chores
- Typical filters: adults (age ≥ 18/20), non-pregnant, valid mortality linkage, non-missing key measures, and disease-specific exclusions.
- Each filter answers a scientific question ("who is this study about?"), so each needs a stated rationale.
- Rule: write exclusions as **executable logic** with a comment citing the paper's sentence.
- MASLD hook: the paper's exclusions include competing liver-disease causes and — critically — **heavy alcohol use**, our worked example next.
- (10 min)

## Slide 9 — Worked example: the alcohol ambiguity (one sentence, three cohorts)
- The paper states an alcohol exclusion in a *single sentence* that can be read three ways (which drinks question, which threshold, missing = drop vs keep).
- Coded three defensible ways, the same sentence yields **N ≈ 4,308 / 5,944 / 6,371** — a swing of ~2,000 people.
- Lesson: prose is lossy; the ambiguity is invisible until you try to *run* it.
- MASLD hook: this is exactly why the reported N never quite pins down — and why we must publish our own coding decision explicitly rather than guess the authors' intent.
- (15 min)

## Slide 10 — BREAK (10 min)
- Restart prompt on screen: "Which of the three alcohol codings would *you* defend, and why?"

## Slide 11 — The eligibility funnel: report N at every step
- Build a top-to-bottom funnel: source N → adults → MASLD (FLI ≥ 60 + criterion) → alcohol/other exclusions → mortality linkage → **analytic N**.
- Report the count removed **and remaining** at *each* line; a CONSORT-style diagram is the deliverable.
- The funnel is a reproducibility contract: a reader can re-derive your N.
- MASLD hook: the paper reports **N ≈ 6,300**, phenotype groups **386 / 4,541 / 769 / 604** and **585 all-cause deaths**; our reproduction's **full analytic file** is **6,371**, with groups **391 / 4,585 / 787 / 608** and **586 deaths**, and its **locked domain** — the rows carrying a valid fasting weight — is **6,048**. Getting 6,371 rather than the paper's number is not a failure: it is the finding. These are numbers only interpretable *with* the funnel that produced them.
- (14 min)

## Slide 12 — Why you never tune the cohort to hit the paper's N
- Temptation: quietly flip a threshold until your N matches the abstract. This is **fitting the process to the answer** — a garden of forking paths.
- Correct stance: pick the *most defensible* coding a priori, report your N, and *explain* any gap.
- A matched N with hidden tuning is worse than an honest mismatch you can account for.
- MASLD hook: because the alcohol sentence alone spans ~2,000 people, "matching" the paper's N proves nothing about correctness — it may just mean you guessed their ambiguity.
- (10 min)

## Slide 13 — Peer-review principles for eligibility
- Reviewer checklist: Is the case definition operational? Is every exclusion executable? Does the funnel's arithmetic close? Is the analytic N stated and reproducible?
- Distinguish an *honest, documented* choice from an *undocumented, load-bearing* one.
- Charity + rigor: assume competence, but demand the numbers reconcile.
- MASLD hook: apply the checklist to the alcohol sentence and the **mislabeled BMI header** (Table says "< 25" where the cut is actually 30) — small text discrepancies, real consequences for a reader rebuilding the cohort.
- (12 min)

## Slide 14 — Feasibility: can you even measure the exposure?
- FLI needs fasting labs, so only the **fasting subsample** qualifies. Within that subsample FLI is computable for **94.7%** of adults — the 5.3% who lack it are genuine item nonresponse.
- The much larger reduction from all adults to the fasting subsample is **designed subsampling**, handled by `WTSAF2YR`, not a selection bias to be modelled away.
- Feasibility check *before* committing: is the exposure computable for enough of your target population?
- MASLD hook: make the funnel **typed** — DESIGN / ELIGIBILITY / TARGET POPULATION / OUTCOME ASCERTAINMENT / MISSINGNESS. The single most common error is calling every downward step "attrition".
- (10 min)

## Slide 15 — From paper to protocol (recap, M0 closing)
- We converted a prose methods section into an explicit cohort algorithm: definition → exclusions → funnel → analytic N.
- Every decision is documented, defensible, and re-runnable — the standard your own P1 must meet.
- Once M0 closes at 12 PM today, your paper's eligibility paragraph is *your* specification to decode.
- (6 min)

## Slide 16 — Bridge to today's lab (L2 / P1)
- **In L2 (Thu):** using EpiMethods (ehsanx.github.io/EpiMethods), you build the MASLD analytic dataset from the L1 frame — code the FLI, apply FLI ≥ 60 and ≥ 1 cardiometabolic criterion, implement one defensible alcohol coding, and output a **funnel with N at every step**. Do not aim the funnel at a number: the paper reports ~6,300, our full analytic file lands on 6,371, and what you report is wherever your documented steps take you.
- **P1 (your increment):** repeat the funnel for *your own* locked paper — write each inclusion/exclusion as executable logic, report N at each step, and flag one ambiguous eligibility sentence you had to adjudicate.
- Deliverable stance: a documented N you can defend beats a matched N you cannot. P1 is optional and ungraded — no separate deadline and nothing to submit; keep the funnel and its one hardest judgment call in your group GitHub repo, and be ready to defend that call.
- (6 min)
