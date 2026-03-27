---
name: use-scop
description: "Use when the user explicitly invokes $use-scop and wants single-cell analysis or visualization to be done with the scop R package. Apply to Seurat-based workflows for QC, clustering, dimensional reduction, annotation, trajectory inference, differential expression, enrichment, metabolism, cell-cell communication, SCExplorer preparation, and plotting. Prefer scop:: functions and scop-native plots; if scop lacks direct support, state that clearly before a limited fallback to Seurat or basic ggplot2."
---

# Use Scop

Use `scop` as the default analysis and visualization layer for single-cell tasks when the user explicitly invokes `$use-scop`.

Treat this skill as aligned to `scop` `0.8.6`, refreshed against the official changelog and current docs.

## Invocation Rules

- Activate this skill only when the user explicitly writes `$use-scop`.
- Do not apply this skill implicitly to general single-cell requests.
- Assume the main object is a `Seurat` object unless the user explicitly says otherwise.

## Version Baseline

- Assume `scop` `0.8.6` unless the local repo or installed package clearly shows another version.
- Use `group.by`, not `group_by`, in newly written code and explanations.
- Prefer `cores` for recent parallelized interfaces when the docs expose it; do not write stale `num_threads` for `scVI_integrate()`.
- Expect plotting defaults to use palette `"Chinese"` unless the user asks for another palette.
- Do not suggest removed example datasets `ifnb_sub`, `ref_scHCL`, or `ref_scZCL`; prefer `pancreas_sub`, `panc8_sub`, and `ref_scMCA`.

## Source of Truth

Use cached skill knowledge first. Check external `scop` sources only when the task is not covered by the bundled mapping, the required arguments are unclear, or the user asks for exact verification.

Check `scop` in this order when verification is needed:

1. Local clone at `/home/new2/R/scop`
2. Installed R help for `scop`
3. Official pkgdown docs at `https://mengxu98.github.io/scop/`

Within the local clone, prefer checking only the narrowest relevant source:

- `NEWS.md` for recent additions, renamed arguments, defaults, and behavior changes
- `man/` for arguments, return values, and examples
- `NAMESPACE` for exported functions
- `R/` for edge cases or implementation details
- `README.md` for workflow patterns only

## Operating Rules

- Prefer `scop::` functions over direct `Seurat`, `ggplot2`, or ad hoc analysis code.
- Prefer a full `scop` workflow rewrite over mixing one new `scop` step into an otherwise unrelated pipeline.
- Prefer `scop` plotting helpers for visualization whenever a matching plot exists.
- Use the bundled function map as the default chooser for routine tasks.
- Do not re-read the full `scop` repo for common tasks already covered by the bundled references.
- Keep function names and arguments aligned with `scop` `0.8.6` naming and defaults when drafting from memory.
- If the user provides older `scop` code, modernize argument names where safe, especially `group.by` and `cores`.
- When the request touches QC, gene-set scoring, metabolism, DE visualization, or trajectory fitting, actively consider newer `0.8.x` functions before falling back.
- If the user's current script already uses Seurat objects and metadata, adapt those objects into `scop` functions rather than redesigning the data model.

## Version-Aware Shortcuts

- Ambient RNA handling: use `RunDecontX()` directly or `RunCellQC()` with `qc_metrics` including `"decontX"` plus `decontX_*` arguments.
- Gene-set scoring: use `RunGSVA()` with `GSVAPlot()` for general pathway scoring.
- Metabolism scoring: use `RunMetabolism()` with `MetabolismPlot()` for metabolism-specific pathway analysis.
- DE visualization: prefer `DEtestPlot()` for volcano, Manhattan, and ring plots; use `res = ...` if a DE table already exists.
- Trajectory dynamics: `RunDynamicFeatures()` supports both `fit_method = "gam"` and `fit_method = "pretsa"`.
- Potency and pseudotime: `RunMonocle2()`, `RunMonocle3()`, `RunCytoTRACE()`, and `CytoTRACEPlot()` are first-class `scop` options.
- Database inspection: `ListDB()` now accepts multiple species and returns `Species` and `DB` columns.

## Fallback Policy

- If `scop` has direct support, use it.
- If `scop` does not have direct support, say so explicitly before any fallback.
- Limit fallback to `Seurat` or basic `ggplot2` only when needed to finish the requested task.
- Never silently replace a `scop`-capable step with another method.

Use wording like:

`scop` does not appear to provide a direct function for this step, so I am falling back to `Seurat`/`ggplot2` only for this part.

## Workflow

1. Confirm the task by mapping it to a `scop` capability with the bundled reference.
2. Apply the current version baseline first, especially `group.by`, `cores`, `"Chinese"` palette defaults, and available example data.
3. For common tasks, write the solution directly from the bundled mapping without re-scanning the package.
4. Check `NEWS.md` plus the relevant `scop` docs only if the task is uncommon, argument-sensitive, or ambiguous.
5. Build the solution with `scop::` analysis functions first.
6. Use `scop` visualization functions for output plots whenever available.
7. If a gap exists, explain the gap and apply a narrow fallback only for that step.

## Preferred Function Families

Read `references/scop-function-map.md` for the high-value task-to-function mapping before drafting code.

Treat that file as the primary working memory for this skill.

Start from these common anchors:

- Standard workflow: `standard_scop()`, `RunDimReduction()`
- QC: `RunCellQC()`, `RunDoubletCalling()`, `RunDecontX()`
- Annotation: `RunSingleR()`, `RunCellTypist()`, `RunScmap()`, `RunKNNPredict()`
- Mapping/projection: `RunKNNMap()`, `RunSeuratMap()`, `RunSymphonyMap()`, `ProjectionPlot()`
- Trajectory and fate: `RunSlingshot()`, `RunMonocle2()`, `RunMonocle3()`, `RunSCVELO()`, `RunPAGA()`, `RunCellRank()`, `RunPalantir()`, `RunCytoTRACE()`
- DE and enrichment: `RunDEtest()`, `DEtestPlot()`, `RunEnrichment()`, `RunGSEA()`, `RunGSVA()`
- Communication and metabolism: `RunCellChat()`, `RunMetabolism()`
- Visualization: `CellDimPlot()`, `FeatureDimPlot()`, `GroupHeatmap()`, `FeatureHeatmap()`, `DynamicHeatmap()`, `VelocityPlot()`, `PAGAPlot()`, `EnrichmentPlot()`, `GSVAPlot()`, `MetabolismPlot()`, `CytoTRACEPlot()`

## Output Style

- When asked to write or revise R analysis code, emit `scop`-first code snippets.
- When asked to explain an analysis plan, describe it using `scop` function names, not generic method labels alone.
- When a fallback is used, identify the exact step that fell back and keep the rest of the workflow in `scop`.
