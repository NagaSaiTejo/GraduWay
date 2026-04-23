# ─────────────────────────────────────────
# Node.js Signaling + Media Server
# ─────────────────────────────────────────
FROM node:20-alpine

# Install ffmpeg with retry logic and explicit mirror for resilience
RUN for i in 1 2 3; do apk add --no-cache ffmpeg && break || sleep 5; done

WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm install --omit=dev

# Copy application source with explicit permissions
COPY --chown=node:node . .
RUN chown -R node:node /app

# Update ffmpeg path for Linux
ENV FFMPEG_PATH=/usr/bin/ffmpeg

# Switch to non-root user for OpenShift compatibility
USER node

EXPOSE 3000 8000 1935

CMD ["node", "index.js"]
