# L0: Setup — do this before the first class

**Self-study. Not graded. Takes about 30 minutes**, most of it waiting for downloads.

The first session covers the course, the project, and your R + GitHub setup. You will get
much more out of it if the software is already installed. Everything afterwards assumes
it works.

If something fails, **stop and bring it to the first session** — that is what it is for.
Do not spend two hours fighting an install alone.

---

## The checklist

- [ ] R installed
- [ ] RStudio installed
- [ ] The PDF toolchain installed (TinyTeX)
- [ ] Course packages installed
- [ ] A free GitHub account
- [ ] The test document below knits successfully

---

## 1. Install R

<https://cran.r-project.org/> — choose your operating system and take the latest release.
The course is developed on **R 4.5.1**; anything from 4.3 upward is fine.

Install R **before** RStudio. RStudio is an editor; it needs R underneath and will not
find it if the order is reversed.

## 2. Install RStudio

<https://posit.co/download/rstudio-desktop/> — the free Desktop edition.

Open it once and confirm you see a console with an `>` prompt.

## 3. Install the PDF toolchain

This is the step that most often goes wrong, and the one worth doing beforehand
rather than during a lab. In the RStudio console:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

The second line downloads a small LaTeX distribution and takes a few minutes. You do
**not** need MiKTeX or MacTeX; TinyTeX is enough and much smaller.

*Already have MiKTeX or MacTeX?* Leave it — skip this step.

## 4. Install the course packages

```r
install.packages(c(
  "rmarkdown", "knitr", "tidyverse", "haven",
  "survival", "survminer", "rms", "survey",
  "mice", "tableone", "nhanesA", "kableExtra"
))
```

Two more are needed for Lab 4 only, and you can leave them until then:

```r
install.packages(c("interactionR", "Publish"))   # note the capital P
```

If a package fails to install, note **which one** and the error message. Bring both.

## 5. Create a GitHub account

<https://github.com/signup> — free. You will keep your group's code in a repository and
submit a downloaded zip of it with M1 and M4 — the only two milestones that ask for one.
**We do not need access to your repository**, so a free personal account is all you need.

Use an email address you will still have after you graduate.

## 6. Test that it works

Create a new file in RStudio (**File → New File → R Markdown**), replace everything in it
with the text below, save it as `setup_test.Rmd`, and click **Knit**.

````markdown
---
title: "Setup test"
author: "Your name"
output: pdf_document
---

```{r}
sessionInfo()
```

```{r}
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  labs(title = "If you can see this plot in a PDF, your setup works")
```
````

**You are done when a PDF appears** containing your session information and a scatter plot.

If PDF fails but HTML works, the problem is step 3 — TinyTeX. That is a common and fixable
problem; bring it to the first session.

---

## What to bring to the first session

- Your laptop, with the above done as far as you got
- The exact error message if anything failed — a screenshot is fine

**Once the in-person labs begin**, you will need your laptop with R installed at every
one. The syllabus gives the lab day, time and room.

## If you don't have a suitable laptop

Contact the instructor. UBC Library lends laptops, and the
[UBC Vancouver Technology Bursary](https://students.ubc.ca/finances/awards-scholarships-bursaries/ubc-vancouver-technology-bursary/)
may be able to help. Required software for this course costs **$0** — R, RStudio, TinyTeX,
GitHub and both textbooks are all free.
