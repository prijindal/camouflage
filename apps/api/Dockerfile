FROM node:20-alpine

RUN apk add --no-cache dumb-init

ENV NODE_ENV production

WORKDIR /app

USER node

COPY --chown=node:node . /app

RUN npm install better-sqlite3

CMD [ "dumb-init", "node", "apps/api/dist/index.js"]
