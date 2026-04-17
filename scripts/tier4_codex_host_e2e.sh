#!/usr/bin/env bash
# ============================================================================
# Tier 4: Codex host E2E black-box validation
# 维护工具，非 skill 运行时的一部分。
# 在临时宿主仓库里只用 Codex 验证安装链路和真实开发闭环。
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/tier4_codex_host_e2e.sh [options]

Options:
  --mode <local|remote>      Validation source mode. Default: local
  --source-ref <REF>         Source ref label. Default: HEAD or HEAD+dirty in local mode, refs/heads/main in remote mode
  --repo <owner/name>        GitHub repo slug for remote mode. Default: bigwhite37/harness_skills
  --sample-repo <URL>        Host sample repo URL. Default: Pytest-with-Eric/pytest-fastapi-crud-example
  --host-dir <PATH>          Existing empty directory to use instead of a temp directory
  --host-env <NAME>          Conda env used for Python validation. Default: py310
  --model <MODEL>            Codex model. Default: gpt-5.4
  --reasoning <EFFORT>       Reasoning effort. Default: xhigh
  --cleanup                  Remove the temp host directory after a successful run
  -h, --help                 Show this help
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_fixed_string() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if ! grep -Fq "$needle" "$file"; then
    echo "Missing required audit evidence ($label): $needle in $file" >&2
    exit 1
  fi
}

MODE="local"
SOURCE_REF=""
REPO_FULL_NAME="bigwhite37/harness_skills"
SAMPLE_REPO_URL="https://github.com/Pytest-with-Eric/pytest-fastapi-crud-example.git"
HOST_DIR=""
HOST_ENV="py310"
MODEL="gpt-5.4"
REASONING="xhigh"
CLEANUP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --source-ref)
      SOURCE_REF="${2:-}"
      shift 2
      ;;
    --repo)
      REPO_FULL_NAME="${2:-}"
      shift 2
      ;;
    --sample-repo)
      SAMPLE_REPO_URL="${2:-}"
      shift 2
      ;;
    --host-dir)
      HOST_DIR="${2:-}"
      shift 2
      ;;
    --host-env)
      HOST_ENV="${2:-}"
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      shift 2
      ;;
    --reasoning)
      REASONING="${2:-}"
      shift 2
      ;;
    --cleanup)
      CLEANUP=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$MODE" != "local" && "$MODE" != "remote" ]]; then
  echo "Unsupported --mode: $MODE" >&2
  exit 2
fi

require_cmd git
require_cmd codex
require_cmd conda
require_cmd curl

if ! conda env list | awk '{print $1}' | grep -qx "$HOST_ENV"; then
  echo "Conda environment not found: $HOST_ENV" >&2
  exit 1
fi

if [[ -z "$SOURCE_REF" ]]; then
  if [[ "$MODE" == "local" ]]; then
    BASE_SHA="$(git -C "$ROOT" rev-parse HEAD)"
    if git -C "$ROOT" diff --quiet && git -C "$ROOT" diff --cached --quiet; then
      SOURCE_REF="$BASE_SHA"
    else
      SOURCE_REF="working-tree:${BASE_SHA}+dirty"
    fi
  else
    SOURCE_REF="refs/heads/main"
  fi
fi

if [[ "$MODE" == "remote" ]]; then
  bash "$ROOT/scripts/check_remote_install.sh" --ref "$SOURCE_REF" --repo "$REPO_FULL_NAME"
fi

if [[ -z "$HOST_DIR" ]]; then
  HOST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/cdf-tier4-host.XXXXXX")"
  HOST_REPO="$HOST_ROOT/host"
else
  HOST_ROOT="$HOST_DIR"
  HOST_REPO="$HOST_DIR"
  if [[ -e "$HOST_REPO" && -n "$(find "$HOST_REPO" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
    echo "--host-dir must be empty: $HOST_REPO" >&2
    exit 1
  fi
  mkdir -p "$HOST_REPO"
fi

RUN_ID="tier4-$(date +%Y%m%dT%H%M%S)"
ARTIFACT_DIR="$HOST_REPO/.convergent-dev-flow/runs/$RUN_ID"
PROMPT_FILE="$HOST_ROOT/tier4_codex_prompt.md"
LAST_MESSAGE_FILE="$HOST_ROOT/tier4_codex_last_message.txt"

echo "=== Tier 4 Codex host E2E ==="
echo "mode: $MODE"
echo "source_ref: $SOURCE_REF"
echo "host_env: $HOST_ENV"
echo "model: $MODEL"
echo "reasoning: $REASONING"
echo "host_repo: $HOST_REPO"
echo "artifacts: $ARTIFACT_DIR"
echo ""

git clone "$SAMPLE_REPO_URL" "$HOST_REPO" >/dev/null 2>&1
git -C "$HOST_REPO" checkout -b "validation/$RUN_ID" >/dev/null 2>&1

cat >"$PROMPT_FILE" <<EOF
This is a black-box maintenance validation for the \`convergent-dev-flow\` skill.

Hard requirements:
- Do not ask the user clarifying questions. Make reasonable assumptions and finish the work.
- Use Codex only. Do not use Claude or any other agent.
- Keep all runtime artifacts for this validation under: \`$ARTIFACT_DIR\`
- The artifact directory must contain:
  - \`install-audit.md\`
  - \`workflow-audit.md\`
  - \`01-reframe.md\`
  - \`02-plan.md\`
  - \`03-ticket.md\`
  - \`04-review.md\`
  - \`05-verify.md\`
  - \`06-retro.md\`
  - \`verify-evidence.txt\`
- When Python commands are needed, first switch into the conda environment \`$HOST_ENV\` with \`conda activate $HOST_ENV\`.
- Before doing Python work, prove the environment actually changed by recording fresh output from \`python --version\` and \`which python\`.
- If dependencies are missing, install only the necessary Python packages with pip inside the activated \`$HOST_ENV\`.
- End in exactly one truthful state: \`verified\`, \`blocked\`, or \`reframe-needed\`.
- Keep implementation scope minimal.
- The integrated audit must be explicit, not implicit:
  - \`install-audit.md\` must record \`GSTACK_SOURCE_REPO\`, \`GSTACK_REV\`, \`SUPERPOWERS_SOURCE_REPO\`, \`SUPERPOWERS_PROVENANCE\`, and direct availability evidence for both dependency sets.
  - \`01-reframe.md\` must include \`gstack /office-hours\`.
  - \`02-plan.md\` must include \`gstack /plan-ceo-review\` and \`gstack /plan-eng-review\`.
  - \`workflow-audit.md\` must include \`superpowers:test-driven-development\`.
  - \`04-review.md\` must include \`gstack /review\`.
  - \`05-verify.md\` must include \`superpowers:verification-before-completion\`.
  - \`06-retro.md\` must include \`gstack /retro\`.
- This host validation is backend API only. Unless your verify contract genuinely requires real browser acceptance, do not invent a \`gstack /qa\` requirement.

Installation source:
EOF

if [[ "$MODE" == "remote" ]]; then
  cat >>"$PROMPT_FILE" <<EOF
- Fetch and follow instructions from https://raw.githubusercontent.com/$REPO_FULL_NAME/$SOURCE_REF/INSTALL.md
- Record \`SOURCE_REF: $SOURCE_REF\` in the install audit.
EOF
else
  cat >>"$PROMPT_FILE" <<EOF
- Use the local source repo at \`$ROOT\` as the installation source and follow its \`INSTALL.md\` contract as closely as possible.
- Treat the source as an unpublished candidate and record \`SOURCE_REF: $SOURCE_REF\` in the install audit.
- Do not claim public remote-install coverage for this local candidate unless you can prove the published raw URL returns 200.
EOF
fi

cat >>"$PROMPT_FILE" <<'EOF'

Validation task:
- Install the skill into this host repo.
- Explicitly trigger `$convergent-dev-flow`.
- Implement a bounded feature for the host API:
  - soft delete instead of hard delete
  - default list hides deleted records
  - `include_deleted=true` returns deleted records
  - restore endpoint
  - tests updated accordingly
- Keep `review` and `verify` separate.
- Save fresh executed verification evidence to `verify-evidence.txt`.
- Final response should name the final state and the artifact directory.
EOF

codex exec \
  -m "$MODEL" \
  -c "reasoning_effort=\"$REASONING\"" \
  --dangerously-bypass-approvals-and-sandbox \
  -C "$HOST_REPO" \
  -o "$LAST_MESSAGE_FILE" \
  "$(cat "$PROMPT_FILE")"

for required in \
  "$ARTIFACT_DIR/install-audit.md" \
  "$ARTIFACT_DIR/workflow-audit.md" \
  "$ARTIFACT_DIR/01-reframe.md" \
  "$ARTIFACT_DIR/02-plan.md" \
  "$ARTIFACT_DIR/03-ticket.md" \
  "$ARTIFACT_DIR/04-review.md" \
  "$ARTIFACT_DIR/05-verify.md" \
  "$ARTIFACT_DIR/06-retro.md" \
  "$ARTIFACT_DIR/verify-evidence.txt"
do
  if [[ ! -f "$required" ]]; then
    echo "Missing required artifact: $required" >&2
    exit 1
  fi
done

INSTALL_AUDIT="$ARTIFACT_DIR/install-audit.md"
WORKFLOW_AUDIT="$ARTIFACT_DIR/workflow-audit.md"

require_fixed_string "$INSTALL_AUDIT" 'GSTACK_SOURCE_REPO' 'gstack source repo'
require_fixed_string "$INSTALL_AUDIT" 'GSTACK_REV' 'gstack revision'
require_fixed_string "$INSTALL_AUDIT" 'SUPERPOWERS_SOURCE_REPO' 'superpowers source repo'
require_fixed_string "$INSTALL_AUDIT" 'SUPERPOWERS_PROVENANCE' 'superpowers provenance'
require_fixed_string "$INSTALL_AUDIT" 'office-hours' 'gstack availability evidence'
require_fixed_string "$INSTALL_AUDIT" 'test-driven-development' 'superpowers availability evidence'

require_fixed_string "$ARTIFACT_DIR/01-reframe.md" 'gstack /office-hours' 'reframe gstack invocation'
require_fixed_string "$ARTIFACT_DIR/02-plan.md" 'gstack /plan-ceo-review' 'plan CEO review invocation'
require_fixed_string "$ARTIFACT_DIR/02-plan.md" 'gstack /plan-eng-review' 'plan ENG review invocation'
require_fixed_string "$WORKFLOW_AUDIT" 'superpowers:test-driven-development' 'build TDD invocation'
require_fixed_string "$ARTIFACT_DIR/04-review.md" 'gstack /review' 'review gstack invocation'
require_fixed_string "$ARTIFACT_DIR/05-verify.md" 'superpowers:verification-before-completion' 'verify superpowers invocation'
require_fixed_string "$ARTIFACT_DIR/06-retro.md" 'gstack /retro' 'retro gstack invocation'

CONDA_BASE="$(conda info --base)"
(
  source "$CONDA_BASE/etc/profile.d/conda.sh"
  conda activate "$HOST_ENV"
  cd "$HOST_REPO"
  python --version
  which python
  python -m pytest -q
) | tee "$HOST_ROOT/tier4-independent-verify.txt"

echo ""
echo "PASS  tier4-codex-host-e2e"
echo "HOST_REPO=$HOST_REPO"
echo "ARTIFACT_DIR=$ARTIFACT_DIR"
echo "LAST_MESSAGE_FILE=$LAST_MESSAGE_FILE"

if $CLEANUP; then
  rm -rf "$HOST_ROOT"
  echo "CLEANUP=removed $HOST_ROOT"
fi
