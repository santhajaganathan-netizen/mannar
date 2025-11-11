#!/usr/bin/env bash
set -e

# === CONFIG ===
DOCKER_DATA_DIR="docker-data"
POSTGRES_DATA_DIR="docker-data/postgres"
MEDUSA_BACKEND_DIR="docker-data/backend"
MEDUSA_STOREFRONT_DIR="docker-data/storefront"

GITHUB_DIR="github"
BACKEND_REPO="https://github.com/medusajs/medusa-starter-default.git"
STOREFRONT_REPO="https://github.com/medusajs/nextjs-starter-medusa.git"

echo "🚀 Preparing Medusa repositories..."
mkdir -p "$POSTGRES_DATA_DIR"
mkdir -p "$MEDUSA_BACKEND_DIR"
mkdir -p "$MEDUSA_STOREFRONT_DIR"
mkdir -p "$GITHUB_DIR"

# === CLONE BACKEND ===
if [ ! -d "$GITHUB_DIR/medusa-starter-default/.git" ]; then
  echo "⬇️  Cloning Medusa backend starter..."
  git clone --depth=1 "$BACKEND_REPO" "$GITHUB_DIR/medusa-starter-default"
else
  echo "🔄 Updating existing Medusa backend repository..."
  (cd "$GITHUB_DIR/medusa-starter-default" && git pull)
fi

# === CLONE STOREFRONT ===
if [ ! -d "$GITHUB_DIR/nextjs-starter-medusa/.git" ]; then
  echo "⬇️  Cloning Medusa storefront starter..."
  git clone --depth=1 "$STOREFRONT_REPO" "$GITHUB_DIR/nextjs-starter-medusa"
else
  echo "🔄 Updating existing storefront repository..."
  (cd "$GITHUB_DIR/nextjs-starter-medusa" && git pull)
fi

echo ""
echo "✅ Repositories ready inside '$GITHUB_DIR':"
echo "   - $GITHUB_DIR/medusa-starter-default"
echo "   - $GITHUB_DIR/nextjs-starter-medusa"
