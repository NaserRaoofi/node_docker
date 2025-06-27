# Use official Node.js Alpine image for smaller size
FROM node:18-alpine AS base

# Install security updates and bash first (as root)
RUN apk update && apk upgrade && apk add --no-cache bash && \
    addgroup -g 1001 -S developer && \
    adduser -S d_sirwan -u 1001 -G developer && \
    adduser -S milad -u 1002 -G developer

# Set working directory
WORKDIR /app

# Change ownership of the working directory
RUN chown -R d_sirwan:developer /app
USER d_sirwan

# Expose port
EXPOSE 3000
# Development command - use exec form to handle signals properly
CMD ["npm", "run", "dev"]

# Production dependencies stage
FROM base AS dependencies
# Copy package files
COPY --chown=d_sirwan:developer package*.json ./
# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM base AS production
# Copy production dependencies from dependencies stage
COPY --from=dependencies --chown=d_sirwan:developer /app/node_modules ./node_modules
# Copy package files
COPY --chown=d_sirwan:developer package*.json ./
# Copy only necessary source files (exclude dev files via .dockerignore)
COPY --chown=d_sirwan:developer . ./

# Expose port
EXPOSE 3000

# Health check with shorter intervals for production
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Production command
CMD ["node", "index.js"]
