FROM node:22.14.0-bookworm@sha256:cfef4432ab2901fd6ab2cb05b177d3c6f8a7f48cb22ad9d7ae28bb6aa5f8b471 AS base
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

FROM node:22.14.0-bookworm-slim@sha256:91be66fb4214c9449836550cf4c3524489816fcc29455bf42d968e8e87cfa5f2 AS runtime
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