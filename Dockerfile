FROM node:24-alpine

WORKDIR /app

# Install openclaw globally
RUN npm install -g openclaw@latest

# Create openclaw config directory
RUN mkdir -p /root/.openclaw

# Copy config
COPY openclaw.json /root/.openclaw/openclaw.json

EXPOSE 18789

CMD ["openclaw", "gateway", "--port", "18789"]
