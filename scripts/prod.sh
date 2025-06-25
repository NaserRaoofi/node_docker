#!/bin/bash

# Production environment management script

case "$1" in
  "start")
    echo "🚀 Starting production environment..."
    docker compose -f docker-compose.base.yml -f docker-compose.prod.yml up -d
    ;;
  "stop")
    echo "🛑 Stopping production environment..."
    docker compose -f docker-compose.base.yml -f docker-compose.prod.yml down
    ;;
  "deploy")
    echo "🚀 Deploying to production..."
    docker compose -f docker-compose.base.yml -f docker-compose.prod.yml pull
    docker compose -f docker-compose.base.yml -f docker-compose.prod.yml up -d --build
    ;;
  "logs")
    echo "📋 Showing production logs..."
    docker compose -f docker-compose.base.yml -f docker-compose.prod.yml logs -f
    ;;
  *)
    echo "Usage: $0 {start|stop|deploy|logs}"
    ;;
esac
