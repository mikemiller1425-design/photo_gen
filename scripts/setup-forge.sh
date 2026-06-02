#!/usr/bin/env bash
# Install Stable Diffusion WebUI Forge for Apple Silicon (M4) and link project folders

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_defaults

echo "=== photo_gen — Forge setup (Apple Silicon) ==="
echo "Forge will install to: $FORGE_DIR"
echo "Project models:      $PROJECT_ROOT/models"
echo

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is tuned for macOS Apple Silicon. Continue only if you know your platform flags." >&2
fi

# Dependencies
if ! command -v python3 &>/dev/null; then
  echo "python3 is required. Install Xcode CLT or Homebrew python." >&2
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "git is required." >&2
  exit 1
fi

# Clone Forge
if [[ ! -d "$FORGE_DIR/.git" ]]; then
  echo "Cloning Stable Diffusion WebUI Forge..."
  git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git "$FORGE_DIR"
else
  echo "Forge already cloned — pulling latest..."
  git -C "$FORGE_DIR" pull --ff-only || echo "Pull skipped (local changes or offline)."
fi

# Link models directory
FORGE_CKPT="$FORGE_DIR/models/Stable-diffusion"
mkdir -p "$FORGE_CKPT"
if [[ ! -L "$FORGE_CKPT/photo_gen_models" ]]; then
  ln -sf "$PROJECT_ROOT/models" "$FORGE_CKPT/photo_gen_models"
  echo "Linked models → $FORGE_CKPT/photo_gen_models"
fi

# Mac launch wrapper
LAUNCHER="$PROJECT_ROOT/scripts/launch-forge.sh"
cat > "$LAUNCHER" <<'LAUNCH'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_defaults

cd "$FORGE_DIR"

# Apple Silicon (M4): MPS backend, avoid half-precision issues on Mac
export COMMANDLINE_ARGS="${COMMANDLINE_ARGS:---skip-torch-cuda-test --upcast-sampling --no-half-vae --listen --api}"

if [[ "$(uname -m)" == "arm64" ]]; then
  export PYTORCH_ENABLE_MPS_FALLBACK=1
  # Uncomment if your Forge build supports --use-mps:
  # export COMMANDLINE_ARGS="$COMMANDLINE_ARGS --use-mps"
fi

echo "Starting Forge at http://127.0.0.1:7860 (API enabled)"
echo "COMMANDLINE_ARGS=$COMMANDLINE_ARGS"
./webui.sh
LAUNCH
chmod +x "$LAUNCHER"

# webui-user.sh overrides (idempotent append)
USER_SH="$FORGE_DIR/webui-user.sh"
if [[ ! -f "$USER_SH" ]] || ! grep -q "photo_gen" "$USER_SH" 2>/dev/null; then
  cat >> "$USER_SH" <<EOF

# --- photo_gen overrides ---
export COMMANDLINE_ARGS="\${COMMANDLINE_ARGS} --skip-torch-cuda-test --upcast-sampling --no-half-vae --listen --api"
# --- end photo_gen ---
EOF
  echo "Updated $USER_SH"
fi

echo
echo "=== Setup complete ==="
echo
echo "Next steps:"
echo "  1. Put a checkpoint in: $PROJECT_ROOT/models/"
echo "  2. Add baseline photo:  $PROJECT_ROOT/$REF_IMAGE"
echo "  3. Start Forge:         ./scripts/launch-forge.sh"
echo "  4. In Forge UI: Settings → API → enable (if needed), load your checkpoint"
echo "  5. Generate:            ./scripts/generate.sh prompts/scenes/volleyball-spectator-nike-pro-black.txt"
echo
echo "Mac fallback: Install 'Draw Things' from the App Store and import prompts manually."