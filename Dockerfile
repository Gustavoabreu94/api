# Build stage
FROM node:18-alpine3.19 AS build

WORKDIR /usr/src/app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn set version berry

RUN yarn install

COPY . .

RUN yarn run build && yarn cache clean

# Production stage
FROM node:18-alpine3.19 AS production-deps

WORKDIR /usr/src/app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn set version berry

RUN yarn workspaces focus --production && yarn cache clean

FROM node:18-alpine3.19

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=production-deps /usr/src/app/node_modules ./node_modules

EXPOSE 3000

CMD ["yarn", "run", "start:prod"]