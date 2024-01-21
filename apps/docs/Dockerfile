FROM node:20-alpine

ENV NODE_ENV production

WORKDIR /app

USER node

COPY --chown=node:node . /app

WORKDIR /app/apps/docs

CMD [ "npm", "start"]
