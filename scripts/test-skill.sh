#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_CODEX_CLI=0
WITH_UPSTREAM=1

for arg in "$@"; do
  case "$arg" in
    --with-codex-cli)
      WITH_CODEX_CLI=1
      ;;
    --offline)
      WITH_UPSTREAM=0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--with-codex-cli] [--offline]" >&2
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

resolve_python() {
  local candidate
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; sys.exit(0)' >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done
  fail "a working python3 or python command is required"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

search_ere() {
  local pattern="$1"
  shift

  if command -v rg >/dev/null 2>&1 && [[ "$(uname -s)" != MINGW* ]]; then
    rg -n -e "$pattern" "$@"
  else
    grep -En "$pattern" "$@"
  fi
}

reject_ere() {
  local pattern="$1"
  shift

  if search_ere "$pattern" "$@" >/dev/null; then
    search_ere "$pattern" "$@" >&2 || true
    fail "unexpected pattern found: $pattern"
  fi
}

require_ere() {
  local pattern="$1"
  shift

  search_ere "$pattern" "$@" >/dev/null || fail "expected pattern not found: $pattern"
}

validate_skill_frontmatter() {
  "$PYTHON_CMD" - <<'PY'
from pathlib import Path
import sys

try:
    import yaml
except Exception as exc:
    print(f"PyYAML is required to validate SKILL.md frontmatter: {exc}", file=sys.stderr)
    sys.exit(1)

text = Path("SKILL.md").read_text(encoding="utf-8")
if not text.startswith("---\n"):
    print("SKILL.md must start with YAML frontmatter", file=sys.stderr)
    sys.exit(1)

try:
    frontmatter = text.split("---", 2)[1]
    data = yaml.safe_load(frontmatter)
except Exception as exc:
    print(f"SKILL.md frontmatter is not valid YAML: {exc}", file=sys.stderr)
    sys.exit(1)

if data.get("name") != "use-scop":
    print("SKILL.md frontmatter name must be use-scop", file=sys.stderr)
    sys.exit(1)

description = data.get("description")
if not isinstance(description, str) or not description.strip():
    print("SKILL.md frontmatter description must be a non-empty string", file=sys.stderr)
    sys.exit(1)

if len(description) > 1024:
    print("SKILL.md frontmatter description must be at most 1024 characters", file=sys.stderr)
    sys.exit(1)

if set(data) != {"name", "description"}:
    print("SKILL.md frontmatter must contain only name and description", file=sys.stderr)
    sys.exit(1)

try:
    router = yaml.safe_load(Path("task_router.yaml").read_text(encoding="utf-8"))
except Exception as exc:
    print(f"task_router.yaml is not valid YAML: {exc}", file=sys.stderr)
    sys.exit(1)

if not isinstance(router, dict) or not isinstance(router.get("domains"), dict):
    print("task_router.yaml must contain a domains mapping", file=sys.stderr)
    sys.exit(1)
PY
}

run_codex_case() {
  local name="$1"
  local prompt="$2"
  local expect="$3"
  local reject="${4:-}"
  local output_file
  local full_prompt

  output_file="$(mktemp)"
  full_prompt="$prompt"$'\n\n'"Please answer briefly. Do not inspect the repository and do not run commands; respond only from the active skill rules."
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

cd "$ROOT_DIR"

[[ -f "SKILL.md" ]] || fail "SKILL.md not found"
[[ -f "README.md" ]] || fail "README.md not found"
[[ -f "README.zh-CN.md" ]] || fail "README.zh-CN.md not found"
[[ -f "task_router.yaml" ]] || fail "task_router.yaml not found"
[[ -f "agents/openai.yaml" ]] || fail "agents/openai.yaml not found"
[[ -f "TESTING.md" ]] || fail "TESTING.md not found"
[[ -x "scripts/install-user-skill.sh" ]] || fail "scripts/install-user-skill.sh not found or not executable"
[[ -f "references/scop-function-map.md" ]] && fail "legacy references/scop-function-map.md should not exist"

echo "Running static skill checks"

PYTHON_CMD="$(resolve_python)"
validate_skill_frontmatter
pass "SKILL.md frontmatter and task_router.yaml are valid YAML"

require_ere '^name: use-scop$' SKILL.md
require_ere '\$use-scop' SKILL.md README.md README.zh-CN.md agents/openai.yaml
require_ere '/use-scop' SKILL.md README.md README.zh-CN.md
require_ere 'task_router\.yaml' SKILL.md README.md README.zh-CN.md agents/openai.yaml
require_ere 'version: 0\.8\.9' task_router.yaml
require_ere '2026-06-28' README.md README.zh-CN.md task_router.yaml
require_ere 'requires_export_check' SKILL.md task_router.yaml
require_ere 'scop_first_narrow_fallback' task_router.yaml
reject_ere 'disable-model-invocation' SKILL.md
require_ere 'allow_implicit_invocation: false' agents/openai.yaml
pass "core metadata and routing files are present"

reject_ere '0\.8\.7' SKILL.md README.md README.zh-CN.md task_router.yaml agents/openai.yaml TESTING.md
reject_ere 'scop::(RunDimReduction|CellChatPlot)' SKILL.md task_router.yaml README.md README.zh-CN.md agents/openai.yaml
pass "stale 0.8.7 baseline and old positive routes are absent"

require_ere 'RunDimsReduction' SKILL.md task_router.yaml
require_ere 'CCCStatPlot|CCCHeatmap|CCCNetworkPlot' SKILL.md task_router.yaml
reject_ere 'scop::RunBulk' task_router.yaml
require_ere 'known_unexported' task_router.yaml
require_ere 'scop::loom_to_srt' task_router.yaml
require_ere 'scop::loom_to_adata' task_router.yaml
require_ere 'scop::RunMilo' task_router.yaml
require_ere 'scop::RunLIANA' task_router.yaml
require_ere 'scop::RunDorothea' task_router.yaml
require_ere 'scop::RunBayesSpace' task_router.yaml
require_ere 'scop::RunscTenifoldKnk' task_router.yaml
require_ere 'scop::GLUE_integrate' task_router.yaml
require_ere 'scop::MultiMAP_integrate' task_router.yaml
require_ere 'scop::WNN_integrate' task_router.yaml
require_ere 'scop::RunCNV' task_router.yaml
require_ere 'scop::RunESTIMATE' task_router.yaml
require_ere 'scop::RunSCENIC' task_router.yaml
require_ere 'scop::RunSpatialIntegration' task_router.yaml
require_ere 'scop::RunSpatialNetwork' task_router.yaml
require_ere 'scop::RunDeconvolution' task_router.yaml
pass "current SCOP routes are represented"

require_ere 'scop::ConvertHomologs' task_router.yaml
require_ere 'scop::RunCytoSPACE' task_router.yaml
require_ere 'scop::SpatialSpotPlot' task_router.yaml
require_ere 'main_commit: "32cb4855"' task_router.yaml
require_ere 'HEAD-sensitive|HEAD-sensitive' SKILL.md README.md
pass "upstream main snapshot and runtime gates are recorded"

require_ere 'Codex' README.md README.zh-CN.md
require_ere 'Claude Code' README.md README.zh-CN.md
require_ere 'Cursor' README.md README.zh-CN.md
require_ere 'install-user-skill\.sh' README.md README.zh-CN.md TESTING.md
require_ere '~/.codex/skills/use-scop' README.md README.zh-CN.md
require_ere '~/.claude/skills/use-scop' README.md README.zh-CN.md
require_ere '~/.cursor/skills/use-scop' README.md README.zh-CN.md
require_ere '\.claude/skills/use-scop' README.md README.zh-CN.md
require_ere '\.cursor/skills/use-scop' README.md README.zh-CN.md
require_ere 'Do not install.*~/.cursor/skills-cursor|不要把.*~/.cursor/skills-cursor' README.md README.zh-CN.md
reject_ere 'git clone .*~/.cursor/skills-cursor|mkdir -p ~/.cursor/skills-cursor' README.md README.zh-CN.md
require_ere 'not an official SCOP repository|不是 SCOP 官方仓库' README.md README.zh-CN.md
pass "public README files cover installation targets and positioning"

if [[ "$WITH_UPSTREAM" -eq 1 ]]; then
  require_cmd curl

  DESCRIPTION_URL="https://raw.githubusercontent.com/mengxu98/scop/HEAD/DESCRIPTION"
  NAMESPACE_URL="https://raw.githubusercontent.com/mengxu98/scop/HEAD/NAMESPACE"
  DESCRIPTION_TEXT="$(curl -fsSL "$DESCRIPTION_URL")"
  NAMESPACE_TEXT="$(curl -fsSL "$NAMESPACE_URL")"

  grep -Eq 'Version:[[:space:]]+0\.8\.9' <<<"$DESCRIPTION_TEXT" || fail "upstream DESCRIPTION is not 0.8.9"
  grep -Eq 'Date:[[:space:]]+2026-06-28' <<<"$DESCRIPTION_TEXT" || fail "upstream DESCRIPTION date mismatch"
  for export_name in $(grep -oE 'scop::[A-Za-z0-9_.]+' task_router.yaml | sed 's/scop:://' | sort -u); do
    grep -Eq "export\\(${export_name}\\)" <<<"$NAMESPACE_TEXT" || fail "expected upstream export not found: $export_name"
  done
  pass "upstream metadata and all routed exports passed"
fi

if [[ "$WITH_CODEX_CLI" -eq 1 ]]; then
  require_cmd codex

  run_codex_case \
    "qc-umap" \
    '$use-scop Write QC, preprocessing, UMAP, clustering, and marker code for my Seurat object.' \
    'RunCellQC|standard_scop|RunDimsReduction|CellDimPlot|FeatureDimPlot' \
    'RunDimReduction|CellChatPlot'

  run_codex_case \
    "bulk-deconvolution" \
    '$use-scop Write a bulk deconvolution and enrichment workflow.' \
    'RunDeconvolution|RunCIBERSORT|RunEnrichment|RunGSEA|EnrichmentPlot' \
    'RunBulk'

  run_codex_case \
    "cell-cell-communication" \
    '$use-scop Use SCOP for CellChat or CellphoneDB communication analysis and plot results.' \
    'RunCellChat|RunCellphoneDB|CCCStatPlot|CCCHeatmap|CCCNetworkPlot' \
    'CellChatPlot'

  run_codex_case \
    "current-main-cytospace" \
    '$use-scop Can I use SCOP for CytoSPACE spatial spot assignment?' \
    'RunCytoSPACE|SpatialSpotPlot|export|installed|NAMESPACE' \
    ''
fi

pass "all requested skill tests completed"
