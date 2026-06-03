#!/usr/bin/env bash
# Start Forge in the background (survives closing this terminal tab)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG="$PROJECT_ROOT/outputs/forge.log"
mkdir -p "$PROJECT_ROOT/outputs"

if curl -sf http://127.0.0.1:7860/sdapi/v1/options -o /dev/null 2>/dev/null; then
  echo "Forge already running at http://127.0.0.1:7860"
  exit 0
fi

nohup "$SCRIPT_DIR/launch-forge.sh" >>"$LOG" 2>&1 &
echo "Forge starting in background (PID $!)"
echo "Log: $LOG"
echo "UI:  http://127.0.0.1:7860"
echo "Stop: pkill -f 'stable-diffusion-webui-forge/launch.py'"