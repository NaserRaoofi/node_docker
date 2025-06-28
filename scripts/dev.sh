#!/bin/bash

# Development environment management script

case "$1" in
  "start")
    echo "🚀 Starting development environment..."
    docker compose -f docker-compose.base.yml -f docker-compose.dev.yml up -d
    
    # Run MongoDB initialization
    ./scripts/init-mongo.sh
    ;;
  "stop")
    echo "🛑 Stopping development environment..."
    docker compose -f docker-compose.base.yml -f docker-compose.dev.yml down
    ;;
  "logs")
    echo "📋 Showing development logs..."
    docker compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f
    ;;
  "build")
    echo "🔨 Building development environment..."
    docker compose -f docker-compose.base.yml -f docker-compose.dev.yml build
    ;;
  *)
    echo "Usage: $0 {start|stop|logs|build}"
    ;;
esac
