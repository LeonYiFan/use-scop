# use-scop

English | [中文](./README.zh-CN.md)

## Acknowledgements

This project exists because SCOP is an exceptional Seurat-based single-cell omics toolkit. It brings together quality control, integration, annotation, trajectory and velocity analysis, differential testing, enrichment, metabolism, communication analysis, visualization, and SCExplorer export in a coherent R package that is useful in real research workflows. We are sincerely grateful to the SCOP authors, maintainers, and community for building and sharing it.

Official project:

https://github.com/mengxu98/scop

Official documentation:

https://mengxu98.github.io/scop/

## What This Skill Does

`use-scop` is a thin SCOP-first skill and routing guide for AI coding or research agents that can read these rules. Its purpose is simple: when SCOP can express a Seurat-based single-cell or omics workflow through public `scop::` APIs, generated analysis code should use SCOP first.

This repository is not a SCOP tutorial collection, environment troubleshooting guide, dependency matrix, or replacement for the official SCOP documentation. For installation and package-specific runtime issues, follow the official SCOP project.

The skill contains only the rule surface needed to route work: `SKILL.md` defines the hard behavior, and `task_router.yaml` lists compact SCOP-first routes across common domains.

The boundary is practical rather than absolute. SCOP is built around Seurat, so if a requested step cannot be expressed through SCOP, the skill should name the unsupported step and allow only a narrow, explicit fallback to Seurat or ggplot2 for that step. It should never silently replace a SCOP-capable step with another library.

## Current Baseline

The current public baseline is taken from official upstream GitHub metadata, not from any local installed package:

- `DESCRIPTION`: `scop` `0.8.9`, dated `2026-06-28`
- `NEWS.md`: already contains `0.9.0` development notes
- GitHub releases/tags: no packaged releases or tags are currently published

The route map is synchronized to upstream `main` commit `32cb4855`. Because `NEWS.md` can lead `DESCRIPTION`, generated runnable code should confirm selected exports in the installed package whenever its source or version differs from that snapshot. The test suite validates every namespaced route against upstream `NAMESPACE` by default.

## How To Use

- **Explicit invocation:** This skill should start only when the user directly calls `$use-scop`, `/use-scop`, or clearly asks to use the `use-scop` skill.

- **Default runtime:** Generated code should assume R with SCOP installed and Seurat objects as the primary data structure unless the user says otherwise.

- **Install for Codex:** Download the skill into your user-level Codex skills directory.

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.codex/skills/use-scop
```

- **Install for Claude Code:** Download this skill into your user-level Claude Code skills directory.

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.claude/skills/use-scop
```

- **Install for Cursor:** Download this skill into your user-level Cursor skills directory.

```bash
mkdir -p ~/.cursor/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.cursor/skills/use-scop
```

- **Project-level installs:** For a repository-local skill, put the same folder at `.claude/skills/use-scop` or `.cursor/skills/use-scop` in the project root.

- **Cursor managed skills:** Do not install this skill into `~/.cursor/skills-cursor`; that directory is reserved for Cursor-managed built-in skills.

- **Install helper:** From this repository, you can sync the current checkout to Codex, Claude Code, and Cursor user-level skill directories.

```bash
bash scripts/install-user-skill.sh --dry-run
bash scripts/install-user-skill.sh
```

- **Chat-based agents without a skill system:** Paste or attach `SKILL.md` and `task_router.yaml` as context, then start the request with `$use-scop` or `/use-scop`.

- **SCOP package installation:** To run generated code, install SCOP in the target R environment.

```r
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("mengxu98/scop")
```

- **SCOP source repository:** You do not need to clone the SCOP source repository to use this skill. The skill only needs the AI tool to read `SKILL.md` and `task_router.yaml`; the R environment that runs generated analysis code should already provide `scop`.

- **Recommended local SCOP source:** For best results, especially when your AI tool can inspect local source code, it is useful to also keep the SCOP source repository locally.

```bash
mkdir -p ~/src
git clone https://github.com/mengxu98/scop.git ~/src/scop
```

- **Example prompts:**

  - `$use-scop write a QC, preprocessing, UMAP, clustering, and marker workflow for my Seurat object.`
  - `/use-scop write a QC, preprocessing, UMAP, clustering, and marker workflow for my Seurat object.`
  - `$use-scop convert this Seurat-only pipeline into SCOP-first code with explicit fallback only where SCOP has no route.`
  - `$use-scop use SCOP for CellChat or CellphoneDB communication analysis and plot the results with CCC plots.`
  - `$use-scop tell me whether this spatial CytoSPACE workflow is available in my installed SCOP version.`

## Project Positioning

This is a community-maintained skill for AI coding and research agents. It is not an official SCOP repository and is not affiliated with the upstream SCOP project.
