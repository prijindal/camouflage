FROM node:20-alpine

ENV NODE_ENV production

WORKDIR /app

USER node

COPY --chown=node:node . /app

CMD [ "node", "apps/docs/.next/standalone/apps/docs/server.js"]
