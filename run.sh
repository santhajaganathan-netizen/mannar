#!/bin/bash
set -e  # exit on error

# Check for exactly one argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <service>"
    echo "Example: $0 postgres"
    exit 1
fi

SERVICE=$1

# 'source' (or '.') reads the file and executes it in the current shell.
# This makes variables like POSTGRES_PORT available for shell expansion.
if [ -f .env ]; then
    echo "Loading environment variables from .env"
    # The variables in .env must be in the format 'VAR=value'
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Supported services
if [ "$SERVICE" = "postgres" ]; then
    echo "🔧 Running '$SERVICE' Docker image..."
    docker run -d --name medusa-db --env-file .env -p ${POSTGRES_PORT}:5432 -v pgdata:/docker_data/postgresql/data medusa-db-img
    echo "✅ Build complete: medusa-db-img"
elif [ "$SERVICE" = "backend" ]; then
    echo "🔧 Running '$SERVICE' Docker image..."
    docker run -d --name medusa-backend --env-file .env -p ${MEDUSA_PORT}:9000 --link medusa-db:db medusa-backend-img:latest
    echo "✅ Container started: medusa-backend"
else
    echo "❌ Error: Service '$SERVICE' is not supported."
    echo "Currently supported: postgres"
    exit 1
fi
