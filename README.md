# use-scop

`use-scop` is an unofficial Codex skill that makes `scop` the default analysis and visualization layer for Seurat-based single-cell workflows.

It activates only when the user explicitly writes `$use-scop`, helping Codex produce `scop`-first code for QC, clustering, dimensional reduction, annotation, trajectory inference, differential expression, enrichment, metabolism, cell-cell communication, SCExplorer preparation, and plotting.

## Why This Skill Exists

When people ask for single-cell analysis help, LLMs often fall back to generic Seurat code even when a stronger `scop` workflow is available. This skill narrows that gap by teaching Codex to:

- prefer `scop::` functions over generic Seurat-first solutions
- keep code aligned with a `scop` `0.8.6` baseline
- use `scop` plotting helpers whenever direct support exists
- modernize argument usage such as `group.by` and `cores`
- fall back to Seurat or `ggplot2` only when `scop` does not provide a direct path

## Best Fit

Use `use-scop` when you want Codex to work in a `scop`-first style for:

- Seurat object QC and filtering
- clustering and dimensional reduction
- reference-based annotation and mapping
- integration workflows
- pseudotime, velocity, and lineage analysis
- differential expression and enrichment
- GSVA and metabolism scoring
- cell-cell communication
- `scop`-native plotting and SCExplorer preparation

Do not use it for:

- general single-cell prompts that do not explicitly request `$use-scop`
- workflows where `scop` is not part of the target stack
- tasks that require silent substitution of `scop` with other frameworks

## Installation

### 1. Install the skill

```bash
mkdir -p ~/.codex/skills
cd ~/.codex/skills
git clone https://github.com/LeonYiFan/use-scop.git
```

If you are updating an existing local copy:

```bash
cd ~/.codex/skills/use-scop
git pull
```

### 2. Prepare your analysis environment

This repository contains the Codex skill definition and references only. It does not vendor the `scop` package itself.

To run the generated analysis code, you should have:

- R installed
- `scop` available in your R environment
- a Seurat-based workflow or object ready to analyze

For `scop` itself, use the official project:

- Repository: <https://github.com/mengxu98/scop>

## Usage

Start your prompt with:

```text
$use-scop
```

Example prompts:

```text
$use-scop Run QC, clustering, UMAP, and marker detection on this Seurat object.
```

```text
$use-scop Rewrite this Seurat pipeline so it uses scop-native annotation, enrichment, and plotting functions.
```

```text
$use-scop Use scop to run Monocle3 pseudotime analysis and visualize dynamic features.
```

## What Is Inside

```text
.
|-- README.md
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- references/
    `-- scop-function-map.md
```

- `SKILL.md`: the main skill behavior, invocation rules, and version-aware guidance
- `agents/openai.yaml`: display metadata and explicit invocation policy
- `references/scop-function-map.md`: quick task-to-function mapping for common `scop` workflows

## Version Baseline

This skill is currently tuned around `scop` `0.8.6`.

Key assumptions include:

- write `group.by`, not `group_by`
- prefer `cores` for newer parallelized interfaces
- expect plotting defaults to use palette `"Chinese"`
- avoid removed example datasets such as `ifnb_sub`, `ref_scHCL`, and `ref_scZCL`

## Project Positioning

This is a community skill for Codex users. It is not an official `scop` repository and is not affiliated with the `scop` project.

## Acknowledgements

Special thanks to the author and maintainers of `scop`, especially the official project at <https://github.com/mengxu98/scop>, for building and sharing a powerful toolkit for single-cell omics analysis.

---

## 中文说明

`use-scop` 是一个非官方的 Codex skill，用来在用户显式输入 `$use-scop` 时，让 Codex 优先按照 `scop` 的思路完成单细胞分析与可视化，而不是直接退回到通用的 Seurat 写法。

### 适用场景

- 希望把 Seurat 对象分析改写为 `scop`-first 工作流
- 希望在 QC、聚类、降维、注释、轨迹、差异分析、富集分析、代谢分析、细胞通讯和绘图中优先使用 `scop`
- 希望避免模型生成过时参数写法，例如 `group_by` 或旧线程参数

### 安装方式

```bash
mkdir -p ~/.codex/skills
cd ~/.codex/skills
git clone https://github.com/LeonYiFan/use-scop.git
```

### 使用方式

在提示词开头明确写上：

```text
$use-scop
```

例如：

```text
$use-scop 请把这个 Seurat 单细胞分析流程改写成 scop 风格，并补上 QC、注释和富集分析代码。
```

### 致谢

感谢 `scop` 作者和项目维护者，也感谢官方项目仓库：

- <https://github.com/mengxu98/scop>
