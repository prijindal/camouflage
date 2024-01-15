# Context will be root
FROM node:20-alpine as BUILD

RUN apk add --no-cache dumb-init

WORKDIR /app

EXPOSE 5001

COPY .npmrc package*.json turbo.json /app/
COPY packages /app/packages
COPY apps/api/package* /app/apps/api/

RUN npm ci

COPY apps/api /app/apps/api

RUN npm run build

ENV NODE_ENV production

RUN npm ci --omit=dev


FROM node:20-alpine

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init

WORKDIR /app

USER node
COPY --chown=node:node --from=BUILD /app /app

CMD [ "dumb-init", "node", "apps/api/dist/index.js"]
