# Week 4 Lecture Plan — Variable roles; confounding & DAGs

Duration: ~2.5 h (Tue, before the Thu lab)

## Learning objectives
- Distinguish the four roles a covariate can play — confounder, mediator, collider, and simple risk marker — and state the adjustment rule for each.
- Draw a minimal DAG for the MASLD question and read a backdoor path off it.
- Explain why age is the dominant confounder here, using the ~40-vs-~62-year group age gap.
- Use Table 1 for what it can actually do — describe how the groups differ, expose sparse cells, positivity problems and coding errors, and raise questions worth investigating — rather than to identify confounders, and read a table critically enough to catch a mislabelled cut point.
- Interpret the crude→adjusted collapse of the Group IV hazard ratio without claiming which mechanism produced it, and read the "obesity paradox" as a structural question rather than a settled artefact.

## Continuity
- **Last week (Wk3 → L2/P1):** we locked the analytic cohort — eligibility, the FLI≥60 exposure filter, and the frozen N. M0 is now closed; your paper is locked.
- **This week:** with the cohort fixed, we ask what *distorts* the exposure–mortality contrast. We name variable roles, draw the DAG, and read Table 1 as a description of the groups that raises questions the causal argument then has to answer — the conceptual groundwork for adjusted models.
- **Sets up:** Thursday's L3 takes Table 1 → crude → adjusted estimates; P2 is your own Table 1 plus the reasoning for what you will and will not adjust for.

## Slide 1 — Where we are in the project
- Recap the arc: Replicate → Interrogate → Improve → Defend; we are entering *Interrogate*.
- M0 locked last week; the cohort and the four phenotype groups are now fixed inputs — the paper reports N ≈ 6,300, our full analytic file is 6,371.
- Today is purely conceptual scaffolding for adjustment — no new data steps.
- *MASLD hook:* the four groups are settled — the paper's counts are I 386 / II 4,541 / III 769 / IV 604 and ours are I 391 / II 4,585 / III 787 / IV 608; today asks whether their mortality contrast is *real or confounded*.
- ~8 min

## Slide 2 — The motivating puzzle
- Group IV (non-obese, high central adiposity) has the worst survival — but the number moves enormously with adjustment.
- Unadjusted all-cause HR ≈ 15.1; adjusted ≈ 2.9–3.3. Same data, one covariate set apart.
- Ask the room: what could make a hazard ratio shrink five-fold? Park answers; return at Slide 12.
- *MASLD hook:* this single collapse (≈15 → ≈3) is the spine of the whole lecture.
- ~8 min

## Slide 3 — Four roles a variable can play
- A covariate is not "a control" by default — its role depends on the causal structure, not on the regression.
- Taxonomy: **confounder** (common cause), **mediator** (on the path), **collider** (common effect), **risk marker** (predicts outcome, no exposure link).
- The role dictates the action: adjust confounders, *don't* adjust mediators or colliders.
- *MASLD hook:* age, cardiometabolic criteria, and the FLI filter each play *different* roles in this study — naming them is the task.
- ~12 min

## Slide 4 — Confounding: a common cause
- Definition: a variable that causes both exposure and outcome, opening a **backdoor path**.
- Signature: it causes both the exposure and the outcome, opening a backdoor path. Imbalance across exposure groups and outcome relevance tell you where to look; they do not establish the role. Whether adjusting it changes the estimate is not a test of confounding — adjusting a mediator changes the estimate too, and so does adjusting a collider. Non-collapsibility of the hazard ratio, a changed model specification, and a crude model fitted on more rows than the adjusted one all do the same.
- This is the one role where adjustment *removes* bias.
- *MASLD hook:* age raises central adiposity/phenotype membership *and* raises mortality — the textbook confounder here.
- ~10 min

## Slide 5 — Mediation: on the causal path
- Definition: exposure → mediator → outcome; the mediator transmits the effect.
- Adjusting a mediator removes part of the very effect you want — "over-adjustment."
- Contrast with confounding: same regression syntax, opposite consequence.
- *MASLD hook:* if central adiposity drives mortality *through* incident diabetes/CVD, controlling those downstream conditions would erase real effect — a mediation trap to flag.
- ~10 min

## Slide 6 — Collider bias: conditioning on a common effect
- Definition: exposure → C ← outcome (or their causes); C is a collider on that path.
- Conditioning on a collider — by adjustment *or by selection* — opens a spurious path.
- Selection into the sample is a form of conditioning: who gets measured matters.
- *MASLD hook:* the paper adjusts for T2DM, hypertension, CKD and prior MI. Ask the class which of those they can **justify** as confounders rather than merely observe to be prognostic — several could be descendants or intermediates under plausible causal structures, and the data do not settle their causal roles or temporal ordering. Adjusting for a variable does not establish its causal role.
- ~10 min

## Slide 7 — A minimal DAG for the MASLD question
- Draw live: Phenotype (exposure) → Mortality (outcome); Age → Phenotype and Age → Mortality (backdoor); Cardiometabolic factors as shared causes.
- Trace the open backdoor Age creates; show that adjusting Age blocks it.
- Show a mediator arrow (Phenotype → diabetes → Mortality) to mark what *not* to block.
- *MASLD hook:* one small hand-drawn DAG makes visible why age is adjusted and why downstream disease is not.
- ~12 min

## Slide 8 — Age: the dominant confounder
- Group mean ages differ sharply (roughly ~40 in the younger obese groups vs ~62 in the leaner high-central group).
- Non-obese high-central adults are, on average, *older* — and age alone predicts death.
- So a chunk of Group IV's raw excess mortality travels with age rather than with the phenotype label. Whether that makes age a *confounder* of this contrast depends on the research goal and on age's causal role — which is what the rest of today establishes, and what Wk2 deliberately left open.
- *MASLD hook:* the ~40-vs-~62 gap is the single largest driver of the crude HR ≈ 15.
- ~10 min

## Slide 9 — The phenotype definition (exposure construction)
- Two axes: obesity (BMI ≥ 30) × central adiposity (WHtR ≥ 0.6) → four groups (I–IV).
- Group IV = non-obese (BMI < 30) but high central adiposity — the "hidden risk" cell.
- The cut points are analyst choices; they determine who lands in the worst-survival group.
- *MASLD hook:* Group IV's definition is exactly why "non-obese" can still be high-risk — the paper's headline.
- ~10 min

## Slide 10 — Reading tables critically: the mislabelled cut
- The published Table headers print the BMI cut as "<25" when the actual analytic cut is 30.
- A reader trusting the header would misread the entire exposure; the *code*, not the label, is truth.
- Lesson: reconcile every table label against the methods and the derivation.
- *MASLD hook:* this is a real, reproducible label–Methods mismatch in Kueh 2026 — a live example of why replication catches what reading cannot.
- ~8 min

## Slide 11 — BREAK (10 min)
- Stretch; leave the DAG on the board for the second half.

## Slide 12 — What Table 1 can and cannot tell you
- Reframe Table 1: not decoration, but the description of how the groups actually differ — a *data* diagnostic, not a confounder detector.
- Read across the phenotype columns — age, sex, cardiometabolic markers — looking for sparse cells that cannot support a model, positivity problems (a covariate level with almost nobody in one group), impossible or miscoded values, and contrasts worth investigating.
- Imbalance does not nominate an adjustment set. A variable belongs in it because causal and temporal reasoning puts it there — a common cause of both exposure and outcome, measured before the exposure — and a badly imbalanced variable can still be a mediator, a collider, or beside the point. Justify the set from science, not from a stepwise algorithm or a scan of the table.
- *MASLD hook:* Table 1 reproduces closely (mean age ~51, BMI ~33.2); the age row across groups (~40 vs ~62) is the question the table hands you — whether age *confounds* this contrast is a claim about causal structure, argued on the Slide 7 DAG, not read off the row.
- ~14 min

## Slide 13 — Crude vs adjusted: the collapse explained
- Return to Slide 2: Group IV all-cause HR ≈ 15 crude → ≈ 3.3 after adjustment.
- Walk the mechanism, then stop: adjustment can remove confounding, but it can also remove real effect by conditioning on mediators, and it can introduce bias by conditioning on colliders. Attenuation is diagnostic evidence about what the covariates are doing — it is not evidence that the adjusted estimate is correct.
- Two further reasons the number can move without any confounding being removed: the hazard ratio is non-collapsible, so it shifts on adjustment even under a null, and a crude model fitted on more rows than the adjusted one differs for two reasons at once. Fit both on the same complete-case rows.
- Name the residual ≈3 for what it is: the remaining conditional association under this adjustment set. Not the phenotype's own signal, and not evidence that the phenotype matters beyond age.
- *MASLD hook:* the ≈15→≈3 move is what the paper's inherited adjustment set produces. Which of those explanations produced it is exactly what this analysis cannot settle — that is the threat you carry to M1, not a result.
- ~12 min

## Slide 14 — The "obesity paradox" as a structural question
- The paradox: obese patients sometimes look *protected* in crude comparisons.
- The candidate explanations are structural, not biological — confounding by age and severity, and selection into a sick-but-surviving sample. Naming a candidate is not the same as demonstrating one, and nothing in this design tells them apart.
- Group IV is where the naive reading gets tested, and the test has two halves. Descriptively, "leaner is safer" fails and the paper reports that accurately: Group IV has the poorest observed survival (19.5% died, against 9.6% in Group III). That claim follows.
- Comparatively, it does not follow. On the locked IV-vs-III contrast, fitted on the same complete-case rows, the adjusted hazard ratio is 1.06 (0.77–1.45) unweighted, and the paper's own Model 1 puts Groups III and IV almost on top of each other — an implied ratio of about 0.99. The ranking is a crude fact; conditioning does not sharpen it.
- *MASLD hook:* so the headline is not the paradox resolved — it is the paradox posed on the cell that holds body-mass category fixed. Wk6 re-runs that same contrast design-aware, giving 1.29 (0.90–1.86), and the interval still includes 1.
- ~10 min

## Slide 15 — What adjustment can and cannot fix
- Adjustment closes *measured* backdoor paths only; residual/unmeasured confounding remains.
- Over-adjustment (mediators) and collider/selection bias can *add* bias — more covariates is not always better.
- Preview: survey design (Wk6) and missing-FLI selection (Wk7) are biases adjustment alone won't fix.
- *MASLD hook:* even the adjusted ≈3 is provisional — later weeks stress-test it.
- ~8 min

## Slide 16 — Bridge to today's lab
- **L3 (Thursday):** in the EpiMethods OER environment, move from the frozen cohort to estimates — build Table 1 across the four phenotype groups, then fit crude and age-adjusted models to watch the Group IV HR fall from ≈15 toward ≈3.
- **Workflow:** build Table 1 to see the groups and to catch sparse cells, positivity problems and coding slips; then decide the adjustment set from causal and temporal reasoning — what precedes the exposure, what lies downstream of it — and record what you deliberately leave *out* (mediators, colliders). The table describes; the causal argument decides.
- **P2 (your paper):** produce your own Table 1 plus a written adjustment rationale — which variables you adjust, which you don't, and why — carrying forward into your M1 replication.
- *MASLD hook:* you will reproduce, with your own hands, the crude→adjusted collapse we drew today.
- ~6 min
