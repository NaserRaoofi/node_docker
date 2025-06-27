#!/bin/bash

# Script to set which container user to run as in production

set -e

USER_NAME="$1"

if [ -z "$USER_NAME" ]; then
    echo "Usage: $0 <username>"
    echo "Available users:"
    echo "  d_sirwan (UID: 1001, GID: 1001)"
    echo "  milad    (UID: 1002, GID: 1001)"
    exit 1
fi

case "$USER_NAME" in
    "d_sirwan")
        echo "Setting container user to d_sirwan (1001:1001)..."
        sed -i 's/^CONTAINER_USER_ID=.*/CONTAINER_USER_ID=1001/' .env
        sed -i 's/^CONTAINER_GROUP_ID=.*/CONTAINER_GROUP_ID=1001/' .env
        ;;
    "milad")
        echo "Setting container user to milad (1002:1001)..."
        sed -i 's/^CONTAINER_USER_ID=.*/CONTAINER_USER_ID=1002/' .env
        sed -i 's/^CONTAINER_GROUP_ID=.*/CONTAINER_GROUP_ID=1001/' .env
        ;;
    *)
        echo "❌ Unknown user: $USER_NAME"
        echo "Available users: d_sirwan, milad"
        exit 1
        ;;
esac

echo "✅ Container user set to $USER_NAME"
echo "Run 'docker compose -f docker-compose.base.yml -f docker-compose.prod.yml up --build -d' to apply changes"
