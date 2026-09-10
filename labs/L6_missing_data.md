# Lab 6: Missing Data & Multiple Imputation

## Overview

This lab addresses one of the most common challenges in real-world data analysis:
**handling missing data**. Simply deleting participants with any missing information
shrinks your sample and can introduce serious bias. Instead you will work with **Multiple
Imputation (MI)** — creating several plausible complete versions of the data based on what
is already known, then checking which conclusions hold across all of them.

Using NHANES data to replicate Williams et al. (2021), you will implement MI inside the
complex survey framework from the previous lab, imputing missing confounders and applying
the "Multiple Imputation then Deletion" (MID) strategy. Your TA will walk through the
worked solution during the session.

This is the workflow you will reuse in **P5** on your own locked paper.

## Materials

- **Exercise instructions:** [Missing Data Analysis](https://ehsanx.github.io/EpiMethods/missingdataE.html)
- **Worked solution:** [The R codes](https://ehsanx.github.io/EpiMethods/missingdataEsolution.html)

**Before you come to lab**, install the packages this exercise needs:

```r
install.packages(c("mice", "survey"))
```

## Your task

1. Follow along as the TA explains the worked solution.
2. Run the R Markdown file yourself, as a group, on your own laptop.
3. Put your **group name and the first names of everyone present** in the `author:`
   field at the top of the file.
4. Because imputation is random, **set a seed** (for example `set.seed(504)`) so your
   numbers are reproducible.

5. Add `sessionInfo()` in a final code chunk.
6. Knit to **PDF or HTML** and submit that one file before the lab ends.

No written explanations are required. If you get stuck, ask the TA in the room — that is
what the session is for.

## Deliverable

- **One file per group:** the knitted PDF or HTML.
- **Due:** end of the lab session (Thu Oct 22).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

> **Imputation is slow.** If the model is still running near the end of the session,
> reduce the number of imputations (for example `m = 5`) so your document knits in time.
> You can run the full version later for P5.

