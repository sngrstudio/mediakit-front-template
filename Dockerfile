FROM node:22.12.0-bookworm@sha256:35a5dd72bcac4bce43266408b58a02be6ff0b6098ffa6f5435aeea980a8951d7 AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS builder-base
WORKDIR /usr/src/app
COPY package.json pnpm-lock.yaml ./

FROM builder-base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM builder-base AS builder
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM node:22.12.0-bookworm-slim@sha256:a4b757cd491c7f0b57f57951f35f4e85b7e1ad54dbffca4cf9af0725e1650cd8 AS runtime
RUN apt update && apt install -y --no-install-recommends dumb-init
WORKDIR /usr/src/app

USER node
COPY --chown=node:node --from=prod-deps /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=builder /usr/src/app/dist ./dist

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

CMD ["dumb-init", "node", "./dist/server/entry.mjs"]