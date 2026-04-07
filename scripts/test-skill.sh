#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_SCOP_REPO="$(cd "$ROOT_DIR/.." && pwd)/scop"
SCOP_REPO="${SCOP_REPO:-$DEFAULT_SCOP_REPO}"
WITH_CODEX_CLI=0

for arg in "$@"; do
  case "$arg" in
    --with-codex-cli)
      WITH_CODEX_CLI=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--with-codex-cli]" >&2
      exit 2
      ;;
  esac
done

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

search_ere() {
  local pattern="$1"
  shift

  if command -v rg >/dev/null 2>&1; then
    rg -n -e "$pattern" "$@"
  else
    grep -En "$pattern" "$@"
  fi
}

run_codex_case() {
  local name="$1"
  local prompt="$2"
  local expect="$3"
  local reject="${4:-}"
  local output_file
  local full_prompt

  output_file="$(mktemp)"
  full_prompt="$prompt"$'\n\n'"请简短回答，不要检查仓库，不要运行命令，只根据当前 skill 规则直接回复。"
  echo "Running Codex CLI regression: $name"
  if ! timeout 120s codex exec \
    --sandbox read-only \
    --skip-git-repo-check \
    --output-last-message "$output_file" \
    --color never \
    "$full_prompt" >/dev/null; then
    rm -f "$output_file"
    fail "codex exec failed for case: $name"
  fi

  if ! grep -Eq "$expect" "$output_file"; then
    echo "---- output ($name) ----" >&2
    cat "$output_file" >&2
    echo "------------------------" >&2
    rm -f "$output_file"
    fail "expected pattern not found for case '$name': $expect"
  fi

  if [[ -n "$reject" ]] && grep -Eq "$reject" "$output_file"; then
    echo "---- output ($name) ----" >&2
    cat "$output_file" >&2
    echo "------------------------" >&2
    rm -f "$output_file"
    fail "reject pattern matched for case '$name': $reject"
  fi

  rm -f "$output_file"
  pass "Codex CLI regression passed: $name"
}

require_cmd Rscript

cd "$ROOT_DIR"

[[ -f "SKILL.md" ]] || fail "SKILL.md not found"
[[ -f "README.md" ]] || fail "README.md not found"
[[ -f "agents/openai.yaml" ]] || fail "agents/openai.yaml not found"
[[ -f "references/scop-function-map.md" ]] || fail "references/scop-function-map.md not found"

echo "Running static skill checks"

[[ -f "$SCOP_REPO/NAMESPACE" ]] || fail "upstream scop NAMESPACE not found; set SCOP_REPO=/path/to/scop"

search_ere '^export\((RunDimsReduction|RunDimsEstimate|h5ad_to_srt|RunCellphoneDB|RunNichenetr|RunMultiNichenetr|CCCStatPlot|CCCHeatmap|CCCNetworkPlot|RunGSVA|RunMetabolism|RunDecontX)\)' \
  "$SCOP_REPO/NAMESPACE" >/dev/null || fail "expected 0.8.7 exports not found in upstream scop"
pass "upstream scop exports include the expected 0.8.7 functions"

if ! Rscript -e 'quit(status = if (requireNamespace("scop", quietly = TRUE)) 0 else 1)' >/dev/null 2>&1; then
  fail "installed R environment cannot find package 'scop'"
fi
pass "installed R environment can load namespace 'scop'"

INSTALLED_VERSION="$(Rscript -e 'cat(as.character(utils::packageVersion("scop")))' 2>/dev/null || true)"
if [[ -z "$INSTALLED_VERSION" ]]; then
  fail "could not determine installed scop version"
fi
echo "Detected installed scop version: $INSTALLED_VERSION"

search_ere 'RunDimReduction|CellChatPlot|group_by|num_threads' \
  SKILL.md README.md references/scop-function-map.md agents/openai.yaml >/dev/null || fail "expected version-guard guidance not found"
pass "skill documents include guidance against stale interfaces"

if [[ "$WITH_CODEX_CLI" -eq 1 ]]; then
  require_cmd codex
  run_codex_case \
    "missing-package-guidance" \
    '$use-scop 当前 R 环境没有安装 scop。请帮我写一段可直接运行的 scop QC + UMAP 代码。' \
    'pak::pak\("mengxu98/scop"\)|install\.packages\("pak"\)' \
    ''

  run_codex_case \
    "dimension-selection" \
    '$use-scop 用 scop 做降维，并自动选择合适维度。' \
    'RunDimsReduction|RunDimsEstimate|DimsEstimatePlot' \
    'RunDimReduction'

  run_codex_case \
    "cell-cell-communication" \
    '$use-scop 用 scop 做细胞通讯分析并画图。' \
    'CCCStatPlot|CCCHeatmap|CCCNetworkPlot|RunCellphoneDB|RunNichenetr|RunMultiNichenetr|RunCellChat' \
    'CellChatPlot'
fi

pass "all requested skill tests completed"
