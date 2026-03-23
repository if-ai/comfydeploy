#!/usr/bin/env bash
set -e

# Configuration
COMMIT_MSG=${1:-"fix: deploy updates"}
API_DIR="apps/api"

echo "🚀 Starting ComfyDeploy deployment sequence..."

# 1. Update and Push API Submodule
echo "📦 Processing API submodule..."
if [ -d "$API_DIR" ]; then
    cd "$API_DIR"
    git add .
    # Only commit if there are changes
    if ! git diff-index --quiet HEAD --; then
        git commit -m "$COMMIT_MSG"
        echo "✅ Committed API changes"
    else
        echo "ℹ️ No changes in API submodule"
    fi
    
    echo "📤 Pushing API to private remote..."
    git push private HEAD:main
    cd ../..
else
    echo "❌ Error: $API_DIR not found"
    exit 1
fi

# 2. Deploy Modal App
echo "☁️ Deploying Modal volume-operations app..."
cd "$API_DIR"

# Check if civitai-api-key secret exists in Modal
if ! uv run modal secret list | grep -q "civitai-api-key"; then
    if [ -n "$CIVITAI_API_KEY" ]; then
        echo "🔑 Creating Modal secret 'civitai-api-key' from CIVITAI_API_KEY..."
        uv run modal secret create civitai-api-key CIVITAI_KEY="$CIVITAI_API_KEY"
    else
        echo "⚠️ Warning: Modal secret 'civitai-api-key' is missing and CIVITAI_API_KEY is not set in environment."
        echo "Please set it: export CIVITAI_API_KEY='your-key' && ./deploy.sh"
    fi
fi

uv run modal deploy src/modal_apps/modal_downloader.py::modal_downloader_app
cd ../..
echo "✅ Modal app deployed"

# 3. Update and Push Main Repository
echo "🏠 Updating main repository..."
git add apps/api
# Only commit if the submodule reference changed
if ! git diff-index --quiet HEAD --; then
    git commit -m "chore: update api submodule reference"
    echo "✅ Committed main repo changes"
else
    echo "ℹ️ No changes in main repository"
fi

echo "📤 Pushing main repository..."
git push origin main

echo "✨ Deployment sequence complete!"
echo "👉 Next: Log into your VPS and run the Dokploy rebuild commands."
