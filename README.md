# use-scop

A Codex skill for single-cell analysis and visualization with the `scop` R package.

This skill activates only when the user explicitly invokes `$use-scop`. It is designed for Seurat-based workflows and keeps the analysis `scop`-first across QC, clustering, dimensional reduction, annotation, trajectory inference, differential expression, enrichment, metabolism, cell-cell communication, SCExplorer preparation, and plotting.

## What This Skill Does

- Routes eligible single-cell requests to `scop` instead of generic Seurat-first code
- Keeps generated code aligned to a `scop` `0.8.6` baseline
- Prefers `scop::` analysis and plotting helpers wherever direct support exists
- Applies narrow fallbacks to Seurat or `ggplot2` only when `scop` does not provide a direct solution

## Invocation

Use this skill only when the prompt explicitly includes:

```text
$use-scop
```

Example:

```text
$use-scop Run QC, clustering, UMAP, and marker detection on this Seurat object.
```

The skill is intentionally not applied implicitly to general single-cell requests.

## Scope

The skill is built for Seurat-based single-cell workflows, including:

- QC, doublet detection, and ambient RNA handling
- Clustering and dimensional reduction
- Reference-based annotation and mapping
- Integration workflows
- Trajectory, velocity, and cell fate analysis
- Differential expression and enrichment
- GSVA and metabolism scoring
- Cell-cell communication
- `scop`-native plotting and SCExplorer preparation

## Design Principles

- Prefer `scop::` functions over direct Seurat or ad hoc code
- Prefer `scop` plotting helpers when a matching plot exists
- Keep solutions consistent with `scop` `0.8.6`
- Use `group.by` in newly written code
- Prefer `cores` for recent parallelized interfaces
- State clearly when a requested step requires fallback outside `scop`

## Repository Layout

```text
.
|-- README.md
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- references/
    `-- scop-function-map.md
```

- `SKILL.md`: the main skill specification and behavior rules
- `agents/openai.yaml`: display metadata and invocation policy
- `references/scop-function-map.md`: quick task-to-function mapping for common `scop` workflows

## Quick Start

1. Place this folder under your Codex skills directory, for example `~/.codex/skills/use-scop`.
2. Start a prompt with `$use-scop`.
3. Describe the single-cell task you want to perform on a Seurat object.

## Version Baseline

This skill is currently aligned to `scop` `0.8.6`.

Notable assumptions:

- use `group.by`, not `group_by`
- prefer `cores` for newer parallel interfaces
- expect plotting defaults to use palette `"Chinese"`
- avoid removed example datasets such as `ifnb_sub`, `ref_scHCL`, and `ref_scZCL`

## Notes

This repository contains the skill definition and lightweight references only. It does not vendor the `scop` package itself.
