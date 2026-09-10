# M2 — reproducibility note

`M2_critique_deck.md` is a **critique of another group's M1**, not a new analysis of our
own. It therefore produces **no numbers from our own data**, and there is no `.qmd` to
run in this folder.

For M2, reproducibility runs in the opposite direction: *we* clone the reviewed group's
repository and re-run their code, and Slide 2 reports what happened when we did. Running
their code and reading their argument are two different passes, and in this review they
returned two different kinds of finding:

- **Running the code returned confirmations and one packaging gap.** It ran end to end
  from raw data, and the funnel, the group sizes, the death count and both headline
  contrasts regenerated and match their deck. The check we ran deliberately — whether the
  survey design is built on the full frame and then subsetted, rather than the rows being
  filtered before the design is created — came back clean, and Slide 2 reports it as
  clean. Their figures are substituted at build time rather than typed, so deck and code
  cannot disagree. The one defect this pass found is a packaging one: their README does
  not list every package the pipeline loads, so a clean install stops twice.
- **Reading the argument returned both substantive objections.** Objection 1 (Slide 3):
  the paper's published Table 2 is used as corroboration without an interval, and their
  own detail note concedes that interval cannot be recovered. Objection 2 (Slide 4): the
  TyG item on their "what would change our mind" list cannot settle the locked contrast,
  because that sensitivity is estimated against Group I whatever weights are applied.
  Neither surfaced from the pipeline run: both came from reading their deck, their detail
  notes and the paper's own table.

A good critique needs both passes. Running the code without reading the argument tells you
that the pipeline executes, not whether it answers the question; reading the argument
without running the code leaves you with only what the authors chose to show you.

The numbers quoted here *about the demonstration paper* — the funnel, group sizes,
HRs, interaction p-values — are reproduced by the `.qmd` files in the P1–P5 and M1
subfolders of this directory.
