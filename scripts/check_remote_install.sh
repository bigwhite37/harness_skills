#!/usr/bin/env bash
# ============================================================================
# Published remote install probe
# 维护工具，非 skill 运行时的一部分。
# 验证某个已发布 ref 的 raw INSTALL.md 是否可直接访问。
# ============================================================================

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/check_remote_install.sh --ref <REF> [--repo <owner/name>]

Options:
  --ref   Published branch/tag/commit ref to probe, e.g. refs/heads/main
  --repo  GitHub repository slug, default: bigwhite37/harness_skills
EOF
}

REPO_FULL_NAME="bigwhite37/harness_skills"
REF=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      REF="${2:-}"
      shift 2
      ;;
    --repo)
      REPO_FULL_NAME="${2:-}"
      shift 2
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

if [[ -z "$REF" ]]; then
  echo "Missing required --ref" >&2
  usage >&2
  exit 2
fi

RAW_URL="https://raw.githubusercontent.com/${REPO_FULL_NAME}/${REF}/INSTALL.md"
TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/cdf-remote-install.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT

HTTP_CODE="$(
  curl -L -sS -o "$TMP_FILE" -w '%{http_code}' --max-time 20 "$RAW_URL"
)"

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "FAIL  remote-install-probe  — ${RAW_URL} returned HTTP ${HTTP_CODE}" >&2
  exit 1
fi

if ! grep -q 'Installing `convergent-dev-flow` Into a Host Repository' "$TMP_FILE"; then
  echo "FAIL  remote-install-probe  — fetched file does not look like INSTALL.md" >&2
  exit 1
fi

echo "PASS  remote-install-probe"
echo "REPO=${REPO_FULL_NAME}"
echo "REF=${REF}"
echo "RAW_URL=${RAW_URL}"
