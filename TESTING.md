# Testing

Use this file to regression-test the `use-scop` skill after updating `SKILL.md`, `README.md`, `README.zh-CN.md`, `task_router.yaml`, `agents/openai.yaml`, `scripts/test-skill.sh`, or `scripts/install-user-skill.sh`.

Recommended entry point:

```bash
bash scripts/test-skill.sh
```

Optional upstream verification against official GitHub metadata:

```bash
bash scripts/test-skill.sh --with-upstream
```

Optional non-interactive Codex CLI prompt regressions:

```bash
bash scripts/test-skill.sh --with-codex-cli
```

Both options can be combined.

```bash
bash scripts/test-skill.sh --with-upstream --with-codex-cli
```

## Quick Checks

The default test suite is static. It requires `python3` with `PyYAML` to verify that `SKILL.md` frontmatter is strict YAML. It does not require:

- a local SCOP source checkout
- an installed R package named `scop`
- a local R installation

It verifies that:

- `SKILL.md`, `README.md`, `README.zh-CN.md`, `task_router.yaml`, `agents/openai.yaml`, and `scripts/install-user-skill.sh` exist
- `SKILL.md` frontmatter is valid YAML, has a string description, and sets `disable-model-invocation: true`
- `SKILL.md` and agent metadata support explicit `$use-scop` and `/use-scop` invocation
- the skill routes through root-level `task_router.yaml`
- the public baseline is official upstream SCOP `0.8.9` dated `2026-05-02`
- the README files document Codex, Claude Code, and Cursor user-level and project-level install paths
- the README files warn not to install into Cursor's managed `~/.cursor/skills-cursor` directory
- old positive routes for the removed dimensional-reduction and CellChat plotting APIs are absent
- current routes such as `RunBulk()`, `loom_to_srt()`, `RunMilo()`, `RunLIANA()`, `RunDorothea()`, `RunBayesSpace()`, `RunscTenifoldKnk()`, `GLUE_integrate()`, `MultiMAP_integrate()`, and `WNN_integrate()` are present
- development routes such as `ConvertHomologs()`, `RunCytoSPACE()`, and `SpatialSpotPlot()` are marked as export-gated

## Optional Upstream Checks

`--with-upstream` uses official GitHub URLs and confirms:

- `DESCRIPTION` reports `Version: 0.8.9`
- `DESCRIPTION` reports `Date: 2026-05-02`
- `NAMESPACE` exports selected current and development-gated functions
- the GitHub releases and tags APIs currently return no packaged releases or tags

This check intentionally does not inspect `/home/new2/scop` or any installed package, because the published skill should not depend on one user's local source tree.

## Manual Prompt Tests

Run these prompts in Codex with `$use-scop`, or in Claude Code/Cursor with `/use-scop`, and compare the response against the expected behavior.

### 1. QC And UMAP

Prompt:

```text
$use-scop Write QC, preprocessing, UMAP, clustering, and marker code for my Seurat object.
```

Expected:

- reads or follows `task_router.yaml`
- prefers `RunCellQC()`, `standard_scop()`, `RunDimsReduction()`, `CellDimPlot()`, and `DEtestPlot()` or marker-related SCOP routes
- does not jump straight to pure Seurat code

### 2. Bulk Analysis

Prompt:

```text
$use-scop Write a pseudobulk differential expression and enrichment workflow.
```

Expected:

- prefers `RunBulk()`
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

### 4. Development-Gated Spatial Route

Prompt:

```text
$use-scop Can I use SCOP for CytoSPACE spatial spot assignment?
```

Expected:

- mentions `RunCytoSPACE()` and `SpatialSpotPlot()`
- says these are HEAD/development-gated routes
- checks installed exports or upstream `NAMESPACE` before writing runnable code

## Pass Criteria

The skill is in good shape when:

- it only activates under explicit `$use-scop`, `/use-scop`, or a clear request to use `use-scop`
- it remains visible to Codex/OpenAI while preserving explicit invocation for Claude Code/Cursor
- it routes through `task_router.yaml`
- it uses official SCOP `0.8.9` as the public baseline
- it gates HEAD/development APIs by export checks
- it avoids old positive routes
- it allows only explicit, narrow fallback to Seurat or ggplot2 for steps SCOP cannot express

## Install Script Checks

The install helper should be safe to inspect before it writes anything.

```bash
bash scripts/install-user-skill.sh --dry-run
bash scripts/install-user-skill.sh --codex --dry-run
bash scripts/install-user-skill.sh --claude --cursor --dry-run
```
