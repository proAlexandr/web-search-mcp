# Use Node.js 18 base image (matches project requirements)
FROM node:18-bullseye

# Install Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Install Playwright browsers
RUN npx playwright install && npx playwright install-deps

# Install uv for running mcpo
RUN pip install uv

# Expose the port mcpo will use
EXPOSE 3000

# Set environment variables for optimal container performance
ENV BROWSER_HEADLESS=true

# Copy source code
COPY . .

# Build the TypeScript project
RUN npm run build

# Run the MCP server via mcpo over HTTP using uvx
CMD ["uvx", "mcpo", "--host", "0.0.0.0", "--port", "3000", "--", "node", "dist/index.js"]