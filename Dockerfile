# Step 1: Build Frontend & Backend Dependencies
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files from root, backend, and frontend
COPY package*.json ./
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Install root, backend, and frontend dependencies
RUN npm run render-build

# Copy the rest of the application source code
COPY . .

# Build the frontend static files
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
COPY --from=builder /app/frontend/dist ./frontend/dist

EXPOSE 10000

CMD ["npm", "start", "--prefix", "backend"]
