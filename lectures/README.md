# SPPH 604 — In-class lecture slide plans (Weeks 1–7)

Slide-by-slide **blueprints** (not finished decks) for the weekly class session.
Weeks 2–7 run **Tuesday 9:30 am–12 pm (150 minutes)**, ahead of that week's Thursday
lab (10 am–12 pm), so the lecture and lab feel continuous. **Week 1 is the exception:**
there is no Tuesday session and no lab — the course opens with a **two-hour Thursday
session** (Sept 10, 10 am–12 pm, by Zoom). Each lecture teaches the concept and
theoretical issue of the demonstration paper (**MASLD / NHANES**, Kueh et al.,
BMJ Open 2026) *before* students go into that week's lab.

Every plan has the same shape:

- **Learning objectives** (3–5)
- **Continuity** — recap of last week's lab + what today sets up
- a numbered **slide blueprint** — each slide has content bullets, a **"MASLD hook"**
  tying it to the paper, and an approximate minute count (with a break marker)
- a closing **"Bridge to today's lab"** slide stating exactly what students do in
  `Lx` and how it becomes their increment `Px`

## The seven weeks

| Week | Lecture | Feeds lab | Feeds increment |
|---|---|---|---|
| **1** | Course intro + procedures (+ 1 paper teaser) | — (setup) | begins M0 shortlisting |
| **2** | NHANES data sources; reading Methods critically | L1 Data wrangling | M0 shortlist |
| **3** | Cohort construction — FLI, MASLD criteria, eligibility | L2 Analytic data | P1 eligibility (M0 locked) |
| **4** | Confounding & DAGs; Table 1; variable roles | L3 Confounding | P2 Table 1 |
| **5** | Interaction & effect modification | L4 Interaction | P3 effect modification |
| **6** | Complex survey design (weights/strata/PSU) | L5 Survey analysis | P4 design-aware estimate |
| **7** | Missing data (MCAR/MAR/MNAR; MI) | L6 Missing data | P5 missing-data sensitivity |

## Design notes

- **Continuity is the point.** Slide 1 of each week recaps where the project stands;
  the last slide hands off directly into the lab and the formative increment.
- **The paper is the running example.** Concepts are taught through the MASLD
  reproduction: Group IV HR ≈ 15 → 2.9, the sex interaction that is null unweighted
  and moves under the design, FLI circularity, the survey-weighting attenuation, the
  typed cohort funnel. The cohort size is the first lesson rather than a verified
  match — the paper reports N ≈ 6,300, our full analytic file is 6,371, and
  accounting for the difference is the skill being taught.

- **The weeks build toward M1.** The demonstration paper runs through Weeks 3–5 as
  sustained practice in replication and methodological interrogation, so the analytic
  judgment **M1** asks each group to make rests on skills they have already rehearsed —
  the judgment itself stays theirs.
- **Timing convention — budget to the clock.** The session length is the cap: **150 min**
  for a Tuesday class (Weeks 2–7), **120 min** for the Week 1 Thursday opener. A plan's own
  minute markers are the whole budget and the only accounting: they include the break, and
  nothing outside them is counted, because the untimed **Learning objectives** and
  **Continuity** blocks at the head of every plan are covered inside that week's Slide 1.
  Markers may sum *to* the cap; they may never sum *past* it. Whatever is left over is
  **float** — minutes the room spends on questions and the vote-and-argue moments. Buffer is
  carried *inside* the plan, never left as unallocated time at the end: each plan names one
  recap or preview slide as its **designated cut**, so an overrun costs a slide chosen in
  advance instead of the bridge into the lab. The plan file is the budget of record; the
  decks' speaker-note timings re-allocate a plan's minutes and are not summed here.

## Checking the timings

Each plan states its own total on its `Duration:` line. That line is the claim; this is the
check, and it re-derives all seven weeks at once whenever a plan is retimed (Git Bash, from
the repo root):

```bash
python -c "import re,glob;P=re.compile(r'(?m)^(?:\#\#\s.*?\(~?(\d+) ?min\)|\s*[-*]\s*\(?~?(\d+) ?min\)?\.?\s*$|\s*\d+\.\s.*?\((\d+) min\))');[print(f,sum(int(x) for m in P.finditer(open(f,encoding='utf-8').read()) for x in m.groups() if x)) for f in sorted(glob.glob('lectures/Week*.md'))]"
```

Read each total against that week's cap — 120 for Week 1, 150 for Weeks 2–7. Only what the
command matches counts as a marker: minutes written into a plan's prose are not part of the
budget, so a total counted by eye can come out higher than the real one. A week over its cap
owes a trim in its own file, not a footnote here. This README publishes no table of the
current totals on purpose — it would be a frozen snapshot of seven files it does not own,
and stale the first time one of them is retimed.

## Built decks (`slides/`)

The plans have been turned into finished **Quarto `revealjs` decks** in
[`slides/`](https://github.com/ehsanx/SPPH604-2026W/tree/main/lectures/slides) — one `.qmd` per week plus a self-contained rendered `.html`
(open in any browser; arrow keys to navigate, `S` for speaker notes, `F` for
fullscreen). Each deck has a title slide, objectives, a continuity slide, the
plan's content slides with **MASLD** running-example callouts, and detailed
**speaker notes** (timings + teaching prompts) under each slide. The Kaplan–Meier
figure is embedded on the weeks that discuss the survival result (2, 5, 6).
Each `.html` is the rendered form of the `.qmd` beside it, so present from the `.html`
and treat the `.qmd` as the source. If you adapt a deck, change the `.qmd` and re-render
it with Quarto rather than editing the `.html`. From this directory:

```bash
quarto render slides/Week5_interaction_slides.qmd
```

`img/` holds the two embedded figures, copied from [`reproduction/output/figures/`](https://github.com/ehsanx/SPPH604-2026W/tree/main/reproduction/output/figures).
