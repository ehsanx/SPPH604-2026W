# Render all P1-P5 handouts (+ README) to PDF via rmarkdown + xelatex.
# Run:  Rscript render_pdfs.R
## Run from the handouts folder; no absolute path, so this works in either tree.
if (!file.exists("P1_analytic_cohort.md"))
  stop("Run this from the folder that holds the P1-P5 handouts.")
files <- c("README.md",
           "P1_analytic_cohort.md", "P2_confounding_diagnostic.md",
           "P3_effect_modification.md", "P4_design_aware_estimate.md",
           "P5_missing_data.md")
for (f in files) {
  cat("Rendering", f, "... ")
  ok <- tryCatch({
    rmarkdown::render(f, output_format = "pdf_document", quiet = TRUE)
    "OK"
  }, error = function(e) paste("FAILED:", conditionMessage(e)))
  cat(ok, "\n")
}
