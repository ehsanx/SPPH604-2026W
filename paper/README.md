# Papers

Two papers live here, under **different licences**. Read this before re-using either.

---

## 1. The demonstration paper — CC BY-**NC**

The paper the whole course replicates, reproduced in [`../reproduction/`](../reproduction/)
and worked through in [`../examples/`](../examples/).

> Kueh MTW, Chew NWS, et al. Body weight categories and fat distribution in relation to
> all-cause mortality among adults with metabolic dysfunction-associated steatotic liver
> disease. ***BMJ Open*** 2026;16:e113719.
> doi:[10.1136/bmjopen-2025-113719](https://doi.org/10.1136/bmjopen-2025-113719)

> © Author(s) (or their employer(s)) 2026.
> **Re-use permitted under CC BY-NC. No commercial re-use.**
> Published by BMJ Group.

`e113719.full.pdf` is redistributed under that licence. **CC BY-NC is not CC BY** — the
repository's own CC BY licence does not extend to this file. Full terms:
<https://creativecommons.org/licenses/by-nc/4.0/>

**Its peer review history is not included here**, because it carries no stated licence —
and it is worth reading, since seeing how professional reviewers critiqued this paper is
the closest thing to a worked example of the M2 genre. To get it:

1. Open <https://doi.org/10.1136/bmjopen-2025-113719>
2. Find **"Peer review history"** with the supplementary material
3. Download the PDF from there

### What we reproduce from it

| | Published | Our reproduction |
|---|---|---|
| Analytic N | ~6,300 | 6,371 |
| Groups I / II / III / IV | 386 / 4,541 / 769 / 604 | 391 / 4,585 / 787 / 608 |
| Deaths | 585 | 586 |
| Group IV HR, unadjusted → adjusted | 15.13 → 2.89 | 15.14 → 2.91 |

The gap is documented rather than tuned away — see
[`../examples/M1_replication/`](../examples/M1_replication/).

---

## 2. A second NHANES paper — CC BY

A fully reproducible NHANES survival analysis with public code, included as a **worked
example of design-aware practice**.

> Karim ME, Hossain MB, Zheng C. Examining the Role of Race/Ethnicity and Sex in Modifying
> the Association Between Early Smoking Initiation and Mortality: A 20-Year NHANES
> Analysis. ***AJPM Focus*** 2025;4(2):100282.
> doi:[10.1016/j.focus.2024.100282](https://doi.org/10.1016/j.focus.2024.100282)

> © 2024 The Author(s). Published by Elsevier Inc.
> **Open access under CC BY.** <https://creativecommons.org/licenses/by/4.0/>

Files: `PIIS2773065424001007.pdf` (article), `mmc1.pdf` (supplementary content).

**Code, analytic data and outputs are archived at Zenodo:**
<https://doi.org/10.5281/zenodo.20764350>

### Why it is here

Read its **Methods** alongside
[`../practice/P4_design_aware_estimate.md`](../practice/P4_design_aware_estimate.md). It
states plainly what P4 asks you to do, and what the M2 model critique presses another
group about:

> "The design was created on the entire data using the design features: interview weights,
> clusters, and strata. **Subsequently, the authors subset the design** to focus on
> eligible patients to estimate variances using the Taylor series linearization method."

Subsetting the *design object* rather than filtering the data before `svydesign()` is the
difference between correct and too-narrow confidence intervals. Most papers never say
which they did. This one does, and the Zenodo archive lets you check it.

It is also a useful contrast on missing data: the authors **decline** to impute, and say
why — a reliable imputation model could not be built from the available covariates. P5
asks for *one justified* missing-data analysis. A reasoned refusal is a justification;
"under 10% missing, so complete-case is fine" is not.

---

## Third-party data

NHANES microdata and NCHS linked mortality files are **US government public-domain data**,
not covered by either licence above, and not redistributed here.
[`../reproduction/R/01_download.R`](../reproduction/R/) fetches them from CDC.
