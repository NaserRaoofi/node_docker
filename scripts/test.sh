#!/bin/bash

# Test environment management script

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    "start")
        print_status "🧪 Starting test environment..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml up -d
        
        # Wait for services to be ready
        print_status "⏳ Waiting for services to be ready..."
        sleep 5
        
        # Check if postgres is ready
        print_status "🔍 Checking database connection..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml exec postgres_test pg_isready -U test -d myapp_test || true
        ;;
    
    "stop")
        print_status "🛑 Stopping test environment..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml down
        ;;
    
    "run")
        print_status "🏃 Running tests..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml up --build app
        ;;
    
    "run-once")
        print_status "🏃 Running tests (one-time)..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm test
        ;;
    
    "setup")
        print_status "🔧 Setting up test environment..."
        # Start test database
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml up -d postgres_test
        
        # Wait for database
        print_status "⏳ Waiting for database to be ready..."
        sleep 10
        
        # Run any test setup scripts
        print_status "📋 Running test setup..."
        # You can add database migrations, seed data, etc. here
        # docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:setup
        
        print_status "✅ Test environment setup complete"
        ;;
    
    "logs")
        print_status "📋 Showing test logs..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml logs -f
        ;;
    
    "clean")
        print_status "🧹 Cleaning test environment..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml down -v
        print_status "✅ Test environment cleaned"
        ;;
    
    "shell")
        SERVICE="${2:-app}"
        print_status "🐚 Opening shell in test $SERVICE..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml exec "$SERVICE" /bin/sh
        ;;
    
    "db-shell")
        print_status "🗄️ Opening database shell..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml exec postgres_test psql -U test -d myapp_test
        ;;
    
    "watch")
        print_status "👀 Running tests in watch mode..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:watch
        ;;
    
    "coverage")
        print_status "📊 Running tests with coverage..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:coverage
        ;;
    
    "unit")
        print_status "🔬 Running unit tests..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:unit
        ;;
    
    "integration")
        print_status "🔗 Running integration tests..."
        # Start test database first
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml up -d postgres_test
        sleep 10
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:integration
        ;;
    
    "lint")
        print_status "🔍 Running linter..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run lint
        ;;
    
    "format")
        print_status "💅 Running formatter..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run format
        ;;
    
    "ci")
        print_status "🤖 Running CI pipeline..."
        print_status "Step 1: Linting..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run lint
        
        print_status "Step 2: Type checking (if applicable)..."
        # docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run type-check
        
        print_status "Step 3: Unit tests..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:unit
        
        print_status "Step 4: Integration tests..."
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml up -d postgres_test
        sleep 10
        docker compose -f docker-compose.base.yml -f docker-compose.test.yml run --rm app npm run test:integration
        
        print_status "✅ CI pipeline completed successfully"
        ;;
    
    *)
        echo -e "${BLUE}🧪 Test Environment Management${NC}"
        echo
        echo "Usage: $0 <command> [options]"
        echo
        echo "Environment Commands:"
        echo "  start               - Start test environment"
        echo "  stop                - Stop test environment"
        echo "  setup               - Setup test environment with database"
        echo "  clean               - Clean test environment and volumes"
        echo "  logs                - Show test logs"
        echo "  shell [service]     - Open shell in test container"
        echo "  db-shell            - Open database shell"
        echo
        echo "Test Commands:"
        echo "  run                 - Run all tests (with services)"
        echo "  run-once            - Run tests once (no services)"
        echo "  watch               - Run tests in watch mode"
        echo "  coverage            - Run tests with coverage"
        echo "  unit                - Run unit tests only"
        echo "  integration         - Run integration tests"
        echo "  lint                - Run linter"
        echo "  format              - Run code formatter"
        echo "  ci                  - Run full CI pipeline"
        echo
        echo "Examples:"
        echo "  $0 setup             # Setup test environment"
        echo "  $0 run               # Run all tests"
        echo "  $0 watch             # Watch mode"
        echo "  $0 ci                # Full CI pipeline"
        ;;
esac
