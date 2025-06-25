# 🐳 Node.js Docker Multi-Environment Setup

A professional Node.js application with Docker Compose supporting development, production, and testing environments with hot reload, environment management, and comprehensive tooling.

## 🚀 Quick Start

```bash
# Initialize project (first time only)
./manage.sh init

# Start development environment
./manage.sh quick-start

# Your app is now running at http://localhost:3000
```

## 📁 Project Structure

```
.
├── index.js                    # Main application entry point
├── Dockerfile                  # Docker image definition
├── manage.sh                   # Main project management script
├── package.json               # Node.js dependencies and scripts
├── .env                       # Environment variables (not in git)
├── .env.example              # Environment variables template
├── .gitignore                # Git ignore patterns
├── docker-compose.yml        # Default/development compose
├── docker-compose.base.yml   # Shared compose configuration
├── docker-compose.dev.yml    # Development-specific config
├── docker-compose.prod.yml   # Production-specific config
├── docker-compose.test.yml   # Testing-specific config
├── scripts/                  # Environment management scripts
│   ├── dev.sh               # Development environment
│   ├── prod.sh              # Production environment
│   ├── test.sh              # Testing environment
│   └── docker.sh            # Docker utilities
├── nginx/                   # Nginx configuration (production)
│   ├── nginx.conf
│   └── ssl/
├── test/                    # Test files
│   ├── setup.js
│   ├── unit/
│   └── integration/
├── jest.config.json         # Jest testing configuration
├── .eslintrc.json          # ESLint configuration
└── .prettierrc.json        # Prettier configuration
```

## 🔧 Environment Management

### Development Environment
```bash
# Start development with hot reload
./manage.sh dev start

# View development logs
./manage.sh dev logs

# Stop development
./manage.sh dev stop

# Rebuild development environment
./manage.sh dev build
```

### Production Environment
```bash
# Deploy to production
./manage.sh prod deploy

# Start production
./manage.sh prod start

# View production logs
./manage.sh prod logs

# Stop production
./manage.sh prod stop
```

### Testing Environment
```bash
# Setup test environment
./manage.sh test setup

# Run all tests
./manage.sh test run

# Run tests in watch mode
./manage.sh test watch

# Run with coverage
./manage.sh test coverage

# Run CI pipeline
./manage.sh test ci

# Clean test environment
./manage.sh test clean
```

## 🐳 Docker Commands

```bash
# System status
./manage.sh docker status

# Cleanup unused resources
./manage.sh docker cleanup

# Deep clean (removes everything!)
./manage.sh docker deep-clean

# View container logs
./manage.sh docker logs <container_name>

# Open shell in container
./manage.sh docker shell <container_name>

# Check application health
./manage.sh docker health

# Build for specific environment
./manage.sh docker build [dev|prod|test]
```

## 📊 Project Management

```bash
# Show project status
./manage.sh status

# Open shell in environment
./manage.sh shell [dev|prod|test]

# View logs from environment
./manage.sh logs [dev|prod|test]

# Update dependencies
./manage.sh update

# Create backup
./manage.sh backup

# Check application health
./manage.sh health

# Stop all environments
./manage.sh stop-all

# Clean project resources
./manage.sh clean
```

## 🔑 Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
# Application
APP_NAME=Node Docker App
APP_VERSION=1.0.0
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Database (if using PostgreSQL)
# DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Redis (if using)
# REDIS_URL=redis://localhost:6379
```

## 🧪 Testing

The project includes comprehensive testing setup:

- **Unit Tests**: `test/unit/` - Test individual functions
- **Integration Tests**: `test/integration/` - Test API endpoints
- **Coverage Reports**: Generated in `coverage/` directory
- **CI Pipeline**: Runs linting, tests, and checks

### Test Commands
```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# With coverage
npm run test:coverage

# Unit tests only
npm run test:unit

# Integration tests only
npm run test:integration

# Linting
npm run lint

# Format code
npm run format
```

## 🔗 Docker Compose Files

### `docker-compose.base.yml`
- Shared configuration for all environments
- Base service definitions
- Common networks and volumes

### `docker-compose.dev.yml`
- Development-specific overrides
- Hot reload with volume mounting
- Development database
- Debug configuration

### `docker-compose.prod.yml`
- Production-optimized settings
- Nginx reverse proxy
- No volume mounting
- Health checks and restart policies

### `docker-compose.test.yml`
- Isolated test environment
- Test database
- Test-specific configurations

## 🌐 Services

### Main Application
- **Development**: `http://localhost:3000`
- **Production**: `http://localhost` (via Nginx)
- **Testing**: `http://localhost:3001`
- **Health Check**: `/health` endpoint

### Redis (Development)
- **Port**: `6379`
- **Container**: `redis_dev`

### PostgreSQL (Testing)
- **Port**: `5433` (mapped from internal 5432)
- **Container**: `postgres_test`
- **Database**: `myapp_test`

### Nginx (Production)
- **HTTP**: Port `80`
- **HTTPS**: Port `443` (with SSL setup)
- **Container**: `nginx_prod`

## 🔒 Security Features

- Environment variable management
- SSL/TLS support (production)
- Rate limiting (Nginx)
- Security headers
- Isolated test environment
- No sensitive data in git

## 🚢 Deployment

### Development
1. `./manage.sh init` - One-time setup
2. `./manage.sh dev start` - Start development
3. Code with hot reload enabled

### Production
1. Configure production environment variables
2. Setup SSL certificates in `nginx/ssl/`
3. `./manage.sh prod deploy` - Deploy
4. Monitor with `./manage.sh prod logs`

### CI/CD
```bash
# Complete CI pipeline
./manage.sh test ci

# This runs:
# - Linting
# - Unit tests
# - Integration tests
# - Coverage reports
```

## 📝 Development Workflow

1. **Setup**: `./manage.sh init`
2. **Develop**: `./manage.sh dev start`
3. **Test**: `./manage.sh test run`
4. **Lint**: `npm run lint`
5. **Deploy**: `./manage.sh prod deploy`

## 🆘 Troubleshooting

### Hot Reload Not Working
- Ensure volume mounting is enabled
- Check that nodemon is using `-L` flag for polling
- Verify container can access host files

### Port Conflicts
- Check if ports are already in use: `lsof -i :3000`
- Modify ports in `.env` file
- Restart containers after changes

### Database Connection Issues
- Ensure database containers are running
- Check connection strings in `.env`
- Wait for database to be ready (use health checks)

### Docker Issues
- Clean up: `./manage.sh docker cleanup`
- Reset everything: `./manage.sh docker deep-clean`
- Check status: `./manage.sh docker status`

## 📖 Available Scripts

All scripts are located in the `scripts/` directory:

- `manage.sh` - Main project management
- `scripts/dev.sh` - Development environment
- `scripts/prod.sh` - Production environment  
- `scripts/test.sh` - Testing environment
- `scripts/docker.sh` - Docker utilities

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run `./manage.sh test ci`
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details
