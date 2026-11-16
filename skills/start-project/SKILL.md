---
name: start-project
description: Bootstrap a new local-first, zero-cost dev project (server app, CLI/TUI or library) - DDD with lint-enforced layers, a ubiquitous-language glossary, Docker Compose, SQLite/PostgreSQL and generated OpenAPI for server apps, GitHub CI, and standing instructions. Use when the user wants to start, scaffold or bootstrap a new project or repository.
---

# Start a project

Use this skill when the user wants to start, scaffold, or bootstrap a new software project or repository. It covers the bootstrap only: from choosing the stack to the first commits and the project's standing instructions. The way of working afterwards lives in the process skills: `write-tests`, `review-changes`, `commit-changes` and `document-changes`. Follow them during the bootstrap too.

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

## Non-negotiables

These rules apply to every project, whatever the stack:

1. **SOLID and domain-driven, mostly framework-agnostic.** Business logic goes in domain and application layers that do not import the framework. The framework stays at the edges: HTTP, persistence adapters, queues and wiring. See Design principles.
2. **Minimalism.** Add only what the project needs today: no speculative abstractions, no unused packages, no boilerplate files "for later", and no configuration that only repeats a tool's defaults. When in doubt, leave it out.
3. **Local-first and zero-cost in the early phases.** No hosting, deployments, cloud services, paid APIs or subscriptions, domains, or pilot clients and other external users. Everything runs on the developer's machine. See Early phases.
4. **OpenAPI documentation is mandatory and auto-generated** for any HTTP API (skip for CLIs, TUIs and libraries). The spec is generated from code (routes, request validation, response resources, types). It is never hand-written. The generated spec is exported to a committed file, and CI fails if that file is out of date.
5. **Forward-only migrations** wherever there is a database. No `down` or rollback methods. A mistake is fixed with a new migration. Local resets rebuild the schema from scratch (e.g. `migrate:fresh`), which needs no `down` methods.
6. **One language version everywhere.** Each language version (and the database's major version) is set to exactly the same value in every place it appears. See Step 4.
7. **GitHub is the code host.** Use GitHub for the repository and GitHub Actions for CI, within the free tier, with `.github/` templates and the `gh` CLI when it is available. GitHub is not used to deploy anything.
8. **The framework bootstrap gets its own commit.** The unmodified framework scaffold is committed by itself before anything is customized.
9. **The database, if any, is SQLite or PostgreSQL.** No other database engines are offered or configured. A tool whose state is a few config files keeps them as plain files (YAML with a JSON Schema beside them), not a database.
10. **Server apps run locally on plain Docker Compose** (`compose.yaml` plus a project `Dockerfile`), served by a real web/app server. Never use framework-specific Docker wrappers (e.g. Laravel Sail) or framework dev servers. A CLI or TUI that drives the host (tmux, the shell, the user's files) runs natively, with no Docker: a container would drive the wrong machine.
11. **One ubiquitous language, written down.** A glossary table in `CLAUDE.md` names every concept once, with its user-facing word and its code identifiers (see Step 10). A new concept gets an entry before it gets code. Once the user-facing words are released (config keys, CLI, UI text), code that disagrees with them is renamed, never the reverse.
12. **Layer boundaries are enforced by a tool,** not by discipline: architecture tests or linter allow-lists that fail CI (see Step 6).
13. **Every change follows the process skills:** tests by `write-tests`, the end-of-change question by `review-changes`, commits by `commit-changes`, docs by `document-changes`.

## Early phases: local, free, no external users

A project stays in its early phase until the user explicitly says it is moving on (e.g. to hosting or pilot clients). Until then:

- **No hosting or deployment.** Do not add deploy workflows, continuous delivery, container registry pushes, infrastructure-as-code, hosting or platform config files (Fly, Vercel, Forge, Heroku, Kubernetes and similar), or a production Docker stage. The Dockerfile targets local development only.
- **No expenses.** Use only free, open-source tools and GitHub's free tier. Never add a dependency that needs a paid account, API key, or subscription, including error tracking, analytics, email delivery, or cloud storage SaaS.
- **Local substitutes for external services**, added only when a feature actually needs them:
  - mail: Mailpit in Compose
  - file storage: the local filesystem
  - queues and cache: the database or a sync/file driver
  - third-party APIs (payments, SMS, maps and so on): a domain-owned port with an in-memory or fake adapter. Write the real adapter later, when the phase changes. DDD ports make this swap cheap.
- **No pilot clients or real users.** Do not add onboarding, invitation, multi-tenant billing, or other features whose only purpose is serving real external users. Use factories and seeders with realistic fake data, and never real customer data.
- **Keep CI cheap.** The repository is private by default, and private repos have limited free Actions minutes. Use `concurrency` with `cancel-in-progress: true`, cache dependencies, and keep the workflow to the jobs listed in Step 9. Do not use paid runners or features (larger runners, Codespaces, paid Packages storage).
- **No releases.** Publishing binaries or packages for others to install serves external users, so a release pipeline waits until the project leaves the early phase. Then, release on a `vX.Y.Z` tag after the tests pass, with the stack's release tool.

If the user asks for something that breaks these rules during an early phase, point that out in one line and ask whether the project is moving out of the early phase.

## Design principles

Apply these to all generated code, including the example slice, and write them into the project's `CLAUDE.md`:

- **SOLID.** Classes have one reason to change. Depend on interfaces the domain owns (ports), not concrete infrastructure. Prefer composition over inheritance. Keep interfaces small.
- **Rich domain model.** Behaviour lives on entities and value objects, not in services that pull data out and push it back (tell, don't ask). Avoid anemic models, setters and public mutable state.
- **Value objects everywhere they add meaning** (`Email`, `Money`, `OrderId`). They are immutable, validated on construction, and compared by value.
- **Elegant, fluent APIs.** Use expressive named constructors (`Money::of(100, Currency::EUR)`, `Order::place(...)`), intention-revealing method names, immutable `with...()` methods that return new instances, and chaining where it reads like a sentence. Do not chain for its own sake, and do not use static helper grab-bags.
- **Defaults:** classes are `final`, properties are `readonly` where the language allows, types are strict, and domain errors are specific exception classes with named constructors (`InsufficientFunds::forAccount($id)`).
- **Ubiquitous language.** Class and method names come from the domain, not from the framework or the database.

## Stack skills

Everything specific to a language or framework lives in its stack skill. Once the stack is chosen in Step 1, load it and follow it alongside the steps below:

- `laravel-stack`: Laravel (PHP)
- `symfony-stack`: Symfony (PHP)
- `typescript-stack`: TypeScript / Node
- `python-stack`: Python
- `go-stack`: Go, including CLIs and TUIs

For a stack with no stack skill, apply the same principles with that stack's usual tools, and offer to write its stack skill when the bootstrap is done.

## Step 1: Ask about the stack

Before creating any files, ask with AskUserQuestion, or in plain text if that tool is unavailable. Combine the questions into as few rounds as possible:

- **Language and framework**, with versions: e.g. Laravel, Symfony, NestJS, Express or Fastify, FastAPI, Django, Go, or plain language with no framework.
- **Project type:** REST API only, API plus SPA frontend, full-stack monolith, CLI, TUI, or library.
- **Database**, one of:
  - **PostgreSQL everywhere** (local and CI). Recommended for most server apps.
  - **SQLite everywhere.** Good for small apps, CLIs, and prototypes.
  - **PostgreSQL as the main database, SQLite for fast local tests.** If chosen, CI still runs the feature suite against PostgreSQL, so engine differences cannot slip through.
  - **None** (e.g. a library or a stateless service).
- **First bounded context(s):** what the core domain is called, e.g. `Billing` or `Catalog`. Offer to start with one.
- **GitHub remote:** create a private repo now with `gh repo create` (public only if the user asks), use an existing remote, or stay local only.
- **Stack-specific options** listed in the stack skill, e.g. for Laravel: whether to include Rector.

Do not ask about the local environment (Docker Compose for server apps, native for CLIs and TUIs), the OpenAPI approach (always generated), or hosting (none in the early phases).

For a CLI, TUI or library, skip the questions about Docker and OpenAPI, and the steps and Step 3 rows they cover.

If the user has already answered some of these, do not ask them again. If no one is available to answer, choose sensible defaults (latest stable language version, PostgreSQL for server apps, SQLite for CLIs and prototypes, private repo), list them at the top of your reply, and continue.

## Step 2: Bootstrap the framework (commit 1)

1. Run the framework's official installer, e.g. `composer create-project laravel/laravel`, `nest new`, or `uv init`. Change nothing yet: not the database settings, not the framework's Docker wrapper, not the default migrations.
2. `git init -b main` if the installer did not, then make sure the scaffold's `.gitignore` is present.
3. Commit only the scaffold: `chore: bootstrap <framework> <version>`. This commit skips the `review-changes` question, since it contains no hand-written code.

## Step 3: Customize in small, separate commits

Each step below is one change and one commit, in roughly this order. Skip a step if it does not apply. End each step as `review-changes` says.

| Step | Example commit |
|---|---|
| Editor and repo hygiene (`.editorconfig`, `.gitattributes`, `.dockerignore`) | `chore: add editorconfig, gitattributes and dockerignore` |
| Pin the language version in every location (Step 4) | `build: pin php 8.4 across the project` |
| Docker Compose environment, server apps only (removing the framework's Docker wrapper and dev server usage if present) | `build: add docker compose environment` |
| Database configuration (and Compose service if PostgreSQL) | `build: configure postgresql` / `build: configure sqlite` |
| Forward-only migrations (strip `down` from existing migrations and stubs) | `build: make migrations forward-only` |
| Code style / formatter | `build: add pint` |
| Static analysis | `build: add phpstan at max level` |
| Automated refactoring (if chosen) | `build: add rector` |
| Test framework and config | `test: set up pest` |
| DDD directory structure and autoloading | `refactor: introduce domain-driven structure` |
| Architecture tests or linter allow-lists enforcing layer boundaries | `test: add architecture tests` / `build: allow-list what domain and app may import` |
| Example vertical slice | `feat(<context>): add <use case>` |
| OpenAPI generation, export command, and committed spec | `docs: add generated openapi documentation` |
| GitHub Actions CI | `ci: add github actions workflow` |
| GitHub templates and Dependabot | `chore: add github templates and dependabot` |
| README, docs skeleton and agent instructions with the glossary | `docs: add readme and agent instructions` |

Before every commit, and at the end of each iteration of work, run the formatter, static analysis and every test suite, and make sure they pass. Never commit a red build.

## Step 4: One version everywhere

Choose the language version once, e.g. PHP `8.4`, and use exactly that value in every place it appears. Where a tool can read the version from a file, point it at that file rather than repeating the number. The stack skill lists the places for its language. The PostgreSQL major version is the same in `compose.yaml` and in the CI service container.

When the version changes later, change every location in the same commit. The reviewer checks this.

## Step 5: Docker Compose

Server apps only.

- Write a project `Dockerfile` for local development, based on the official language image, with the version taken from a build `ARG` set to the pinned value. Install only the extensions and tools the project needs. Do not add a production stage during the early phases.
- Write `compose.yaml` (not `docker-compose.yml`, and no top-level `version:` key) with:
  - `app`: built from the Dockerfile, with the source bind-mounted, running as a non-root user whose UID/GID matches the host.
  - a real web/app server, as the stack skill says. Never a framework dev server.
  - `postgres` when PostgreSQL is used (see Step 7), with `depends_on` and `condition: service_healthy`.
  - local substitutes such as Mailpit, only once a feature needs them (see Early phases).
  - Named volumes for database data.
- Bind published ports to `127.0.0.1` so nothing is exposed beyond the developer's machine.
- Configure everything through `.env`. Commit `.env.example` with local-only values and no third-party keys. Never commit `.env`.
- All project commands run through Compose. Add a short `Makefile` with only the targets that are used: `up`, `stop`, `shell`, `test`, `check`, `docs`, and `seed` once seeders exist.

## Step 6: DDD structure

Organize by bounded context first, then by layer:

```
src/
  <Context>/
    Domain/          # Entities, value objects, domain events, repository interfaces, domain services. Pure language, no framework.
    Application/     # Use cases / command & query handlers, DTOs, ports. No framework.
    Infrastructure/  # Framework- and vendor-specific adapters: ORM repositories, mail, queues, fake external services.
  Shared/            # Shared kernel, created only when something is genuinely shared.
```

The stack skill gives the language's own spelling of this layout.

The framework's own HTTP layer (controllers, requests, resources, routes) stays thin. It maps HTTP to application commands or queries and maps results back. This layer is also where the OpenAPI generator reads from, so it must be well typed (see Step 8).

Dependency rule: `Domain` depends on nothing. `Application` depends only on `Domain`. `Infrastructure` and the framework layer depend inward. Enforce this with the tool the stack skill names.

Ports go where their concept lives. Ports about domain concepts (repositories, external systems the domain drives) live in `Domain`. Ports for talking to the user (forms, confirmation prompts, an editor, pickers) live in `Application`. Every adapter, UI screens included, lives in `Infrastructure`. Screens and forms hold no logic: they only collect answers, which domain constructors check, or a choice, which a use case carries out.

Create one small example vertical slice in the first context: a value object, an entity with real behaviour, a repository interface, a use case, an in-memory repository, meaningful unit tests, and one endpoint that appears in the generated OpenAPI spec. It should show the design principles in practice. Keep it small, and do not add empty folders or placeholder classes.

## Step 7: Database

Persistence is an infrastructure concern:

- Domain and application code never know which engine is used. They talk to repository interfaces.
- Unit tests use in-memory repository implementations and never touch a database.
- Feature tests use a real database.
- Migrations are forward-only (non-negotiable 5). Never edit a migration that has been merged; add a new one.
- Development data comes from factories and seeders with realistic fake data, never real customer data.

### PostgreSQL

- Local: add a `postgres` service to `compose.yaml` using the official `postgres` image at the pinned major version, with a named volume and a `pg_isready` healthcheck.
- Create a separate test database, e.g. `<app>_test`, so running tests never wipes development data. An init script mounted into `/docker-entrypoint-initdb.d/` can create it.
- `.env.example` contains the full set of connection variables with local defaults, using `DB_HOST=postgres` (the Compose service name).
- CI: run a `postgres` service container at the same major version, with a health check, and point the test environment at it.
- PostgreSQL-specific features (jsonb, partial indexes, enums, `uuid` columns) are fine in Infrastructure and migrations, but must not leak into Domain.

### SQLite

- Store the file at `database/database.sqlite` (or the stack's equivalent) and gitignore it. It lives on the bind-mounted source, so it persists across container restarts. Create it on setup with a script or package-manager hook.
- Enable foreign keys (`PRAGMA foreign_keys = ON`) and WAL mode for app usage.
- Tests use `:memory:` for speed.
- Compose needs only the `app` service and the web server. CI needs no service container.

### Mixed (PostgreSQL as the main database, SQLite for fast tests)

- Compose runs `postgres` for development. Local tests default to SQLite `:memory:`.
- CI runs the suite twice, or uses a matrix: once on SQLite and once on PostgreSQL. A PostgreSQL failure blocks the merge.
- Keep migrations portable. If a PostgreSQL-only feature is needed, switch to PostgreSQL everywhere instead of maintaining engine-specific branches.

## Step 8: OpenAPI (auto-generated)

- Generate the spec from code using the generator the stack skill names. Prefer generators that infer from routes, validation and response types over ones that need hand-written annotations. If annotations or attributes are needed, put them only in the HTTP layer, never on Domain or Application classes.
- Add a single command that exports the spec to `docs/openapi.json` (OpenAPI 3.1 where the generator supports it), e.g. `make docs`. Commit the exported file so API changes show up in PR diffs.
- Generated docs are only as good as the code they read. Use typed request validation, typed response resources/DTOs, explicit status codes, and short summaries on endpoints. Use a consistent error response format (RFC 9457 problem+json) and declare security schemes.
- Serve the interactive docs UI locally only.
- CI has an `openapi` job that regenerates the spec, fails if `git diff --exit-code docs/openapi.json` shows changes (the committed spec is stale), and lints it with `npx @redocly/cli lint docs/openapi.json`.
- Where it adds real value, assert in feature tests that API responses match the generated spec.

## Step 9: GitHub

- `.github/workflows/ci.yml` runs on push and pull_request to `main`, with `concurrency` set to cancel superseded runs, and jobs for:
  - the formatter in check mode
  - static analysis
  - tests, against the chosen database as described in Step 7 (no coverage threshold)
  - the OpenAPI freshness check and lint
  - automated refactoring dry-run (if used)
  - building the Docker image, if there is one, so a broken Dockerfile fails CI. The image is never pushed anywhere.
  - a matrix over what users' machines vary in, when the code depends on it (e.g. the shells a tool types commands into, or the OS). Each leg costs free minutes, so cover only what really varies.

  Every job takes the language version from the pinned value (Step 4). Run the quality jobs natively with the language setup actions, which is faster and uses fewer free minutes than running them inside Compose. Cache dependencies. No deploy or release jobs.
- `.github/pull_request_template.md` with a short checklist:
  - [ ] Meaningful tests added/updated
  - [ ] Docs, schemas and the glossary updated for the change
  - [ ] OpenAPI spec regenerated and committed for any API change (if an API)
  - [ ] Forward-only migration included for any schema change (if a database)
  - [ ] Commits follow Conventional Commits
- `.github/dependabot.yml` for the package ecosystem, for GitHub Actions, and for Docker if used, on a weekly schedule to limit CI runs.
- The backlog lives in GitHub Issues, not in a file in the repo. Write the `gh` conventions the agent should follow into `docs/agents/issue-tracker.md`.
- If the user chose to create the remote: `gh repo create <name> --private --source=. --push` (or `--public` if asked). Otherwise, push only when asked.

## Step 10: Standing instructions in the repo

Write a `CLAUDE.md` (and an identical `AGENTS.md` if the user wants one for other tools) at the repo root so these rules apply to all future work, not just the bootstrap. It holds what is specific to this project; the process skills hold how work is done, and this file overrides them where it says so.

```markdown
# Project rules

## Phase
- Early phase: local-only and zero-cost. No hosting, deployment, paid services or API keys, and no pilot clients or real users. External services are faked behind domain ports or replaced by local containers (e.g. Mailpit). Ask before changing this.

## Design
- SOLID and DDD: src/<Context>/{Domain,Application,Infrastructure}. Domain and Application never import the framework; <architecture tests | depguard allow-lists> enforce this.
- Ports about domain concepts live in Domain; ports for talking to the user live in Application; every adapter lives in Infrastructure. Screens and forms hold no logic.
- Rich domain model, immutable value objects, expressive named constructors, fluent intention-revealing APIs. Final classes, readonly properties and strict types by default.
- Minimalism: add only what is needed now. No speculative abstractions, unused dependencies or placeholder files.

## Ubiquitous language

Code, configs, CLI, UI text, docs and commits use these words, and only these. Once the user-facing words are released, code that disagrees is renamed. A new concept gets an entry here before it gets code.

| Term | Meaning | Config / CLI / UI | Code |
| --- | --- | --- | --- |
| <term> | <one sentence; say what it is not, e.g. "Not 'stop'"> | <key, flag or screen> | <types and methods> |

## Environment
- <Docker Compose only, no framework Docker wrapper or dev server. Run commands through the Makefile or `docker compose exec app ...`. | No Docker: <the tool> drives the host's real <tmux, shell, files>.>
- <Language> version is <X.Y> everywhere (<the places from the stack skill>). Change all of them together, or none.
- Storage: <PostgreSQL | SQLite | PostgreSQL main, SQLite for fast tests | plain YAML files under <dir>, with a JSON Schema kept in step and checked by a test>. Persistence lives in Infrastructure only. Fake data only, from factories and seeders.
- Migrations are forward-only: never write `down` methods and never edit a merged migration. Fix mistakes with a new migration.

## API docs
- OpenAPI docs are auto-generated. **After any change to an endpoint, request validation, response resource, status code, or auth requirement, run `make docs` and commit the updated docs/openapi.json in the same commit.** CI fails if it is stale. Never hand-edit it; fix the code it is generated from.

## Processes
- Tests follow `write-tests`, reviews `review-changes`, commits `commit-changes`, and docs `document-changes`. Rules added below override them for this project.
- At the end of each iteration of work, run every test suite and every lint, and fix what fails before going on.
- Docs: <list which doc owns what>.
- Review checklist additions: OpenAPI regenerated for API changes, migrations forward-only, language version consistent everywhere, nothing that needs hosting or money.
```

Fill the glossary with the example slice's concepts. Put the actual commands (build, run, test, lint, docs; up and stop for Compose) in `docs/development.md` and point this file at it, so they live in one place. Also add one short Mermaid diagram of the layers and bounded contexts to `docs/development.md`; GitHub renders it.

Keep this file to rules and the glossary. How-tos the agent needs for specific jobs (driving the terminal tests, the issue tracker, recording a demo) go in `docs/agents/<topic>.md`, linked from here.

## Finish

When the bootstrap is done, show the user:
- `git log --oneline` of the bootstrap commits
- a Mermaid diagram (or inline visual) of the bounded contexts and layers, instead of a long description
- the commands to start the environment, run tests and checks, and regenerate the API docs
- the GitHub repo URL, if one was created

Then suggest the next step: model the first real use case in the chosen bounded context.
