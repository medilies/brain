---
name: typescript-stack
description: TypeScript and Node project preferences (versions, Docker, layer boundaries, database, OpenAPI, tools). Use whenever working in or bootstrapping a TypeScript or Node project.
---

# TypeScript / Node stack

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

Headings name the `start-project` step they serve during a bootstrap. Outside a bootstrap, follow them whenever the topic comes up.

## Versions (Step 4)

`.nvmrc` or `.node-version` is the source of truth. `engines.node` in `package.json`, `ARG NODE_VERSION` in the Dockerfile, and `node-version-file` in `actions/setup-node` follow it.

## Docker (Step 5)

The official `node` image running the app's own server. Never a framework dev server with hot reload as the served app.

## Layers (Step 6)

Keep domain and application outside framework modules (e.g. outside Nest modules). Enforce boundaries with dependency-cruiser.

## Database (Step 7)

Drizzle or Kysely, with `pg` or `better-sqlite3`, behind repository interfaces, with forward-only migrations.

## OpenAPI (Step 8)

- NestJS: `@nestjs/swagger` with its CLI plugin.
- Fastify: `@fastify/swagger` with route schemas.
- Express: zod-to-openapi.

## Tools

Strict `tsconfig`, ESLint plus Prettier (or Biome), Vitest for unit tests.
