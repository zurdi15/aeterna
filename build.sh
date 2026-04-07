#!/bin/bash
set -euo pipefail

VERSION=${1:?Usage: ./build.sh <version> (e.g. v1.1.0)}
REPO="ghcr.io/zurdi15/aeterna"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Load GHCR token from .env.ghcr if not already set
if [[ -z "${GITHUB_TOKEN:-}" && -f "${REPO_ROOT}/.env.ghcr" ]]; then
  source "${REPO_ROOT}/.env.ghcr"
fi

echo "🔐 Logging into GHCR..."
echo "${GITHUB_TOKEN:?Set GITHUB_TOKEN or add it to .env.ghcr}" | docker login ghcr.io -u zurdi15 --password-stdin

echo "📦 Building backend ${VERSION}..."
docker build -t "${REPO}-backend:${VERSION}" -t "${REPO}-backend:latest" ./backend

echo "📦 Building frontend ${VERSION}..."
docker build -t "${REPO}-frontend:${VERSION}" -t "${REPO}-frontend:latest" --build-arg VITE_API_URL=/api ./frontend

echo "🚀 Pushing backend..."
docker push "${REPO}-backend:${VERSION}"
docker push "${REPO}-backend:latest"

echo "🚀 Pushing frontend..."
docker push "${REPO}-frontend:${VERSION}"
docker push "${REPO}-frontend:latest"

echo "✅ Done: ${REPO}-backend:${VERSION} and ${REPO}-frontend:${VERSION}"
