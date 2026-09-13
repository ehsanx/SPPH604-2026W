# SPPH 604 — Application of Advanced Epidemiological Methods

**UBC School of Population and Public Health · Term 1, 2026W**

> **Student preview — 2026W.** This repository is available now so you can see the
> course structure, materials, and submission formats. Minor wording and Canvas
> configuration updates may still be made before this version is declared final.

All course materials live here. **Canvas carries submissions and grading**, and the things
the syllabus points there for: the rubric grids, the worked AI-use example, Zoom links, and
anything posted in the weekly Modules.

**Prefer a guided view?** Use the
[SPPH 604 student guide](https://ehsanx.github.io/SPPH604-2026W/) for a
week-by-week map, assignment overview, repository map, and searchable file catalogue.
This README remains the compact overview of the repository itself.

---

## How the course works

You pick one recent, open-data paper in Week 3 and carry it all term:

> **Orient → Lock → Build → Replicate → Review → Improve & Defend → Reanalyse**

You form a group, lock one feasible paper, build the analysis through P1–P5, assemble the
first complete argument at M1, review another group's work at M2, improve and defend your
own analysis at M3, and carry the best-defended version into the final M4 reanalysis.

| | What | Weight |
|---|---|:--:|
| **M0** | Feasibility memo — lock your paper | pass/fail |
| **L1–L6** | Weekly labs on fixed teaching data | 10% |
| **P1–P5** | Weekly increments on *your* paper — optional, ungraded, no deadline, nothing to submit | — |
| **M1** | Your five increments compiled + which threat most endangers the paper (deck + repository zip) | 30% |
| **M2** | A live critique of **another group's M1** | 15% |
| **M3** | Individual oral defense: improve and defend the analysis; changes may be reviewer-prompted or self-initiated | 15% |
| **M4** | Reanalysis letter + reproducible repository | 30% |

The full rules are in the [syllabus](syllabus/SPPH604-syllabus-2026W.pdf).

## Where things are

| Folder | What's in it |
|---|---|
| [`syllabus/`](https://ehsanx.github.io/SPPH604-2026W/syllabus/SPPH604-syllabus-2026W.pdf) | The syllabus. Authoritative on deadlines, weights and policy. |
| [`labs/`](labs/) | L0 setup (self-study) and the L1–L6 handouts. Labs run Thursdays 10–12, SPPH 143, Weeks 2–7. |
| [`practice/`](https://ehsanx.github.io/SPPH604-2026W/practice/README.html) | P1–P5 handouts — the same methods applied to your own paper. |
| [`milestones/`](milestones/) | M0–M4 assignment briefs — what each milestone asks for. |
| [`examples/`](examples/) | **Worked model answers** for P1–P5 and M0–M4, on the demonstration paper. |
| [`reproduction/`](reproduction/) | The full R pipeline behind the demonstration paper. |
| [`lectures/`](lectures/) | Week 1–7 plans and slide decks. |
| [`paper/`](paper/) | Two papers under different licences — the demonstration paper (CC BY-NC) and a second NHANES paper (CC BY) read alongside P4 — and their attribution. |
| [`index.md`](index.md) | **Index of every document in the repository.** |

## Start here

1. Open the [student guide](https://ehsanx.github.io/SPPH604-2026W/) if you want the
   easiest way to navigate the course.
2. Read the [syllabus](syllabus/SPPH604-syllabus-2026W.pdf) — it is authoritative on
   deadlines, weights, grading, and policy.
3. Use the [weekly map](https://ehsanx.github.io/SPPH604-2026W/weekly.html) to see which
   lecture, lab, project increment, and milestone belong together.
4. Use the [assignments guide](https://ehsanx.github.io/SPPH604-2026W/assignments.html)
   when you need to know what to do, what to submit, how it is graded, and what it feeds.
5. Skim [`practice/README.md`](https://ehsanx.github.io/SPPH604-2026W/practice/README.html) — it explains how P1–P5 build into M1.
6. Look at one worked example, for example
   [`examples/P1_analytic_cohort/`](https://ehsanx.github.io/SPPH604-2026W/examples/P1_analytic_cohort/P1_analytic_cohort_submission.html), to see the standard.
7. Work through [`labs/L0_setup.md`](labs/L0_setup.md) **before the first class** —
   R, RStudio, the PDF toolchain, a GitHub account, and a test knit.

If you already know the filename you need, open [`index.md`](index.md) or use the
[searchable file catalogue](https://ehsanx.github.io/SPPH604-2026W/files.html).

## The demonstration paper

Everything in `examples/` and `reproduction/` is built on:

> Kueh MTW et al. Body weight categories and fat distribution in relation to all-cause
> mortality among adults with MASLD. *BMJ Open* 2026;16:e113719. NHANES 2007–2018 with
> NCHS linked mortality. [doi:10.1136/bmjopen-2025-113719](https://doi.org/10.1136/bmjopen-2025-113719)

It reproduces: N = 6,371 against the paper's ~6,300, groups 391 / 4,585 / 787 / 608, 586
deaths, and a Group IV hazard ratio of 15.14 unadjusted → 2.91 adjusted (published:
15.13 → 2.89).

**These are answer keys, not templates to copy.** You will do this on *your* paper. What
transfers is the sequence of moves, not the numbers.

The article is included in [`paper/`](paper/) and is redistributed under **CC BY-NC**
(© Author(s) 2026, published by BMJ Group; no commercial re-use). See
[`paper/README.md`](paper/README.md) for the full attribution. Its peer-review history
file carries no stated licence and is not redistributed here.

## Running the reproduction code

```r
# from the reproduction/ folder
source("R/run_all.R")
```

Needs R with `haven`, `dplyr`, `survival`, `survminer`, `rms`, `survey`, `mice`,
`tableone`, `ggplot2`, `nhanesA`.

**The NHANES microdata is not in this repository** — it is ~211 MB and freely available
from CDC. `R/01_download.R` fetches it into `reproduction/data/`. The URL pattern is:

```
https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/<year>/DataFiles/<FILE>.xpt
```

## Using AI in this course

Permitted, with disclosure, and specified per assessment in the syllabus. Two things are
never permitted: **AI assistance during the live M3 defense**, and **putting any part of
another group's unpublished work into an AI tool**. Preparing for M3 with an AI is
permitted and needs no disclosure, because M3 has no submission. While running a reviewed
group's code you may ask an AI about your own machine and public documentation: paste what
is yours or public, describe what is theirs. Supports approved through UBC's Centre for
Accessibility are the exception to the live-defense rule; they are arranged in advance
through the syllabus section *Academic Accommodation Letter*.

You remain responsible for the integrity and accuracy of everything you submit. The oral
defense is where the course checks that the reasoning is yours.

## Contact

**Dr. M. Ehsan Karim** — ehsan.karim@ubc.ca · [ehsank.com](http://www.ehsank.com/)
Put `SPPH 604` in the subject line. Replies within 48 hours on weekdays.
Ask the TA in lab or in TA office hours, not by email.

## Licence

Course materials are **CC BY 4.0** — reuse and adapt freely with attribution, with named
carve-outs rather than one exception: material distributed only through Canvas and not
published here — if it is not in this repository, do not post it — plus third-party
material, the exercise datasets, session recordings, student work, and the papers in
`paper/`, which carry their own publisher licences (the demonstration paper is CC BY-NC).
See [`LICENSE.md`](LICENSE.md).

---

UBC's Point Grey Campus is located on the traditional, ancestral, and unceded territory of
the xʷməθkʷəy̓əm (Musqueam) people.
