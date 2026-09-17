# Step 1: Build Frontend & Backend Dependencies
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Copy ALL source code BEFORE building
COPY . .

# Install dependencies and build
RUN npm run render-build
RUN npm run build --prefix frontend

# Step 2: Production Execution Environment
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=10000

# Copy root and backend packages for production install
COPY package*.json ./
COPY backend/package*.json ./backend/

# Install production dependencies only
RUN npm ci --only=production --prefix backend

# Copy backend source files and the compiled frontend build from builder
COPY --from=builder /app/backend ./backend
COPY --from=builder /app/frontend/build ./frontend/build

EXPOSE 10000

CMD ["npm", "start", "--prefix", "backend"]
