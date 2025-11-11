#!/bin/bash
set -e  # exit on error

# Check for exactly one argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <service>"
    echo "Example: $0 postgres"
    exit 1
fi

SERVICE=$1

# Supported services
if [ "$SERVICE" = "postgres" ]; then
    echo "🔧 Running '$SERVICE' Docker image..."
#    docker run -d --name medusa-db mannar-db
     docker run -d --name medusa-db -e POSTGRES_USER=medusa_root -e POSTGRES_PASSWORD=supersecretpassword -e POSTGRES_DB=medusa -p 5432:5432 -v pgdata:/docker_data/postgresql/data mannar-db
    echo "✅ Build complete: mannar-db"
else
    echo "❌ Error: Service '$SERVICE' is not supported."
    echo "Currently supported: postgres"
    exit 1
fi
