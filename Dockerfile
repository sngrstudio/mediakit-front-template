FROM node:20.18.1-bookworm@sha256:f4755c9039bdeec5c736b2e0dd5b47700d6393b65688b9e9f807ec12f54a8690 AS base
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

FROM node:20.18.1-bookworm-slim@sha256:f44fa8d6d0ef15fe252459ac5d3d178362231a7948d7d07e147bae891006e2e5 AS runtime
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