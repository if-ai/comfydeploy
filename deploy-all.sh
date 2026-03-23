#!/usr/bin/env bash
# ComfyDeploy full stack deploy — API then Web via VPS tar+scp fallback
#
# Usage: ./deploy-all.sh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "=========================================="
echo " ComfyDeploy Full Stack Deploy"
echo "=========================================="

echo ""
echo ">>> Deploying API ..."
echo ""
"$SCRIPT_DIR/deploy-api.sh"

echo ""
echo ">>> Deploying Web ..."
echo ""
"$SCRIPT_DIR/deploy-web.sh"

echo ""
echo "=========================================="
echo " Full stack deploy complete"
echo "=========================================="
echo ""
echo "Verifying live services..."
ssh -o StrictHostKeyChecking=no root@impactframes-vps \
  "docker service ls --format '{{.Name}} {{.Image}}' | grep -i 'comfydeploy'"

echo ""
echo "Smoke checks..."
curl -sI https://comfy.impactframes.ai/ | head -1
curl -sI https://api.comfy.impactframes.ai/api/platform/gpu-credit-schema | head -1
echo ""
echo "Done."
