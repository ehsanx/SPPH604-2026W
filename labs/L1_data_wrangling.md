# Lab 1: NHANES Data Wrangling

## Overview

In this lab you will learn how epidemiologists access and prepare large survey datasets
in R, using NHANES as the example: importing, merging, cleaning, and summarizing. Your TA
will walk through the worked solution during the session.

The goal of this lab is to get your toolchain working end to end. By the time you leave
the room, you should be able to open an R Markdown file, run it, and produce a finished
document.

## Materials

- **Exercise instructions:** [Exercise 3(a) Lab](https://ehsanx.github.io/EpiMethods/accessingE3.html)
- **Worked solution:** [Exercise 3(a) Solution](https://ehsanx.github.io/EpiMethods/accessingE3solution.html)
- **AI-assisted walkthrough:** [Exercise 3(a) AI Vibe](https://ehsanx.github.io/EpiMethods/accessingE3vibe.html)

## Your task

1. Follow along as the TA explains the worked solution.
2. Run the R Markdown file yourself, as a group, on your own laptop.
3. Put your **group name and the first names of everyone present** in the `author:`
   field at the top of the file.

4. Add `sessionInfo()` in a final code chunk.
5. Knit to **PDF or HTML** and submit that one file before the lab ends.

No written explanations are required. If you get stuck, ask the TA in the room — that is
what the session is for.

## Deliverable

- **One file per group:** the knitted PDF or HTML.
- **Due:** end of the lab session (Thu Sept 17).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

---

## Where this lab fits

This lab is one step in a weekly chain: Tuesday’s lecture sets up the method, Thursday’s lab runs it on fixed teaching data, and your increment applies it to the paper your group locked at M0.

| | Document | How this lab connects |
|---|---|---|
| **This week’s lecture** | [Week 2 — NHANES data sources; reading Methods critically](https://ehsanx.github.io/SPPH604-2026W/lectures/Week2_nhanes_and_reading_methods.html) | Tuesday read the demonstration paper’s Methods section as the first act of reproduction, and gave you the four-primitive template. This lab turns that reading into data: several NHANES cycles downloaded, the raw topic files read, and everything merged on `SEQN` into one row per person. |
| **Slide deck** | [Week 2 deck](https://ehsanx.github.io/SPPH604-2026W/lectures/slides/Week2_nhanes_slides.html) | The same material as slides, with speaker notes. Press `S` for notes, `F` for fullscreen. |
| **Milestone** | [M1 — Replication and interrogation](https://ehsanx.github.io/SPPH604-2026W/milestones/M1_assignment.html) | Only indirectly, and only through the paper you lock at M0. Nothing you build today is submitted for M1. |
| **Milestone** | [M0 — Feasibility memo](https://ehsanx.github.io/SPPH604-2026W/milestones/M0_assignment.html) | Use this week’s template and the M0 criteria to shortlist two or three candidate NHANES papers of your own. You lock one at M0 in Week 3. |
| **Every later lab** | — | L1’s merge is the substrate for the whole term. Table 1, confounding, interaction, survey weights and missing data all run on the table you build today, so a clean merge now saves you five weeks of debugging. |
