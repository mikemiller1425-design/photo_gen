#!/usr/bin/env bash
# Run multiple scene presets in sequence (same reference, different outputs)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEN="$SCRIPT_DIR/generate.sh"

PRESETS=(
  "prompts/scenes/volleyball-spectator-nike-pro-black.txt"
  "prompts/scenes/volleyball-spectator-nike-pro-white.txt"
  "prompts/scenes/penthouse-nike-pro-red.txt"
  "prompts/backgrounds/beach.txt"
  "prompts/backgrounds/bedroom.txt"
)

echo "=== Batch generate (${#PRESETS[@]} presets) ==="
for preset in "${PRESETS[@]}"; do
  echo
  echo ">>> $preset"
  "$GEN" "$preset" "$@" || echo "Failed: $preset (continuing...)"
done
echo
echo "Done. Check outputs/"