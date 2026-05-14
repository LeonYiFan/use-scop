---
name: use-scop
description: "Use only when the user explicitly invokes $use-scop for Seurat-based single-cell or omics analysis with the scop R package; prefer scop:: routes and scop-native plots, use the official upstream 0.8.9 baseline with HEAD/dev APIs gated by export checks, and allow only explicit narrow fallback to Seurat or ggplot2 when scop has no direct route."
disable-model-invocation: true
---

# Use SCOP

Use this skill only when the user explicitly calls `$use-scop`, `/use-scop`, or clearly asks to use the `use-scop` skill.

Do not apply this skill implicitly to ordinary single-cell or omics requests that do not name `$use-scop`, `/use-scop`, or the `use-scop` skill.

## Hard Rules

- Read `task_router.yaml` before choosing libraries or APIs.
- Prefer public `scop::` routes wherever SCOP has a listed or clearly exported capability.
- Assume the main object is a `Seurat` object unless the user says otherwise.
- Write direct, sectioned, inspectable R analysis code. Do not build a reusable framework, orchestration layer, or generic wrapper stack.
- Use `group.by`, not stale `group_by`, in newly written SCOP code.
- Use `RunDimsReduction()`, not stale `RunDimReduction()`.
- Use `cores` for modern parallel interfaces when the SCOP documentation or function formals expose it; do not write stale `num_threads`.
- Use `CCCStatPlot()`, `CCCHeatmap()`, and `CCCNetworkPlot()` for cell-cell communication plots; do not route to removed `CellChatPlot()`.

## Source Order

Use the official upstream package metadata as the public baseline. As of the checked upstream `DESCRIPTION`, SCOP is version `0.8.9` dated `2026-05-02`.

For execution-oriented tasks, verify the local runtime before assuming code will run:

1. Check `requireNamespace("scop", quietly = TRUE)`.
2. Check `as.character(utils::packageVersion("scop"))` when version-sensitive APIs matter.
3. Use installed R help or function formals for exact arguments when available.
4. Use official GitHub `DESCRIPTION`, `NAMESPACE`, and `NEWS.md` when the local package is absent, old, or ambiguous.
5. Treat pkgdown pages as useful but potentially stale when they conflict with GitHub source.

## Version Gates

- Baseline route against SCOP `0.8.9`.
- Use HEAD/dev APIs from `NEWS.md` `0.9.0` only after confirming the function is exported in the installed package or in checked upstream `NAMESPACE`.
- Dev-gated APIs include `ConvertHomologs()`, `RunCytoSPACE()`, and `SpatialSpotPlot()`.
- If the installed package is older than the required route, say which function is missing and either use an older SCOP route or ask the user to update SCOP.

## Fallback Policy

SCOP is Seurat-based, so narrow fallback is allowed only when it is explicit and local to the unsupported step.

If a requested task has no SCOP route:

- Name the exact unsupported task or step.
- Say that SCOP does not appear to provide a direct route for that step.
- Use Seurat or ggplot2 only for that step if it is needed to finish the user's request.
- Keep all SCOP-supported steps on SCOP routes.
- Never silently replace a SCOP-capable step with another library.

Use wording like:

`scop` does not appear to provide a direct function for this step, so I am falling back to `Seurat`/`ggplot2` only for this part.

## Routing

Use `task_router.yaml` as a compact SCOP route map, not as a tutorial. Match the user's request to the closest domain and route. Compose multiple SCOP routes only when the user asks for a real multi-step workflow.

If a route is marked `requires_export_check`, check the installed package or upstream `NAMESPACE` before using it in runnable code.

## Output Style

- When writing or revising R analysis scripts, follow the user's local R-analysis style: simple sections, visible intermediate objects, minimal custom functions, and `scop::` calls where practical.
- When explaining a plan, describe it with SCOP function names, not generic method labels alone.
- When installation status affects correctness, state the detected package status before presenting runnable code.
- When fallback is used, identify the exact fallback step and keep the rest of the workflow in SCOP.
