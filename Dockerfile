FROM node:20.18 AS base

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /usr/src/app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install 

FROM base AS build

WORKDIR /usr/src/app

COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
RUN pnpm prune --prod

FROM node:20-alpine3.21 AS deploy

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

ENV CLOUDFLARE_ACCESS_KEY_ID="9c61d3042114f2e4cb2a63a5a50eebef"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="4053d29402517aa238287f20a9fc770b184ef1b0c0abc5c0403507cb05aa2984"
ENV CLOUDFLARE_BUCKET="ftr-upload-widget"
ENV CLOUDFLARE_ACCOUNT_ID="34c87ab1613a1afc6567344b2e5c1088"
ENV CLOUDFLARE_PUBLIC_URL="https://pub-97abb5beafd144d8b12b9244ef8767ff.r2.dev"

EXPOSE 3333

CMD ["node", "dist/server.mjs"]