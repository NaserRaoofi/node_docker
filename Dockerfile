# Use official Node.js Alpine image for smaller size
FROM node:18-alpine AS base

# Install security updates and create app user
RUN apk update && apk upgrade && apk add --no-cache bash && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set working directory and ownership
WORKDIR /app
RUN chown appuser:appgroup /app
USER appuser

# Expose port
EXPOSE 3000

# Development stage - includes all dependencies and source code
FROM base AS development
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci && npm cache clean --force
COPY --chown=appuser:appgroup . ./
CMD ["npm", "run", "dev"]

# Production stage - optimized for production
FROM base AS production
# Copy package files and install only production dependencies
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci --only=production && npm cache clean --force
# Copy source code
COPY --chown=appuser:appgroup . ./
# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1
# Production command
CMD ["node", "index.js"]
