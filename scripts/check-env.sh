#!/usr/bin/env bash
# Verify local setup: folders, reference image, Forge API, optional Draw Things

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_defaults

echo "=== photo_gen environment check ==="
echo "Project: $PROJECT_ROOT"
echo

ok=true

for dir in prompts outputs models scripts references config; do
  if [[ -d "$PROJECT_ROOT/$dir" ]]; then
    echo "[ok] $dir/"
  else
    echo "[missing] $dir/"
    ok=false
  fi
done

echo
if [[ -f "$PROJECT_ROOT/$REF_IMAGE" ]]; then
  echo "[ok] Reference image: $REF_IMAGE"
else
  echo "[action] Add baseline photo: $PROJECT_ROOT/$REF_IMAGE"
  ok=false
fi

model_count=$(find "$PROJECT_ROOT/models" -maxdepth 1 \( -name '*.safetensors' -o -name '*.ckpt' \) 2>/dev/null | wc -l | tr -d ' ')
if [[ "$model_count" -gt 0 ]]; then
  echo "[ok] Checkpoints in models/: $model_count"
else
  echo "[action] Download a .safetensors checkpoint into models/ (see models/README.md)"
fi

echo
if [[ -d "$FORGE_DIR" ]]; then
  echo "[ok] Forge directory: $FORGE_DIR"
else
  echo "[optional] Forge not installed — run: ./scripts/setup-forge.sh"
fi

if curl -sf "${WEBUI_API}/options" -o /dev/null 2>/dev/null; then
  echo "[ok] WebUI API reachable at $WEBUI_URL"
else
  echo "[wait] WebUI API not running at $WEBUI_URL (start Forge with ./webui.sh)"
fi

if [[ -d "/Applications/Draw Things.app" ]]; then
  echo "[ok] Draw Things.app found (Mac fallback)"
else
  echo "[info] Draw Things not installed — optional App Store fallback"
fi

echo
if $ok; then
  echo "Core project layout looks good."
else
  echo "Complete the [action] items above, then re-run this script."
fi