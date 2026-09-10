# Licence

## Course materials — CC BY 4.0

Everything in this repository written for SPPH 604 — the syllabus, the lab and practice
handouts, the model submissions, the lecture plans and slides, and the reproduction
pipeline code — is released under the
**[Creative Commons Attribution 4.0 International Licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)**.

You are free to **share** and **adapt** this material for any purpose, including
commercially, provided you give appropriate credit, link to the licence, and indicate if
changes were made.

**Suggested attribution:**

> SPPH 604: Application of Advanced Epidemiological Methods (2026W).
> M. Ehsan Karim, University of British Columbia School of Population and Public Health.
> Licensed CC BY 4.0.

If you adapt these materials for your own course, we would be glad to hear about it, but
you are not obliged to ask.

**What this licence does not cover.** Material distributed only through Canvas and not
published here — the rubric grids, the worked AI-use example, Zoom links, and anything
posted in the weekly Modules; anything licensed to the course by a third party; the
exercise datasets noted below; **session recordings**; and **student work**. Those remain
governed by the syllabus's *Copyright* and *Session Recordings* sections, which the grant
above does not override. The test is simple: **if it is not in this repository, do not post
it.**

---

## `paper/` — two papers, two licences, neither ours to relicense

### `e113719.full.pdf` — CC BY-**NC**, more restrictive than this repository

`paper/e113719.full.pdf` is:

> © Author(s) (or their employer(s)) 2026.
> **Re-use permitted under CC BY-NC. No commercial re-use.**
> Published by BMJ Group.
> Kueh MTW, Chew NWS, et al. *BMJ Open* 2026;16:e113719.
> doi:[10.1136/bmjopen-2025-113719](https://doi.org/10.1136/bmjopen-2025-113719)

**CC BY-NC is not CC BY.** The repository licence above does not extend to that file, and
you may not re-use it commercially. See [`paper/README.md`](paper/README.md).

The article's peer-review history file carries no stated licence and is deliberately **not
included** in this repository; download it from the publisher.

### `PIIS2773065424001007.pdf` and `mmc1.pdf` — CC BY

> Karim ME, Hossain MB, Zheng C. *AJPM Focus* 2025;4(2):100282.
> doi:[10.1016/j.focus.2024.100282](https://doi.org/10.1016/j.focus.2024.100282)
> © 2024 The Author(s), published by Elsevier Inc.
> **Open access under CC BY.**

Same terms as this repository: reuse and adapt with attribution. Its code and analytic
data are archived separately at <https://doi.org/10.5281/zenodo.20764350>.

---

## Third-party data

The NHANES microdata and the NCHS linked mortality files are **United States government
public-domain data** and are not covered by this licence. They are not redistributed here
(see [`.gitignore`](.gitignore)); `reproduction/R/01_download.R` fetches them from CDC.

Exercise datasets used in the labs (RHC, and the NHANES extracts in the EpiMethods
tutorials) belong to their original sources and are linked rather than copied.

## Third-party front-end code

The rendered `.html` decks and notebooks embed vendored JavaScript, CSS and web fonts
(reveal.js, Bootstrap, and others). Those components are licensed by their own authors and are
not covered by the CC BY 4.0 grant above; their notices are collected in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
