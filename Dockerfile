FROM node:20.16.0-bookworm@sha256:d3c8ababe9566f9f3495d0d365a5c4b393f607924647dd52e75bf4f8a54effd3 AS base
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

FROM node:20.16.0-bookworm-slim@sha256:2d4585684de1a8483b91ed507cefb6270e8e0f3feff1a2d586e95d3e13c1af39 AS runtime
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