#!/usr/bin/env bash
# img2img via local Forge / A1111 API — preserves baseline pose using your reference photo

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_defaults

usage() {
  cat <<EOF
Usage: $(basename "$0") <prompt-preset.txt> [options]

Options:
  --ref PATH       Reference image (default: \$REF_IMAGE)
  --strength F     Denoising strength 0.25–0.55 (lower = closer to reference)
  --seed N         Seed (-1 = random)
  --out DIR        Output directory (default: outputs/)
  --dry-run        Print payload summary without calling API

Examples:
  $(basename "$0") prompts/scenes/volleyball-spectator-nike-pro-black.txt
  $(basename "$0") prompts/backgrounds/beach.txt --strength 0.35 --seed 42

Requires Forge running with --api: ./scripts/launch-forge.sh
EOF
}

PROMPT_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --ref) REF_IMAGE="$2"; shift 2 ;;
    --strength) DENOISING_STRENGTH="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --out) OUTPUT_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "$PROMPT_FILE" ]]; then
        PROMPT_FILE="$1"
      else
        echo "Unexpected argument: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

[[ -n "$PROMPT_FILE" ]] || { usage; exit 1; }

if [[ ! -f "$PROMPT_FILE" ]]; then
  PROMPT_FILE="$PROJECT_ROOT/$PROMPT_FILE"
fi

parse_prompt_file "$PROMPT_FILE"

[[ -n "$POSITIVE" ]] || { echo "No 'positive=' prompt in $PROMPT_FILE" >&2; exit 1; }

REF_PATH="$PROJECT_ROOT/$REF_IMAGE"
if [[ ! -f "$REF_PATH" ]]; then
  echo "Reference image missing: $REF_PATH" >&2
  echo "Copy your baseline gym photo there (see references/README.md)." >&2
  exit 1
fi

mkdir -p "$PROJECT_ROOT/$OUTPUT_DIR"
OUT_DIR="$PROJECT_ROOT/$OUTPUT_DIR"
SLUG="$(basename "$PROMPT_FILE" .txt)"
TS="$(timestamp_slug)"

echo "=== photo_gen img2img ==="
echo "Preset:    $PROMPT_FILE"
echo "Reference: $REF_PATH"
echo "Strength:  $DENOISING_STRENGTH | CFG: $CFG_SCALE | Steps: $STEPS"
echo "Size:      ${WIDTH}x${HEIGHT} | Seed: $SEED"
echo "Output:    $OUT_DIR"
echo

if $DRY_RUN; then
  echo "[dry-run] Positive (preview):"
  echo "${POSITIVE:0:240}..."
  exit 0
fi

check_webui

INIT_IMAGE="$(image_to_base64 "$REF_PATH")"
PAYLOAD_FILE="$(mktemp)"
RESPONSE="$(mktemp)"
trap 'rm -f "$PAYLOAD_FILE" "$RESPONSE"' EXIT

export INIT_IMAGE POSITIVE NEGATIVE DENOISING_STRENGTH CFG_SCALE STEPS SAMPLER WIDTH HEIGHT SEED

python3 - "$PAYLOAD_FILE" <<'PY'
import json, os, sys
path = sys.argv[1]
payload = {
    "init_images": [os.environ["INIT_IMAGE"]],
    "prompt": os.environ["POSITIVE"],
    "negative_prompt": os.environ.get("NEGATIVE", ""),
    "denoising_strength": float(os.environ["DENOISING_STRENGTH"]),
    "cfg_scale": float(os.environ["CFG_SCALE"]),
    "steps": int(os.environ["STEPS"]),
    "sampler_name": os.environ["SAMPLER"],
    "width": int(os.environ["WIDTH"]),
    "height": int(os.environ["HEIGHT"]),
    "seed": int(os.environ["SEED"]),
    "save_images": True,
    "include_init_images": False,
}
with open(path, "w") as f:
    json.dump(payload, f)
PY

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$RESPONSE" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE" \
  "${WEBUI_API}/img2img")

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "API error (HTTP $HTTP_CODE):" >&2
  cat "$RESPONSE" >&2
  exit 1
fi

SAVED=$(python3 - "$RESPONSE" "$OUT_DIR" "${OUTPUT_PREFIX}_${SLUG}_${TS}" <<'PY'
import json, sys, base64, os
resp_path, out_dir, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
with open(resp_path) as f:
    data = json.load(f)
paths = []
for i, img in enumerate(data.get("images", [])):
    out = os.path.join(out_dir, f"{prefix}_{i:02d}.png")
    with open(out, "wb") as f:
        f.write(base64.b64decode(img))
    paths.append(out)
if not paths:
    sys.exit("No images in API response")
print("\n".join(paths))
PY
)

echo "Saved:"
echo "$SAVED"