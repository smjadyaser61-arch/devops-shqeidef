
# Start from a version-pinned Node.js Alpine base image
FROM node:24.9.0-alpine3.22

# Set the working directory to /app
WORKDIR /app

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy dependency manifests first for caching
COPY package*.json ./

# Install production dependencies and clean npm cache
RUN npm ci --omit=dev && npm cache clean --force

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy application source code
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Document the application port
EXPOSE 3000

# Link the image to the GitHub repository
LABEL org.opencontainers.image.source="https://github.com/smjadyaser61-arch/devops-shqeidef"

# Check application health using wget
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:3000/health || exit 1

# Start the application
CMD ["node", "index.js"]

