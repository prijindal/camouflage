# Context will be root
FROM node:20-alpine as BUILD

WORKDIR /app

EXPOSE 5001

COPY .npmrc package*.json turbo.json /app/
COPY packages /app/packages
COPY apps/docs/package* /app/apps/docs/

RUN npm ci

COPY apps/docs /app/apps/docs

RUN npm run build

ENV NODE_ENV production

RUN npm ci --omit=dev


FROM node:20-alpine

WORKDIR /app

USER node
COPY --chown=node:node --from=BUILD /app /app

CMD [ "node", "apps/docs/.next/standalone/apps/docs/server.js"]
