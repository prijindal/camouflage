FROM node:20-alpine

RUN apk add --no-cache dumb-init

ENV NODE_ENV production

USER node

WORKDIR /app

EXPOSE 5001

COPY --chown=node:node .npmrc package*.json turbo.json /app/
COPY --chown=node:node packages /app/packages
RUN npm ci --omit=dev
COPY --chown=node:node apps /app/apps

CMD [ "dumb-init", "node", "apps/api/dist/index.js"]
