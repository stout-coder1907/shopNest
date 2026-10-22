# ==========================================
# Step 1: Build Frontend (Builder Stage)
# ==========================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependency manifests first to leverage Docker layer caching
COPY frontend/package*.json ./frontend/

# Install frontend dependencies (cached unless frontend/package*.json changes)
RUN npm ci --prefix frontend

# Copy frontend source code
COPY frontend/ ./frontend/

# Build production static assets
RUN npm run build --prefix frontend

# ==========================================
# Step 2: Production Execution Environment (Runner Stage)
# ==========================================
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

# Copy backend package manifests and install production-only dependencies
COPY backend/package*.json ./backend/
RUN npm ci --omit=dev --prefix backend

# Copy backend source code
COPY backend/ ./backend/

# Copy compiled frontend assets from builder stage
COPY --from=builder /app/frontend/build ./frontend/build

# Ensure upload directory exists for Multer
RUN mkdir -p backend/uploads uploads

EXPOSE 5000

CMD ["npm", "start", "--prefix", "backend"]
