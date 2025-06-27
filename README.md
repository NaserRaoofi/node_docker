# 🐳 Node.js Docker Multi-Environment Application

[![Node.js](https://img.shields.io/badge/Node.js-18-green.svg)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-green.svg)](https://www.mongodb.com/)
[![Redis](https://img.shields.io/badge/Redis-7.0-red.svg)](https://redis.io/)

A professional Node.js application with Docker multi-stage builds, MongoDB integration, Redis support, and comprehensive DevOps tooling featuring development, production, and testing environments.

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
n_docker/
├── 🐳 Docker Configuration
│   ├── Dockerfile                     # Multi-stage build (base, development, production)
│   ├── docker-compose.base.yml        # Shared base configuration
│   ├── docker-compose.dev.yml         # Development with MongoDB + Redis
│   ├── docker-compose.dev-minimal.yml # Minimal development (app only)
│   ├── docker-compose.prod.yml        # Production with Nginx
│   └── docker-compose.test.yml        # Testing environment
│
├── 🔧 Application Core
│   ├── index.js                      # Express app with MongoDB API
│   ├── package.json                  # Dependencies (express, mongodb)
│   └── package-lock.json             # Locked dependency versions
│
├── ⚙️ Configuration
│   ├── .env                         # Environment variables (local)
│   ├── .env.example                 # Environment template
│   ├── jest.config.json             # Jest testing configuration
│   ├── .eslintrc.json               # ESLint code quality rules
│   └── .prettierrc.json             # Prettier formatting rules
│
├── 🎯 Scripts & Automation
│   ├── manage.sh                    # Main project management script
│   └── scripts/
│       ├── dev.sh                  # Development environment
│       ├── prod.sh                 # Production environment
│       ├── test.sh                 # Testing environment
│       ├── docker.sh               # Docker utilities
│       └── mongo-init.js           # MongoDB initialization script
│
├── 🌐 Infrastructure
│   └── nginx/
│       ├── nginx.conf              # Nginx reverse proxy config
│       └── ssl/                    # SSL certificates directory
│
└── 🧪 Testing
    └── test/
        ├── setup.js                # Test environment setup
        ├── unit/                   # Unit tests
        └── integration/            # Integration tests
```

## 🔧 Environment Management

### Key Features
- **🏗️ Multi-stage Docker builds** for optimized production images
- **🔄 Hot reload development** with volume mounting  
- **🗄️ MongoDB integration** with automated initialization
- **⚡ Redis support** for caching and sessions
- **🏥 Health monitoring** with automated health checks
- **🧪 Comprehensive testing** with Jest and Supertest
- **🔒 Security-first approach** with non-root containers

### Development Environment
```bash
# Start full development stack (Node.js + MongoDB + Redis)
./manage.sh dev start

# Start minimal development (app only - useful for debugging)
docker compose -f docker-compose.base.yml -f docker-compose.dev-minimal.yml up

# View development logs
./manage.sh dev logs

# Stop development
./manage.sh dev stop

# Rebuild development environment
./manage.sh dev build
```

**Features:**
- 🔄 Hot reload with nodemon
- 🗄️ MongoDB with automated initialization
- ⚡ Redis for session management
- 📁 Volume mounting for live code sync
- 🐛 Debug mode enabled

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

## 📊 API Endpoints

### Core Application Routes

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| `GET` | `/` | **Home page** with environment info | HTML dashboard |
| `GET` | `/health` | **Health check** for monitoring | JSON health status |
| `GET` | `/api/users` | **Get all users** from MongoDB | JSON user list |
| `POST` | `/api/users` | **Create new user** | JSON user object |

### Example API Usage

```bash
# Health check
curl http://localhost:3000/health

# Get users
curl http://localhost:3000/api/users

# Create user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"username": "john", "email": "john@example.com", "name": "John Doe"}'
```

### Health Check Response

```json
{
  "status": "OK",
  "timestamp": "2025-06-27T10:00:00.000Z",
  "environment": "development",
  "version": "1.0.0",
  "services": {
    "mongodb": "connected",
    "redis": "configured"
  }
}
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
NODE_ENV=development
APP_NAME=Node Docker App
APP_VERSION=1.0.0
PORT=3000
HOST=0.0.0.0

# MongoDB Configuration
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=devpass
MONGODB_URL=mongodb://admin:devpass@mongo_dev:27017/nodeapp_dev?authSource=admin

# Redis Configuration
REDIS_URL=redis://redis_dev:6379

# Docker Configuration
DOCKER_TARGET=development
UID=1000
GID=1000
COMPOSE_PROJECT_NAME=node_docker
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
- Common networks and health checks

### `docker-compose.dev.yml`
- Development-specific overrides
- Hot reload with volume mounting
- MongoDB and Redis services
- Debug configuration and sample data

### `docker-compose.dev-minimal.yml`
- **Application only** (no databases)
- Useful for debugging and quick testing
- Lightweight development environment
- Network troubleshooting

### `docker-compose.prod.yml`
- Production-optimized settings
- Nginx reverse proxy
- No volume mounting
- Health checks and restart policies

### `docker-compose.test.yml`
- Isolated test environment
- Test database
- Test-specific configurations

## 🗄️ MongoDB Integration

### Automatic Database Setup
The MongoDB container automatically initializes with:
- **Collections**: `users`, `posts`, `sessions`
- **Indexes**: Email and username uniqueness, performance indexes
- **Sample data**: Development user accounts
- **Authentication**: Admin user with proper permissions

### MongoDB Initialization Script (`scripts/mongo-init.js`)
```javascript
// Creates database, users, collections, and indexes
db = db.getSiblingDB('nodeapp_dev');
db.createUser({...});
db.users.createIndex({ "email": 1 }, { unique: true });
// ... more setup
```

### Usage Examples
```bash
# Connect to MongoDB
docker exec -it mongo_dev mongosh -u admin -p devpass

# Check database status
curl http://localhost:3000/health
```

## 🌐 Services

### Main Application
- **Development**: `http://localhost:3000`
- **Production**: `http://localhost` (via Nginx)
- **Testing**: `http://localhost:3001`
- **Health Check**: `/health` endpoint
- **API**: `/api/users` endpoint

### MongoDB (Development)
- **Port**: `27017`
- **Container**: `mongo_dev`
- **Database**: `nodeapp_dev`
- **User**: `admin` / **Password**: `devpass`
- **Initialization**: Automated with sample data

### Redis (Development)
- **Port**: `6379`
- **Container**: `redis_dev`
- **Usage**: Session storage and caching

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

### MongoDB Connection Issues
- Ensure MongoDB container is running: `./manage.sh dev logs mongo_dev`
- Check connection string in `.env`
- Verify authentication credentials
- Wait for MongoDB to be ready (initialization takes time)

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
- `scripts/mongo-init.js` - MongoDB initialization script

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run `./manage.sh test ci`
5. Submit a pull request

## 📄 License

ISC License - see LICENSE file for details
