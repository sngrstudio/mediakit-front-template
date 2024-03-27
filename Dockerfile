FROM node:20.11.1-bookworm AS base
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

FROM oven/bun:1.0.35-slim AS runtime
RUN apt update && apt install -y --no-install-recommends dumb-init
WORKDIR /usr/src/app

USER bun
COPY --chown=bun:bun --from=prod-deps /usr/src/app/node_modules ./node_modules
COPY --chown=bun:bun --from=builder /usr/src/app/dist ./dist

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

CMD ["dumb-init", "bun", "run", "./dist/server/entry.mjs"]