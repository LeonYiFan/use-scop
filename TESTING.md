# Testing

Use this file to regression-test the `use-scop` skill after updating `SKILL.md`, `README.md`, `agents/openai.yaml`, or `references/scop-function-map.md`.

Recommended entry point:

```bash
bash scripts/test-skill.sh
```

To also run non-interactive Codex CLI regressions:

```bash
bash scripts/test-skill.sh --with-codex-cli
```

## Quick Checks

Verify that key `0.8.7` functions still exist in upstream `scop`:

```bash
SCOP_REPO=/path/to/scop
rg -n '^export\((RunDimsReduction|RunDimsEstimate|h5ad_to_srt|RunCellphoneDB|RunNichenetr|RunMultiNichenetr|CCCStatPlot|CCCHeatmap|CCCNetworkPlot|RunGSVA|RunMetabolism|RunDecontX)\)' "$SCOP_REPO/NAMESPACE"
```

Verify that the local R environment can see `scop`:

```bash
Rscript -e 'cat(requireNamespace("scop", quietly = TRUE))'
Rscript -e 'if (requireNamespace("scop", quietly = TRUE)) cat(as.character(utils::packageVersion("scop")))'
```

Verify that the skill only mentions old interfaces as things to avoid:

```bash
rg -n 'RunDimReduction|CellChatPlot|group_by|num_threads' SKILL.md README.md references/scop-function-map.md agents/openai.yaml
```

Expected result:

- `RunDimsReduction`, `RunDimsEstimate`, `RunCellphoneDB`, `RunNichenetr`, `RunMultiNichenetr`, and `CCC*Plot` are exported by upstream `scop`
- `requireNamespace("scop", quietly = TRUE)` returns `TRUE`
- `packageVersion("scop")` matches the intended baseline or is explicitly noted
- old names appear only in "do not use" guidance

## Manual Prompt Tests

Run these prompts in Codex and compare the response against the expected behavior.

### 1. Runnable workflow

Prompt:

```text
$use-scop 帮我写一段可直接运行的 scop QC + UMAP 代码
```

Expected:

- checks or states installed-package status first
- prefers `RunCellQC()`, `standard_scop()`, `CellDimPlot()`
- does not jump straight to pure Seurat code

### 2. Dimension selection

Prompt:

```text
$use-scop 用 scop 做降维，并自动选择合适维度
```

Expected:

- uses `RunDimsReduction()`
- may mention `RunDimsEstimate()` or `DimsEstimatePlot()`
- does not use `RunDimReduction()`

### 3. Cell-cell communication

Prompt:

```text
$use-scop 用 scop 做细胞通讯分析并画图
```

Expected:

- prefers `RunCellChat()`, `RunCellphoneDB()`, `RunNichenetr()`, or `RunMultiNichenetr()`
- uses `CCCStatPlot()`, `CCCHeatmap()`, or `CCCNetworkPlot()`
- does not use `CellChatPlot()`

### 4. Package-missing behavior

Prompt:

```text
$use-scop 帮我调试这段 scop 代码为什么跑不起来
```

Expected:

- treats this as execution-oriented
- checks installed `scop` before assuming runnable code
- if missing, gives install guidance before package-specific debugging

### 5. Non-execution request

Prompt:

```text
$use-scop 解释一下 scop 和 Seurat 的关系
```

Expected:

- explains in `scop` terms
- does not overemphasize installation checks because the request is conceptual

## Pass Criteria

The skill is in good shape when:

- it only activates under explicit `$use-scop`
- it prefers installed-package checks over source inspection
- it uses current `0.8.7` interfaces
- it avoids outdated names except in "avoid this" guidance
- it falls back to Seurat or `ggplot2` only when `scop` lacks direct support
