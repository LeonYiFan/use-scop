# use-scop

[English](./README.md) | 中文

## 致谢

这个项目的存在，是因为 SCOP 是一个非常出色的 Seurat 生态单细胞组学工具包。它把质控、整合、注释、轨迹和 velocity、差异分析、富集、代谢、细胞通讯、可视化以及 SCExplorer 导出组织在一个连贯的 R 包中，非常贴近日常科研分析工作流。我们真诚感谢 SCOP 的作者、维护者和社区，感谢他们构建并分享这样一个实用工具。

官方项目：

https://github.com/mengxu98/scop

官方文档：

https://mengxu98.github.io/scop/

## 这个 Skill 做什么

`use-scop` 是一个轻量的 SCOP-first skill 和任务路由指南，适用于能够读取这些规则的 AI 编程或科研助手。它的目标很简单：只要 SCOP 能通过公开的 `scop::` API 表达某个基于 Seurat 的单细胞或组学工作流，生成的分析代码就应该优先使用 SCOP。

这个仓库不是 SCOP 教程集合、环境排错指南、依赖兼容矩阵，也不能替代 SCOP 官方文档。安装和包运行问题请优先参考 SCOP 官方项目。

这个 skill 只保留任务路由所需的最小规则面：`SKILL.md` 定义硬性行为规则，`task_router.yaml` 则按常见分析领域提供紧凑的 SCOP-first 路由。

边界是务实的，而不是绝对拒绝 fallback。SCOP 本身围绕 Seurat 构建，因此如果某个步骤不能通过 SCOP 表达，skill 应指出具体不支持的步骤，并且只允许在该步骤上明确、窄范围地 fallback 到 Seurat 或 ggplot2。不能把 SCOP 能完成的步骤静默替换成其他库。

## 当前基线

当前公开基线来自官方 upstream GitHub 元数据，而不是本机已安装的旧包：

- `DESCRIPTION`: `scop` `0.8.9`，日期为 `2026-05-02`
- `NEWS.md`: 已经包含 `0.9.0` 开发版本说明
- GitHub releases/tags: 当前没有发布打包 release 或 tag

因为 `NEWS.md` 可能领先于包版本，`ConvertHomologs()`、`RunCytoSPACE()`、`SpatialSpotPlot()` 这类 HEAD/development API 需要加门控：生成可运行代码前，应该先确认本机已安装包或已检查的 upstream `NAMESPACE` 中确实导出了这些函数。

## 如何使用

- **显式调用：** 这个 skill 只应在用户直接写出 `$use-scop` 时启动。

- **默认运行环境：** 默认生成 R 代码，并假设目标环境已经安装 SCOP；默认数据结构是 Seurat 对象，除非用户明确说明其他格式。

- **在 Codex 中安装：** 可以把这个 skill 下载到本地 Codex skills 目录。

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.codex/skills/use-scop
```

- **在 Claude Code 中使用：** 可以把这个 skill 下载到 Claude Code 的本地 skills 目录。

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.claude/skills/use-scop
```

- **在 Cursor 中使用：** 可以把这个 skill 下载到 Cursor 的本地 skills 目录。

```bash
mkdir -p ~/.cursor/skills
git clone https://github.com/LeonYiFan/use-scop.git ~/.cursor/skills/use-scop
```

- **没有 skill 系统的对话式助手：** 把 `SKILL.md` 和 `task_router.yaml` 作为上下文粘贴或上传，然后用 `$use-scop` 开始请求。

- **安装 SCOP 包：** 如果要真正运行生成出来的代码，需要在目标 R 环境中安装 SCOP。

```r
if (!require("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("mengxu98/scop")
```

- **SCOP 源码仓库：** 使用这个 skill 不要求把 SCOP 源码仓库克隆到本地。这个 skill 只要求 AI 工具能够读取 `SKILL.md` 和 `task_router.yaml`；真正运行生成代码的 R 环境需要已经安装 `scop`。

- **推荐保留本地 SCOP 源码：** 为了让支持本地源码检索的 AI 工具获得更好的上下文，建议同时把 SCOP 本体源码保存在本地。

```bash
mkdir -p ~/src
git clone https://github.com/mengxu98/scop.git ~/src/scop
```

- **示例 prompt：**

  - `$use-scop write a QC, preprocessing, UMAP, clustering, and marker workflow for my Seurat object.`
  - `$use-scop convert this Seurat-only pipeline into SCOP-first code with explicit fallback only where SCOP has no route.`
  - `$use-scop use SCOP for CellChat or CellphoneDB communication analysis and plot the results with CCC plots.`
  - `$use-scop tell me whether this spatial CytoSPACE workflow is available in my installed SCOP version.`

## 项目定位

这是一个面向 AI 编程和科研助手的社区维护 skill。它不是 SCOP 官方仓库，也不隶属于 upstream SCOP 项目。
