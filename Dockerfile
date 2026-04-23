FROM node:22-slim

WORKDIR /app

# Install openssl for certificate generation
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /app/data/inbox /app/data/outbox /app/data/sent /app/data/failed /app/certs

# Copy application files
COPY package.json ./
RUN npm install --production

COPY server.js ./
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 4080

ENTRYPOINT ["/app/entrypoint.sh"]
