---
name: use-scop
description: "Use when the user explicitly invokes $use-scop and wants single-cell analysis or visualization to be done with the scop R package. Apply to Seurat-based workflows for QC, clustering, dimensional reduction, annotation, trajectory inference, differential expression, enrichment, metabolism, cell-cell communication, SCExplorer preparation, and plotting. Prefer scop:: functions and scop-native plots; if scop lacks direct support, state that clearly before a limited fallback to Seurat or basic ggplot2."
---

# Use Scop

Use `scop` as the default analysis and visualization layer for single-cell tasks when the user explicitly invokes `$use-scop`.

Treat this skill as aligned to `scop` `0.8.7`, primarily against the installed package interface and current docs.

## Invocation Rules

- Activate this skill only when the user explicitly writes `$use-scop`.
- Do not apply this skill implicitly to general single-cell requests.
- Assume the main object is a `Seurat` object unless the user explicitly says otherwise.

## Decision Order

Follow this order unless the user explicitly asks for something different:

1. Check whether the request is execution-oriented.
2. If it is, verify installed `scop` availability before assuming runnable code.
3. If installed, check version only when compatibility may matter.
4. Use bundled skill knowledge and the function map for the first draft.
5. Check installed R help when arguments or behavior still need verification.
6. Check pkgdown docs only if installed help is insufficient.
7. Inspect upstream source only when the user explicitly wants source-level verification or docs remain ambiguous.

## Version Baseline

- Assume `scop` `0.8.7` unless the local repo or installed package clearly shows another version.
- Use `group.by`, not `group_by`, in newly written code and explanations.
- Prefer `RunDimsReduction()`, not the older `RunDimReduction()` name.
- Prefer `cores` for recent parallelized interfaces when the docs expose it; do not write stale `num_threads` for `scVI_integrate()`.
- Expect plotting defaults to use palette `"Chinese"` unless the user asks for another palette.
- Do not suggest removed example datasets `ifnb_sub`, `ref_scHCL`, or `ref_scZCL`; prefer `pancreas_sub`, `panc8_sub`, and `ref_scMCA`.
- Prefer unified cell-cell communication plotting via `CCCStatPlot()`, `CCCHeatmap()`, and `CCCNetworkPlot()`; do not suggest removed `CellChatPlot()`.

## Source of Truth

Prefer the installed `scop` package as the runtime source of truth. Verify in this order: installed package and R help, pkgdown docs, then optional upstream source inspection only when source-level verification is necessary.

## Operating Rules

- Treat the following as execution-oriented tasks: writing runnable R pipelines, debugging user code, modifying existing `scop` scripts, explaining runtime errors, or advising on package-dependent arguments.
- If `scop` is missing, say so clearly and provide a minimal install snippet before drafting code that assumes successful execution.
- If the installed `scop` version is older than the skill baseline and that difference matters to the requested task, say which function or interface may differ and write version-aware guidance.
- Prefer `scop::` functions over direct `Seurat`, `ggplot2`, or ad hoc analysis code.
- Prefer a full `scop` workflow rewrite over mixing one new `scop` step into an otherwise unrelated pipeline.
- Prefer `scop` plotting helpers for visualization whenever a matching plot exists.
- Use the bundled function map as the default chooser for routine tasks.
- Keep function names and arguments aligned with `scop` `0.8.7` naming and defaults when drafting from memory.
- If the user provides older `scop` code, modernize argument names where safe, especially `group.by` and `cores`.
- When the request touches QC, dimensionality reduction, data import, cell-cell communication, gene-set scoring, metabolism, DE visualization, or trajectory fitting, actively consider newer `0.8.x` functions before falling back.
- If the user's current script already uses Seurat objects and metadata, adapt those objects into `scop` functions rather than redesigning the data model.

## Version-Aware Shortcuts

- Ambient RNA handling: use `RunDecontX()` directly or `RunCellQC()` with `qc_metrics` including `"decontX"` plus `decontX_*` arguments.
- Dimensionality reduction: use `RunDimsReduction()` and consider `RunDimsEstimate()` / `DimsEstimatePlot()` when dimension selection matters.
- Data import: use `h5ad_to_srt()` for direct `.h5ad` to `Seurat` conversion when the user starts from AnnData.
- Gene-set scoring: use `RunGSVA()` with `GSVAPlot()` for general pathway scoring.
- Metabolism scoring: use `RunMetabolism()` with `MetabolismPlot()` for metabolism-specific pathway analysis.
- DE visualization: prefer `DEtestPlot()` for volcano, Manhattan, and ring plots; use `res = ...` if a DE table already exists.
- Trajectory dynamics: `RunDynamicFeatures()` supports both `fit_method = "gam"` and `fit_method = "pretsa"`.
- Potency and pseudotime: `RunMonocle2()`, `RunMonocle3()`, `RunCytoTRACE()`, and `CytoTRACEPlot()` are first-class `scop` options.
- Database inspection: `ListDB()` now accepts multiple species and returns `Species` and `DB` columns.
- Cell-cell communication: use `RunCellChat()` for CellChat, `RunCellphoneDB()` for CellphoneDB, `RunNichenetr()` / `RunMultiNichenetr()` for ligand-receptor prioritization, and the `CCC*Plot()` family for visualization.

## Fallback Policy

- If `scop` has direct support, use it.
- If `scop` does not have direct support, say so explicitly before any fallback.
- Limit fallback to `Seurat` or basic `ggplot2` only when needed to finish the requested task.
- Never silently replace a `scop`-capable step with another method.

Use wording like:

`scop` does not appear to provide a direct function for this step, so I am falling back to `Seurat`/`ggplot2` only for this part.

## Workflow

1. Confirm the task by mapping it to a `scop` capability with the bundled reference.
2. Apply the `Decision Order`, especially for installation and verification steps.
3. Apply the current version baseline first, especially `group.by`, `cores`, `"Chinese"` palette defaults, and available example data.
4. For common tasks, write the solution directly from the bundled mapping without re-scanning the package.
5. Build the solution with `scop::` analysis functions first.
6. Use `scop` visualization functions for output plots whenever available.
7. If a gap exists, explain the gap and apply a narrow fallback only for that step.

## Install Detection

- For execution-oriented tasks, check `requireNamespace("scop", quietly = TRUE)` first and `as.character(utils::packageVersion("scop"))` only when needed.
- If `scop` is not installed, say that runnable code will fail until installation and provide this install path:

```r
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("mengxu98/scop")
```

- Do not suggest cloning the source repo unless the user explicitly wants source inspection, development, or exact upstream verification.
- If the installed version is older than `0.8.7`, keep code compatible with the detected version and call out any version-specific interface differences only when they matter.

## Preferred Function Families

Read `references/scop-function-map.md` before drafting code. Start from these common anchors:

- Standard workflow: `standard_scop()`, `RunDimsReduction()`
- QC: `RunCellQC()`, `RunDoubletCalling()`, `RunDecontX()`
- Annotation: `RunSingleR()`, `RunCellTypist()`, `RunScmap()`, `RunKNNPredict()`
- Mapping/projection: `RunKNNMap()`, `RunSeuratMap()`, `RunSymphonyMap()`, `ProjectionPlot()`
- Dimensionality estimation/import: `RunDimsEstimate()`, `DimsEstimatePlot()`, `h5ad_to_srt()`, `adata_to_srt()`
- Trajectory and fate: `RunSlingshot()`, `RunMonocle2()`, `RunMonocle3()`, `RunSCVELO()`, `RunPAGA()`, `RunCellRank()`, `RunPalantir()`, `RunCytoTRACE()`
- DE and enrichment: `RunDEtest()`, `DEtestPlot()`, `RunEnrichment()`, `RunGSEA()`, `RunGSVA()`
- Communication and metabolism: `RunCellChat()`, `RunCellphoneDB()`, `RunNichenetr()`, `RunMultiNichenetr()`, `RunMetabolism()`
- Visualization: `CellDimPlot()`, `FeatureDimPlot()`, `GroupHeatmap()`, `FeatureHeatmap()`, `DynamicHeatmap()`, `VelocityPlot()`, `PAGAPlot()`, `EnrichmentPlot()`, `GSVAPlot()`, `MetabolismPlot()`, `CytoTRACEPlot()`, `CCCStatPlot()`, `CCCHeatmap()`, `CCCNetworkPlot()`

## Output Style

- When asked to write or revise R analysis code, emit `scop`-first code snippets.
- When asked to explain an analysis plan, describe it using `scop` function names, not generic method labels alone.
- When a fallback is used, identify the exact step that fell back and keep the rest of the workflow in `scop`.
- When installation status affects correctness, state the detected package status before presenting runnable code.
