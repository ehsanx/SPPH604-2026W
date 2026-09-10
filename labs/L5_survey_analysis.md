# Lab 5: Survey Data Analysis

## Overview

This lab introduces the essential principles of **survey data analysis**. Public health
data often comes from complex surveys like NHANES, which don't sample people randomly —
they use a strategic design with **weights, strata, and clusters** so the sample
represents the entire U.S. population. Ignoring these features can badly bias your results.

Using data from Flegal et al. (2016), you will work through the difference between a naive
analysis and a methodologically sound survey analysis: creating a survey design object,
generating weighted descriptive statistics, and fitting survey-weighted regression models
to replicate published findings. Your TA will walk through the worked solution during the
session.

This is the workflow you will reuse in **P4** on your own locked paper.

## Materials

- **Exercise instructions:** [Survey Data Analysis](https://ehsanx.github.io/EpiMethods/surveydataE.html)
- **Worked solution:** [The R codes](https://ehsanx.github.io/EpiMethods/surveydataEsolution.html)

**Before you come to lab**, install the package this exercise needs:

```r
install.packages("survey")
```

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
- **Due:** end of the lab session (Thu Oct 15).

## Grading: Complete / Incomplete

You receive **Complete** if the document knitted without errors, your group name and
members are in it, and it was submitted before the lab ended. Only members present in the
room receive credit.

