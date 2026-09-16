FROM node:22-slim

WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY server.js ./
RUN groupadd --system app && useradd --system --gid app app && chown -R app:app /app
USER app

EXPOSE 4080
CMD ["node", "server.js"]
