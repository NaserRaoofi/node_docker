#!/bin/bash

# Main project management script - Unified interface for all environments

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project info
PROJECT_NAME="Node Docker App"
PROJECT_DIR="/mnt/windows-data/VScode/n_docker"

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                      🐳 $PROJECT_NAME                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

case "$1" in
    "init"|"setup")
        print_header
        print_status "🚀 Initializing project environment..."
        
        # Check if .env exists
        if [ ! -f ".env" ]; then
            print_warning "⚠️  .env file not found. Creating from .env.example..."
            cp .env.example .env
            print_status "✅ Created .env file. Please review and update it."
        fi
        
        # Build base image
        print_status "🔨 Building base Docker image..."
        docker compose build
        
        # Install dependencies
        print_status "📦 Installing dependencies..."
        docker compose run --rm app npm install
        
        print_status "✅ Project initialization complete!"
        echo
        echo "Next steps:"
        echo "  1. Review and update .env file"
        echo "  2. Run: $0 dev start"
        ;;
    
    "dev")
        shift
        bash ./scripts/dev.sh "$@"
        ;;
    
    "prod")
        shift
        bash ./scripts/prod.sh "$@"
        ;;
    
    "test")
        shift
        bash ./scripts/test.sh "$@"
        ;;
    
    "docker")
        shift
        bash ./scripts/docker.sh "$@"
        ;;
    
    "status")
        print_header
        print_status "📊 Project Status Overview"
        echo
        
        # Check if containers are running
        echo -e "${CYAN}=== Running Containers ===${NC}"
        docker ps --filter "name=node_app" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo
        
        # Check Docker images
        echo -e "${CYAN}=== Project Images ===${NC}"
        docker images --filter "reference=*node*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
        echo
        
        # Check disk usage
        echo -e "${CYAN}=== Docker Disk Usage ===${NC}"
        docker system df
        ;;
    
    "logs")
        ENV="${2:-dev}"
        print_status "📋 Showing logs for $ENV environment..."
        case "$ENV" in
            "dev")
                docker compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f
                ;;
            "prod")
                docker compose -f docker-compose.base.yml -f docker-compose.prod.yml logs -f
                ;;
            "test")
                docker compose -f docker-compose.base.yml -f docker-compose.test.yml logs -f
                ;;
            *)
                docker compose logs -f
                ;;
        esac
        ;;
    
    "shell")
        ENV="${2:-dev}"
        print_status "🐚 Opening shell in $ENV environment..."
        case "$ENV" in
            "dev")
                docker compose -f docker-compose.base.yml -f docker-compose.dev.yml exec app /bin/sh
                ;;
            "prod")
                docker compose -f docker-compose.base.yml -f docker-compose.prod.yml exec app /bin/sh
                ;;
            "test")
                docker compose -f docker-compose.base.yml -f docker-compose.test.yml exec app /bin/sh
                ;;
            *)
                docker compose exec app /bin/sh
                ;;
        esac
        ;;
    
    "quick-start")
        print_header
        print_status "⚡ Quick Start - Development Environment"
        
        # Check if .env exists
        if [ ! -f ".env" ]; then
            cp .env.example .env
            print_status "📝 Created .env file"
        fi
        
        # Start development environment
        print_status "🚀 Starting development environment..."
        docker compose up -d
        
        # Wait a moment for services to start
        sleep 3
        
        # Show status
        print_status "📊 Services started:"
        docker compose ps
        
        echo
        print_status "✅ Development environment is ready!"
        echo -e "   🌐 App: ${GREEN}http://localhost:3000${NC}"
        echo -e "   🏥 Health: ${GREEN}http://localhost:3000/health${NC}"
        echo -e "   📋 Logs: ${YELLOW}$0 logs${NC}"
        ;;
    
    "stop-all")
        print_status "🛑 Stopping all environments..."
        docker compose -f docker-compose.base.yml -f docker-compose.dev.yml down 2>/dev/null || true
        docker compose -f docker-compose.base.yml -f docker-compose.prod.yml down 2>/dev/null || true
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml down 2>/dev/null || true
        docker compose down 2>/dev/null || true
        print_status "✅ All environments stopped"
        ;;
    
    "update")
        print_status "📦 Updating project dependencies..."
        docker compose run --rm app npm update
        docker compose build
        print_status "✅ Project updated"
        ;;
    
    "backup")
        BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
        print_status "💾 Creating backup in $BACKUP_DIR..."
        mkdir -p "$BACKUP_DIR"
        
        # Backup volumes
        docker run --rm -v "$(pwd)":/source -v "$(pwd)/$BACKUP_DIR":/backup alpine tar czf /backup/source.tar.gz -C /source .
        
        # Backup database if running
        if docker compose ps postgres_test | grep -q "running"; then
            docker compose exec postgres_test pg_dump -U test myapp_test > "$BACKUP_DIR/test_db.sql"
        fi
        
        print_status "✅ Backup created in $BACKUP_DIR"
        ;;
    
    "health")
        print_status "🏥 Checking application health..."
        
        # Check different environments
        for env in dev prod test; do
            for port in 3000 3001 8080 80; do
                if curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
                    echo -e "${GREEN}✅ $env environment healthy on port $port${NC}"
                    curl -s "http://localhost:$port/health" | jq 2>/dev/null || curl -s "http://localhost:$port/health"
                    echo
                fi
            done
        done
        ;;
    
    "clean")
        print_warning "🧹 This will clean up Docker resources for this project"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then        # Stop all environments
        bash ./manage.sh stop-all
            
            # Remove project containers and volumes
            docker compose down -v
            
            # Clean up project images
            docker images --filter "reference=*node*" -q | xargs -r docker rmi
            
            print_status "✅ Project cleanup completed"
        fi
        ;;
    
    "help"|"--help"|"-h")
        print_header
        echo -e "${PURPLE}Project Management Commands:${NC}"
        echo "  init/setup          - Initialize project environment"
        echo "  quick-start         - Quick start development environment"
        echo "  status              - Show project status overview"
        echo "  stop-all            - Stop all environments"
        echo "  update              - Update project dependencies"
        echo "  backup              - Create project backup"
        echo "  health              - Check application health"
        echo "  clean               - Clean up project Docker resources"
        echo
        echo -e "${PURPLE}Environment Commands:${NC}"
        echo "  dev <command>       - Development environment"
        echo "  prod <command>      - Production environment"
        echo "  test <command>      - Test environment"
        echo "  docker <command>    - Docker utilities"
        echo
        echo -e "${PURPLE}Quick Commands:${NC}"
        echo "  logs [env]          - Show logs (default: dev)"
        echo "  shell [env]         - Open shell (default: dev)"
        echo
        echo -e "${PURPLE}Examples:${NC}"
        echo "  $0 quick-start      # Start development quickly"
        echo "  $0 dev start        # Start development environment"
        echo "  $0 prod deploy      # Deploy to production"
        echo "  $0 test ci          # Run CI pipeline"
        echo "  $0 docker cleanup   # Clean up Docker"
        echo "  $0 logs prod        # Show production logs"
        echo
        echo -e "${PURPLE}Environment-specific help:${NC}"
        echo "  $0 dev              # Show dev commands"
        echo "  $0 prod             # Show prod commands"
        echo "  $0 test             # Show test commands"
        echo "  $0 docker           # Show docker commands"
        ;;
    
    *)
        print_header
        echo -e "${YELLOW}⚡ Quick Commands:${NC}"
        echo "  $0 quick-start      - Start development environment"
        echo "  $0 status           - Show project status"
        echo "  $0 help             - Show full help"
        echo
        echo -e "${YELLOW}🔧 Environment Management:${NC}"
        echo "  $0 dev start        - Start development"
        echo "  $0 prod start       - Start production"
        echo "  $0 test run         - Run tests"
        echo
        echo "Use '$0 help' for complete documentation"
        ;;
esac
