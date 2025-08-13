FROM node:20-alpine3.19 AS build

WORKDIR /usr/src/app

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

COPY . .
RUN corepack enable && corepack prepare yarn@4.9.2 --activate
RUN yarn install
RUN yarn workspace api build

FROM node:20-alpine3.19

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/yarn.lock ./yarn.lock
COPY --from=build /usr/src/app/.yarnrc.yml ./.yarnrc.yml
COPY --from=build /usr/src/app/.yarn ./.yarn
COPY --from=build /usr/src/app/.pnp.* ./

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN corepack enable && corepack prepare yarn@4.9.2 --activate

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["yarn", "run", "start:prod"]