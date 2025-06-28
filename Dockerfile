# Use official Node.js Alpine image for smaller size
FROM node:18-alpine AS base

# Install security updates, bash, sudo, and nodemon globally as root
RUN apk update && apk upgrade && \
    apk add --no-cache bash sudo shadow && \
    npm install -g nodemon

# Create developer group and sirwan user with sudo privileges
RUN addgroup -g 1001 developer && \
    adduser -D -u 1001 -G developer sirwan && \
    echo "sirwan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sirwan && \
    chmod 0440 /etc/sudoers.d/sirwan

# Set working directory
WORKDIR /app

# Create node_modules directory and set ownership
RUN mkdir -p /app/node_modules && \
    chown -R sirwan:developer /app && \
    chmod -R 777 /app

# Expose port
EXPOSE 3000

# Development stage - includes all dependencies and source code
FROM base AS development
USER sirwan
COPY --chown=sirwan:developer package*.json ./
RUN npm ci && npm cache clean --force
COPY --chown=sirwan:developer . ./
# Ensure all scripts are executable
RUN find /app -name "*.sh" -exec chmod +x {} \;
# We'll use node directly to avoid nodemon issues
CMD ["node", "index.js"]

# Production stage - optimized for production
FROM base AS production
USER sirwan
COPY --chown=sirwan:developer package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --chown=sirwan:developer . ./
# Ensure all scripts are executable
RUN find /app -name "*.sh" -exec chmod +x {} \;
# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1
# Production command
CMD ["node", "index.js"]
