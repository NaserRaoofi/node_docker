#!/bin/bash

# Docker management utility script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

case "$1" in
    "cleanup")
        print_warning "🧹 Cleaning up Docker resources..."
        echo "This will remove:"
        echo "  - Stopped containers"
        echo "  - Unused networks"
        echo "  - Unused images"
        echo "  - Build cache"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker system prune -f
            print_status "✅ Docker cleanup completed"
        else
            print_status "❌ Cleanup cancelled"
        fi
        ;;
    
    "deep-clean")
        print_warning "🧨 DEEP CLEAN - This will remove ALL Docker data!"
        echo "This will remove:"
        echo "  - ALL containers (running and stopped)"
        echo "  - ALL images"
        echo "  - ALL volumes"
        echo "  - ALL networks"
        echo "  - ALL build cache"
        read -p "Are you absolutely sure? Type 'YES' to continue: " -r
        if [[ $REPLY == "YES" ]]; then
            docker container prune -f
            docker image prune -af
            docker volume prune -f
            docker network prune -f
            docker system prune -af --volumes
            print_status "💥 Deep clean completed"
        else
            print_status "❌ Deep clean cancelled"
        fi
        ;;
    
    "status")
        print_status "📊 Docker System Status"
        echo
        echo -e "${BLUE}=== Running Containers ===${NC}"
        docker ps
        echo
        echo -e "${BLUE}=== Docker System Info ===${NC}"
        docker system df
        echo
        echo -e "${BLUE}=== Docker Images ===${NC}"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
        ;;
    
    "logs")
        if [ -z "$2" ]; then
            print_error "Please specify container name or service"
            echo "Usage: $0 logs <container_name_or_service>"
            exit 1
        fi
        print_status "📋 Showing logs for: $2"
        docker logs -f "$2"
        ;;
    
    "shell")
        if [ -z "$2" ]; then
            print_error "Please specify container name"
            echo "Usage: $0 shell <container_name>"
            exit 1
        fi
        print_status "🐚 Opening shell in container: $2"
        docker exec -it "$2" /bin/sh
        ;;
    
    "build")
        ENV="${2:-dev}"
        print_status "🔨 Building for environment: $ENV"
        case "$ENV" in
            "dev")
                docker compose -f docker-compose.base.yml -f docker-compose.dev.yml build
                ;;
            "prod")
                docker compose -f docker-compose.base.yml -f docker-compose.prod.yml build
                ;;
            "test")
                docker compose -f docker-compose.base.yml -f docker-compose.test.yml build
                ;;
            *)
                print_error "Unknown environment: $ENV"
                echo "Available environments: dev, prod, test"
                exit 1
                ;;
        esac
        ;;
    
    "rebuild")
        ENV="${2:-dev}"
        print_status "🔄 Rebuilding for environment: $ENV (no cache)"
        case "$ENV" in
            "dev")
                docker compose -f docker-compose.base.yml -f docker-compose.dev.yml build --no-cache
                ;;
            "prod")
                docker compose -f docker-compose.base.yml -f docker-compose.prod.yml build --no-cache
                ;;
            "test")
                docker compose -f docker-compose.base.yml -f docker-compose.test.yml build --no-cache
                ;;
            *)
                print_error "Unknown environment: $ENV"
                echo "Available environments: dev, prod, test"
                exit 1
                ;;
        esac
        ;;
    
    "health")
        print_status "🏥 Checking application health..."
        # Try different ports/endpoints
        for port in 3000 8080 80; do
            if curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Health check passed on port $port${NC}"
                curl -s "http://localhost:$port/health" | jq 2>/dev/null || curl -s "http://localhost:$port/health"
                exit 0
            fi
        done
        print_error "❌ Health check failed on all ports"
        ;;
    
    "inspect")
        if [ -z "$2" ]; then
            print_error "Please specify container name"
            echo "Usage: $0 inspect <container_name>"
            exit 1
        fi
        print_status "🔍 Inspecting container: $2"
        docker inspect "$2" | jq '.[0] | {Name, State, Config: {Image, Env}, NetworkSettings: {Ports, Networks}}'
        ;;
    
    "top")
        print_status "📈 Docker processes"
        docker stats --no-stream
        ;;
    
    *)
        echo -e "${BLUE}🐳 Docker Management Utility${NC}"
        echo
        echo "Usage: $0 <command> [options]"
        echo
        echo "Commands:"
        echo "  cleanup              - Remove unused Docker resources"
        echo "  deep-clean          - Remove ALL Docker data (dangerous!)"
        echo "  status              - Show Docker system status"
        echo "  logs <container>    - Show logs for a container"
        echo "  shell <container>   - Open shell in container"
        echo "  build [env]         - Build for environment (dev/prod/test)"
        echo "  rebuild [env]       - Rebuild without cache"
        echo "  health              - Check application health"
        echo "  inspect <container> - Inspect container details" 
        echo "  top                 - Show Docker processes"
        echo
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 cleanup"
        echo "  $0 logs node_app"
        echo "  $0 shell node_app"
        echo "  $0 build prod"
        echo "  $0 health"
        ;;
esac
