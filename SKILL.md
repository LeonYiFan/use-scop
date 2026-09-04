---
name: use-scop
description: "Use only when the user explicitly invokes $use-scop for Seurat-based single-cell, spatial, bulk, or multi-omics analysis with the scop R package; prefer current exported scop:: routes and scop-native plots, verify installed exports for HEAD-sensitive APIs, and allow only explicit narrow fallback to Seurat or ggplot2 when scop has no direct route."
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
- Prefer SCOP's public wrapper for an optional backend. Do not replace an available SCOP wrapper with a direct backend-package call.

- Prefer `RunStandardWorkflow()` and `RunIntegration()` for new workflows. `standard_scop()` and `integration_scop()` are compatibility aliases; retain them only when the installed version requires them.
- A task route lists alternatives and associated plots, not a mandatory sequence. Select the producer matching the requested method.

## Source Order

Use the official upstream package metadata as the public baseline. The route map was synchronized to upstream `main` commit `d6646dc31cfb1c6229558f15ed813caa1ff01200`; its `DESCRIPTION` reports SCOP version `0.9.1` dated `2026-09-01`.

For execution-oriented tasks, verify the local runtime before assuming code will run:

1. Check `requireNamespace("scop", quietly = TRUE)`.
2. Check `as.character(utils::packageVersion("scop"))` when version-sensitive APIs matter.
3. Use installed R help or function formals for exact arguments when available.
4. Use official GitHub `DESCRIPTION`, `NAMESPACE`, and `NEWS.md` when the local package is absent, old, or ambiguous.
5. Treat pkgdown pages as useful but potentially stale when they conflict with GitHub source.

## Runtime Gates

- Route against the checked upstream `main` snapshot recorded in `task_router.yaml`.
- Before presenting runnable code, confirm every selected route is exported by the installed SCOP package when the installed source or version may differ from that snapshot.
- Treat APIs added after the installed build as HEAD-sensitive; a matching version number alone does not prove matching exports or signatures.
- If the installed package lacks a selected route, name the missing function and either choose an exported older SCOP route or ask the user to update SCOP.

## Verify Inputs, Backends, and Results

- Verify the actual object, assay/layer, identities, sample labels, and required matrices before analysis. Do not infer raw counts from an assay name or pass scaled values to a count-based method.
- An exported R wrapper does not prove its R/Python backend is installed or its required data are present. Inspect wrapper help and the configured environment; distinguish export checks, adapter tests, and a real completed run.
- Prefer the public SCOP wrapper and its dependency checks. When modifying SCOP optional-backend code, follow repository `AGENTS.md`: Remotes except `thisplot`/`thisutils` stay runtime optional, use `check_r(..., verbose = FALSE)` and `get_namespace_fun()`, and do not add dependency declarations or environment/global-option bypasses to silence checks. This is a development constraint, not a reason to inject private helpers into user analysis scripts.
- Trace workflow calls through helpers when explaining what ran. Distinguish direct calls, helper-mediated execution, reads of stored results, and dimensions computed inside a backend.
- Report failed, skipped, and partial stages explicitly. Do not substitute synthetic results or another method while retaining the requested method label.
- For sample-level DE, verify biological replication and the selected method's count/aggregation requirements. Check `min.cells.sample` in installed `RunDEtest()` help; filtering changes the samples retained within each group. Cell-level tests are not biological-replicate evidence.

## Spatial Analysis and Plotting

- Read the selected producer's installed help for `image`, coordinates, assay, and reference requirements. Select an image explicitly for multi-image objects or iterate with an explicit per-image policy.
- Use `SpatialCoordinates()` where a public coordinate accessor is needed. Distance-sensitive computation uses raw acquisition coordinates; display coordinates serve rendering. Keep cell/spot identifiers aligned and state distance units when known.
- `RunStandardWorkflow(workflow = "spatial")` is a basic single-image Visium-style workflow. Its supported stages and methods must come from its actual formals/help, not the full spatial route list. Use `RunSpotQC()` for spot QC; do not automatically apply single-cell doublet rules to spots.
- Plot the actual stored producer output with a compatible SCOP plot. Do not assume every spatial result uses the same payload or invent public registry/accessor APIs from internal implementation names.
- For `CCCNetworkPlot(plot_type = "spatial")`, explain the selected-image scope and whether nodes/edges represent cells, spots, or group summaries. A rendered spatial network alone does not establish cross-slice communication or a physical transport path.
- Label constructed demo edges separately from real coordinates and labels; they do not validate a communication backend. Preserve named group-to-color mappings when comparing plots.

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
