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

# Required environment variables
REQUIRED_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB")

# Function to check for .env file
check_env_file() {
    if [ ! -f ".env" ]; then
        echo "❌ Error: .env file not found in the current directory."
        echo "Please create a .env file with the following variables:"
        printf '  %s\n' "${REQUIRED_VARS[@]}"
        exit 1
    fi
}

# Function to verify all required variables are set
verify_env_vars() {
    # Load the .env file
    set -o allexport
    source .env
    set +o allexport

    missing_vars=()
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "❌ Error: The following required environment variables are missing in .env:"
        printf '  %s\n' "${missing_vars[@]}"
        exit 1
    fi

    echo "✅ All required environment variables are set."
}

echo "🚀 Preparing Medusa repositories..."
mkdir -p "$POSTGRES_DATA_DIR"
mkdir -p "$MEDUSA_BACKEND_DIR"
mkdir -p "$MEDUSA_STOREFRONT_DIR"
mkdir -p "$GITHUB_DIR"


clone_from_github() {
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

}



# --- Main Execution ---
if [ $# -ne 1 ]; then
    echo "Usage: $0 <service>"
    echo "Example: $0 postgres"
    exit 1
fi

check_env_file
verify_env_vars
clone_from_github