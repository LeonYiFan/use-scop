# Testing

Use this file to regression-test the `use-scop` skill after updating `SKILL.md`, `README.md`, `README.zh-CN.md`, `task_router.yaml`, `agents/openai.yaml`, `scripts/test-skill.sh`, or `scripts/install-user-skill.sh`.

Recommended entry point:

```bash
bash scripts/test-skill.sh
```

The default test verifies every routed `scop::` function against official upstream `NAMESPACE` at `baseline.main_commit`. To detect drift separately:

```bash
bash scripts/test-skill.sh --latest
```

`--latest` checks exports on current `main` and reports its version/date without requiring the pinned version to remain current. It cannot be combined with `--offline`. Use offline mode only when network access is unavailable:

```bash
bash scripts/test-skill.sh --offline
```

Optional non-interactive Codex CLI prompt regressions:

```bash
bash scripts/test-skill.sh --with-codex-cli
```

Offline mode and prompt regressions can be combined.

```bash
bash scripts/test-skill.sh --offline --with-codex-cli
```

## Quick Checks

The test suite requires `python3` with `PyYAML` to verify that `SKILL.md` frontmatter is strict YAML. Its default upstream check also requires `curl`. It does not require:

- a local SCOP source checkout
- an installed R package named `scop`
- a local R installation

It verifies that:

- `SKILL.md`, `README.md`, `README.zh-CN.md`, `task_router.yaml`, `agents/openai.yaml`, and `scripts/install-user-skill.sh` exist
- `SKILL.md` frontmatter and `task_router.yaml` are valid YAML; skill frontmatter contains only `name` and a string `description`
- `SKILL.md` and agent metadata support explicit `$use-scop` and `/use-scop` invocation
- the skill routes through root-level `task_router.yaml`
- the public baseline is official upstream SCOP `0.9.1` dated `2026-09-01`
- the README files document Codex, Claude Code, and Cursor user-level and project-level install paths
- the README files warn not to install into Cursor's managed `~/.cursor/skills-cursor` directory
- old positive routes for the removed dimensional-reduction and CellChat plotting APIs are absent
- current routes such as `RunCNV()`, `RunESTIMATE()`, `RunSCENIC()`, `RunSpatialIntegration()`, `RunSpatialNetwork()`, and `RunDeconvolution()` are present
- `RunBulk()` is recorded as known but unexported and is not emitted as a namespaced route

## Upstream Checks

The default run uses official GitHub URLs pinned to the full commit in `task_router.yaml` and confirms:

- `DESCRIPTION` reports `Version: 0.9.1`
- `DESCRIPTION` reports `Date: 2026-09-01`
- `NAMESPACE` exports every function referenced as a `scop::` route in `task_router.yaml`
- excluded routes are actually unexported at the pinned commit
- routes are nonempty, uniquely named within their domain, and contain valid `scop::` names

This check intentionally does not inspect `/home/new2/scop` or any installed package, because the published skill should not depend on one user's local source tree.

These are skill and export-contract checks, not R execution or live backend tests. Optional CLI cases receive the candidate `SKILL.md` and router explicitly, so they do not silently test an older installed copy. Their keyword checks are only smoke tests; use the manual cases below to assess behavior.

## Manual Prompt Tests

Run these prompts in Codex with `$use-scop`, or in Claude Code/Cursor with `/use-scop`, and compare the response against the expected behavior.

### 1. QC And UMAP

Prompt:

```text
$use-scop Write QC, preprocessing, UMAP, clustering, and marker code for my Seurat object.
```

Expected:

- reads or follows `task_router.yaml`
- prefers `RunCellQC()`, `RunStandardWorkflow()`, `RunDimsReduction()`, `CellDimPlot()`, and `DEtestPlot()` or marker-related SCOP routes
- does not jump straight to pure Seurat code

### 2. Bulk Deconvolution

Prompt:

```text
$use-scop Write a bulk deconvolution and enrichment workflow.
```

Expected:

- prefers `RunDeconvolution()` or `RunCIBERSORT()`
- connects bulk results to `DEtestPlot()`, `RunEnrichment()`, `RunGSEA()`, `EnrichmentPlot()`, or `GSEAPlot()`
- keeps fallback explicit if a requested bulk substep lacks a SCOP route

### 3. Cell-Cell Communication

Prompt:

```text
$use-scop Use SCOP for CellChat or CellphoneDB communication analysis and plot results.
```

Expected:

- uses `RunCellChat()` or `RunCellphoneDB()`
- uses `CCCStatPlot()`, `CCCHeatmap()`, or `CCCNetworkPlot()`
- does not use removed `CellChatPlot()`

### 4. Current-Main Spatial Route

Prompt:

```text
$use-scop Can I use SCOP for CytoSPACE spatial spot assignment?
```

Expected:

- mentions `RunCytoSPACE()` and `SpatialSpotPlot()`
- checks installed exports when the installed source or version differs from the synchronized upstream-main snapshot

### 5. Multi-Image Spatial Communication

Prompt:

```text
$use-scop My Seurat object contains two Visium slices. Run spatial communication and explain a spatial network plot.
```

Expected:

- selects a supported spatial producer and checks its inputs/backend
- requires explicit image selection or an explicit per-image workflow
- distinguishes raw analysis coordinates from display coordinates
- does not claim that a selected-image plot infers communication across slices
- labels constructed edges if used for a plotting-only demonstration

### 6. Exported Wrapper Without Backend

Prompt:

```text
$use-scop RunPalantir is exported in my installed SCOP. Does that mean the workflow is ready to run?
```

Expected:

- distinguishes the R export from the Python environment and required inputs
- checks installed formals/help and the environment before promising execution
- does not install another method or fabricate pseudotime as an implicit fallback

### 7. Current Workflow And Retired APIs

Prompt:

```text
$use-scop Write a standard preprocessing and integration workflow. Can I still use LoadScopDataset and the RunGiottoWorkflow route?
```

Expected:

- prefers `RunStandardWorkflow()` and `RunIntegration()` when installed
- identifies the old workflow names as compatibility aliases
- reports that the two requested old routes are unexported at the recorded snapshot
- verifies installed capabilities and consults current dataset help instead of inventing replacement calls

## Pass Criteria

The skill is in good shape when:

- it only activates under explicit `$use-scop`, `/use-scop`, or a clear request to use `use-scop`
- its metadata disables implicit invocation and preserves explicit invocation across supported agents
- it routes through `task_router.yaml`
- it uses official SCOP `0.9.1` as the public baseline
- it validates every namespaced route against upstream `NAMESPACE`
- it avoids old positive routes
- it allows only explicit, narrow fallback to Seurat or ggplot2 for steps SCOP cannot express

## Install Script Checks

The install helper should be safe to inspect before it writes anything.

```bash
bash scripts/install-user-skill.sh --dry-run
bash scripts/install-user-skill.sh --codex --dry-run
bash scripts/install-user-skill.sh --claude --cursor --dry-run
```
