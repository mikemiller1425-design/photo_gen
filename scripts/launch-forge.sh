#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_defaults

cd "$FORGE_DIR"

# Forge requires Python 3.10 (system 3.14 breaks torch install)
PYTHON310="${PYTHON310:-/opt/homebrew/bin/python3.10}"
if [[ ! -x "$PYTHON310" ]]; then
  echo "Python 3.10 required. Install: brew install python@3.10" >&2
  exit 1
fi

# Remove broken venv if it was built with the wrong Python
if [[ -d venv ]]; then
  VENV_PY="$(venv/bin/python -c 'import sys; print(sys.version_info[:2])' 2>/dev/null || echo "")"
  if [[ "$VENV_PY" != "(3, 10)" ]]; then
    echo "Removing incompatible venv (need Python 3.10)..."
    rm -rf venv
  fi
fi

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
