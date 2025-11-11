#!/usr/bin/env bash
set -e

# === CONFIGURATION ===
BACKEND_SRC="github/medusa-starter-default"
STOREFRONT_SRC="github/nextjs-starter-medusa"

BACKEND_DIR="docker-data/backend"
STOREFRONT_DIR="docker-data/storefront"

echo "🚀 Setting up Medusa Docker build environment..."
echo "-----------------------------------------------"

# === VALIDATE SOURCE REPOSITORIES ===
if [ ! -d "$BACKEND_SRC" ]; then
  echo "❌ ERROR: $BACKEND_SRC not found."
  echo "   Run ./pre.sh first to download the repositories."
  exit 1
fi

if [ ! -d "$STOREFRONT_SRC" ]; then
  echo "❌ ERROR: $STOREFRONT_SRC not found."
  echo "   Run ./pre.sh first to download the repositories."
  exit 1
fi

# === VALIDATE REQUIRED FILES EXIST ===
if [ ! -f "$BACKEND_SRC/package.json" ]; then
  echo "❌ ERROR: Missing package.json in $BACKEND_SRC"
  exit 1
fi

if [ ! -f "$STOREFRONT_SRC/package.json" ]; then
  echo "❌ ERROR: Missing package.json in $STOREFRONT_SRC"
  exit 1
fi

# === COPY package.json FILES TO DOCKER CONTEXTS ===
echo "📦 Copying package.json files to Docker build contexts..."

mkdir -p "$BACKEND_DIR"
mkdir -p "$STOREFRONT_DIR"

cp "$BACKEND_SRC/package.json" "$BACKEND_DIR/"
if [ -f "$BACKEND_SRC/package-lock.json" ]; then
  cp "$BACKEND_SRC/package-lock.json" "$BACKEND_DIR/"
fi

cp "$STOREFRONT_SRC/package.json" "$STOREFRONT_DIR/"
if [ -f "$STOREFRONT_SRC/package-lock.json" ]; then
  cp "$STOREFRONT_SRC/package-lock.json" "$STOREFRONT_DIR/"
fi

echo "✅ package.json files copied successfully!"

# === VERIFY DOCKERFILES EXIST ===
if [ ! -f "$BACKEND_DIR/Dockerfile.medusa" ]; then
  echo "❌ ERROR: Dockerfile.medusa missing in $BACKEND_DIR"
  exit 1
fi

if [ ! -f "$STOREFRONT_DIR/Dockerfile.storefront" ]; then
  echo "❌ ERROR: Dockerfile.storefront missing in $STOREFRONT_DIR"
  exit 1
fi

# === RUN DOCKER BUILD ===
echo "🐳 Building Medusa Docker images..."
docker compose build

echo "✅ Build complete!"
echo ""
echo "To start the containers, run:"
echo "  docker compose up -d"
echo ""
echo "Services:"
echo "  - Medusa Backend:   http://localhost:9000"
echo "  - Storefront:       http://localhost:8000"
echo "  - PostgreSQL:       localhost:5432"
