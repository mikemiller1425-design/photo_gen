#!/usr/bin/env bash
# Shared helpers for photo_gen scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

load_defaults() {
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/config/defaults.env"
}

parse_prompt_file() {
  local file="$1"
  [[ -f "$file" ]] || { echo "Prompt file not found: $file" >&2; exit 1; }

  POSITIVE=""
  NEGATIVE=""
  local key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    [[ "$line" != *"="* ]] && continue
    key="${line%%=*}"
    value="${line#*=}"
    key="$(echo "$key" | tr '[:upper:]' '[:lower:]')"
    case "$key" in
      positive) POSITIVE="$value" ;;
      negative) NEGATIVE="$value" ;;
      denoising_strength) DENOISING_STRENGTH="$value" ;;
      cfg_scale) CFG_SCALE="$value" ;;
      steps) STEPS="$value" ;;
      sampler) SAMPLER="$value" ;;
      width) WIDTH="$value" ;;
      height) HEIGHT="$value" ;;
      seed) SEED="$value" ;;
    esac
  done < "$file"
}

check_webui() {
  if ! curl -sf "${WEBUI_API}/options" -o /dev/null; then
    echo "Forge / WebUI API not reachable at ${WEBUI_URL}" >&2
    echo "Start Forge first: cd \"\$FORGE_DIR\" && ./webui.sh --listen" >&2
    echo "Or use Draw Things manually with prompts from prompts/" >&2
    return 1
  fi
}

image_to_base64() {
  local path="$1"
  python3 - "$path" <<'PY'
import base64, sys
path = sys.argv[1]
with open(path, "rb") as f:
    print(base64.b64encode(f.read()).decode("ascii"))
PY
}

timestamp_slug() {
  date +"%Y%m%d_%H%M%S"
}