# M1 cover note

*M1 is submitted as **two** files: `M1_replication_deck.pdf` and a zip archive of the
group's GitHub repository. This cover note belongs on the **final slide of the deck**, and
the same text ships as `COVER-NOTE.md` in the **root of the repository zip**. It is split
out here only so the exemplar's disclosures can be read on their own, and `M1_code.html`
ships with the exemplar for the same reason — neither is a third deliverable.*

The syllabus requires a cover note on M0, M1, M2 and M4 containing an **AI Use
Statement**, a **per-member contribution note**, and any **external-feedback
disclosure**. Two further disclosures belong here whenever they apply: **code derived
from the original authors**, and **cross-group conversations that shaped an analytic
decision**. This note is short on purpose — it is a disclosure, not an essay.

---

## 1. Derivation from the original authors' code

The article's data availability statement points to the public NHANES repository and
does **not** link analysis code, and we found no public repository for it. **No part of
our pipeline is derived from the authors' code.** The cohort definition, the FLI
formula, the MASLD cardiometabolic criteria and the phenotype cut-points are
implemented from the Methods text, and every place where that text is ambiguous is
logged as a discrepancy on Slide 2 rather than resolved silently.

Reused public code is attributed in the repository `README`: the Bedogni FLI
coefficients, the CKD-EPI 2021 eGFR equation, and the survey-weighted Cox and
domain-analysis idioms from the `survey` package documentation.

## 2. AI Use Statement

AI assistance was used, and it is disclosed here at the level the syllabus asks for —
which code was AI-generated and which was human-audited.

| Component | AI-generated | Human-audited |
|---|---|---|
| NHANES download and merge (`01_download.R`, `02_build_analytic.R`) | Drafted with AI | Every variable derivation checked against the NHANES codebook |
| FLI, MASLD criteria, phenotype groups | Drafted with AI | Checked line by line against the Methods and against Bedogni (2006) |
| P1–P5 increment code | Drafted with AI | Re-executed; every reported figure regenerated from the executed file |
| `M1_code.qmd` assembly and checks | Drafted with AI | Check logic reviewed; deliberately written to fail rather than warn |
| Slide text and interpretation | **Human-owned interpretation; AI-assisted drafting and wording** | Every sentence read, edited and verified; the judgments on Slides 7–8 are ours |

Two things we want on the record, because they are the point of the auditing
requirement:

- **AI-written code was wrong in a way that mattered, and the audit caught it.** The
  alcohol-exclusion rule applied `ALQ130 > 2` to raw values, which silently counted
  NHANES reserved codes 777 ("refused") and 999 ("don't know") as drink counts. That
  reclassified nine refusals as heavy drinkers and moved the excluded count from 2,063
  to 2,072. It was found because the deck is assembled from the executed code rather
  than typed beside it; it is fixed, and the fix is visible in `P1_code.qmd`.
- **We do not offer "the AI made a mistake" for anything on these slides.** Under the
  No-Excuse Clause, every figure here is ours to defend at M3.

## 3. Per-member contribution note

*This is the Instructor exemplar, so it has no group members. A real submission
replaces this section with one line per member, in the syllabus's format:*

> *AB: cohort reconstruction, survey weighting code. CD: DAG, confounder set, Table 1.
> EF: slides, missing-data sensitivity analysis.*

*For the exemplar itself: written by the course instructor, with the AI assistance
disclosed in section 2.*

## 4. External feedback

**Yes — external feedback was received, and it changed the submission.** This exemplar
was put through several rounds of adversarial review by independent large language
models, which were given the artifacts and asked to find errors. That review is the
reason for, among other things: the split of the cohort funnel into typed steps; the
withdrawal of a claim that the crude sex difference was "confounding, not true
modification"; the separation of the full analytic file (6,371) from the locked domain

(6,048); and the rebuild of `M1_code.qmd` as an assembly notebook after a reviewer
noticed the deck quoted a design-aware interaction that no increment computed.

**Being precise about what that review contributed.** The adversarial-review models
provided critique and, in some cases, **proposed wording that informed or was
incorporated into the final text**. The instructor selected, edited, verified, and takes
responsibility for the final wording and the scientific judgments. Separate AI coding
assistance is disclosed in §2. No external contributor ran an analysis or altered code
directly.

Under the External Feedback Policy a student group doing this would need prior instructor
approval, and the policy's "comments and suggestions only" limit is stricter than what
happened here — which is exactly why the disclosure says so plainly rather than claiming
the narrower thing.

## 5. Cross-group conversation and review

Not applicable to the exemplar. A real submission states here whether a conversation with
another group materially shaped an analytic decision, and names the group. From M2 onward
it also states whether reviewing another group's M1 influenced a change — the change being
the group's own, justified and implemented on its own paper. A reviewed group's code,
text, figures, output and distinctive implementation are never carried across. The
syllabus is explicit that disclosing the influence is a strength rather than a confession.

---

## Reproducibility statement

`M1_code.qmd` does not re-implement P1–P5. Each increment writes a result object to
`../_results/` containing named, already-formatted **facts**; M1 reads those, adds the
facts from its own two analyses, and writes `M1.json` and `paper.json`.

**No number is typed onto the slides.** The deck cites facts by name —
`{{ P4.facts.w_m1_iii }}` — and the build substitutes them. An unresolved or misspelled
reference fails the build, as does a stray typed decimal in the deck source. Figures
attributed to the article are transcribed once, in the notebook, each with the string
that must be found in the paper's PDF; a failed check fails the render.

What this guarantees is that every number shown was produced by the named field of a
named result object. It does **not** guarantee that the surrounding prose describes that
number correctly — numeric drift is prevented structurally, interpretive drift is not.

The two analyses M1 runs itself are stated in the notebook: the replication table, and
the design-aware interaction that P3 explicitly deferred to M1.
