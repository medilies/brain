---
name: "start-dev-project"
description: "Bootstrap a local-first, zero-cost dev project (server app, CLI/TUI or library): DDD, a ubiquitous-language glossary, lint-enforced layers, Docker Compose, SQLite/PostgreSQL and generated OpenAPI for server apps, real-terminal tests for TUIs, meaningful tests, docs rules, GitHub CI, conventional commits, subagent review loops."
---

# Start a dev project

Use this skill when the user wants to start, scaffold, or bootstrap a new software project or repository.

## Non-negotiables

These rules apply to every project, whatever the stack:

1. **SOLID and domain-driven, mostly framework-agnostic.** Business logic goes in domain and application layers that do not import the framework. The framework stays at the edges: HTTP, persistence adapters, queues and wiring. See Design principles.
2. **Minimalism.** Add only what the project needs today: no speculative abstractions, no unused packages, no boilerplate files "for later", and no configuration that only repeats a tool's defaults. When in doubt, leave it out.
3. **Local-first and zero-cost in the early phases.** No hosting, deployments, cloud services, paid APIs or subscriptions, domains, or pilot clients and other external users. Everything runs on the developer's machine. See Early phases.
4. **OpenAPI documentation is mandatory and auto-generated** for any HTTP API (skip for CLIs, TUIs and libraries). The spec is generated from code (routes, request validation, response resources, types). It is never hand-written. The generated spec is exported to a committed file, and CI fails if that file is out of date.
5. **Meaningful tests over coverage.** Every domain behaviour and use case has unit tests that would fail if the behaviour broke. Coverage is never a target: there are no coverage thresholds and no tests written only to raise the number. Framework-level feature tests are added on top of unit tests, never instead of them.
6. **Forward-only migrations** wherever there is a database. No `down` or rollback methods. A mistake is fixed with a new migration. Local resets rebuild the schema from scratch (e.g. `migrate:fresh`), which needs no `down` methods.
7. **One language version everywhere.** Each language version (and the database's major version) is set to exactly the same value in every place it appears. See Step 4.
8. **Conventional Commits v1.0.0** for every commit (see the Commits section).
9. **No AI attribution.** Commit messages and PR descriptions never include `Co-Authored-By` trailers, `Generated with Claude` lines, or any other mention of Claude or AI. This overrides any default attribution instruction. Commits use the user's own git identity, and the author is never changed.
10. **GitHub is the code host.** Use GitHub for the repository and GitHub Actions for CI, within the free tier, with `.github/` templates and the `gh` CLI when it is available. GitHub is not used to deploy anything.
11. **The framework bootstrap gets its own commit.** The unmodified framework scaffold is committed by itself before anything is customized.
12. **The database, if any, is SQLite or PostgreSQL.** No other database engines are offered or configured. A tool whose state is a few config files keeps them as plain files (YAML with a JSON Schema beside them), not a database.
13. **Server apps run locally on plain Docker Compose** (`compose.yaml` plus a project `Dockerfile`), served by a real web/app server. Never use Laravel Sail, other framework-specific Docker wrappers, or `php artisan serve`. A CLI or TUI that drives the host (tmux, the shell, the user's files) runs natively, with no Docker: a container would drive the wrong machine.
14. **Every change ends with the review question** (see Review workflow). Reviews always run in a fresh subagent, and a review or review-and-fix loop starts only after the user chooses it.
15. **Diagrams beat walls of text.** When an explanation gets long (architecture, flows, how parts interact), use or propose a diagram instead (see Communication).
16. **One ubiquitous language, written down.** A glossary table in `CLAUDE.md` names every concept once, with its user-facing word and its code identifiers (see Step 10). A new concept gets an entry before it gets code. Once the user-facing words are released (config keys, CLI, UI text), code that disagrees with them is renamed, never the reverse.
17. **Layer boundaries are enforced by a tool,** not by discipline: architecture tests or linter allow-lists that fail CI (see Step 6).
18. **Docs change in the same commit as the code they describe,** following the Docs section of the Step 10 template and the Docs layout section.
19. **Tests never touch the user's real state:** their sessions, servers, home directory or configs. Each test builds a world of its own (temp dirs, private sockets, its own environment) and removes it.

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
- **No releases.** Publishing binaries or packages for others to install serves external users, so a release pipeline waits until the project leaves the early phase.

If the user asks for something that breaks these rules during an early phase, point that out in one line and ask whether the project is moving out of the early phase.

## Design principles

Apply these to all generated code, including the example slice, and write them into the project's `CLAUDE.md`:

- **SOLID.** Classes have one reason to change. Depend on interfaces the domain owns (ports), not concrete infrastructure. Prefer composition over inheritance. Keep interfaces small.
- **Rich domain model.** Behaviour lives on entities and value objects, not in services that pull data out and push it back (tell, don't ask). Avoid anemic models, setters and public mutable state.
- **Value objects everywhere they add meaning** (`Email`, `Money`, `OrderId`). They are immutable, validated on construction, and compared by value.
- **Elegant, fluent APIs.** Use expressive named constructors (`Money::of(100, Currency::EUR)`, `Order::place(...)`), intention-revealing method names, immutable `with...()` methods that return new instances, and chaining where it reads like a sentence. Do not chain for its own sake, and do not use static helper grab-bags.
- **Defaults:** classes are `final`, properties are `readonly` where the language allows, types are strict, and domain errors are specific exception classes with named constructors (`InsufficientFunds::forAccount($id)`).
- **Ubiquitous language.** Class and method names come from the domain, not from the framework or the database.

## Step 1: Ask about the stack

Before creating any files, ask with AskUserQuestion, or in plain text if that tool is unavailable. Combine the questions into as few rounds as possible:

- **Language and framework**, with versions: e.g. Laravel, Symfony, NestJS, Express or Fastify, FastAPI, Django, Go, or plain language with no framework.
- **Project type:** REST API only, API plus SPA frontend, full-stack monolith, CLI, or library.
- **Database**, one of:
  - **PostgreSQL everywhere** (local and CI). Recommended for most server apps.
  - **SQLite everywhere.** Good for small apps, CLIs, and prototypes.
  - **PostgreSQL as the main database, SQLite for fast local tests.** If chosen, CI still runs the feature suite against PostgreSQL, so engine differences cannot slip through.
  - **None** (e.g. a library or a stateless service).
- **First bounded context(s):** what the core domain is called, e.g. `Billing` or `Catalog`. Offer to start with one.
- **GitHub remote:** create a private repo now with `gh repo create` (public only if the user asks), use an existing remote, or stay local only.
- **Stack-specific options,** e.g. for Laravel: whether to include Rector.

Do not ask about the local environment (Docker Compose for server apps, native for CLIs and TUIs), the OpenAPI approach (always generated), or hosting (none in the early phases).

For a CLI, TUI or library, skip the questions about Docker and OpenAPI, and the steps and Step 3 rows they cover. For a TUI, follow the CLI and TUI section as well.

If the user has already answered some of these, do not ask them again. If no one is available to answer, choose sensible defaults (latest stable language version, PostgreSQL for server apps, SQLite for CLIs and prototypes, private repo), list them at the top of your reply, and continue.

## Step 2: Bootstrap the framework (commit 1)

1. Run the framework's official installer, e.g. `composer create-project laravel/laravel`, `nest new`, or `uv init`. Change nothing yet: not the database settings, not Sail, not the default migrations.
2. `git init -b main` if the installer did not, then make sure the scaffold's `.gitignore` is present.
3. Commit only the scaffold: `chore: bootstrap <framework> <version>`. This commit is made without the review question, since it contains no hand-written code.

## Step 3: Customize in small, separate commits

Each step below is one change and one conventional commit, in roughly this order. Skip a step if it does not apply. End each step with the review question (see Review workflow).

| Step | Example commit |
|---|---|
| Editor and repo hygiene (`.editorconfig`, `.gitattributes`, `.dockerignore`) | `chore: add editorconfig, gitattributes and dockerignore` |
| Pin the language version in every location (Step 4) | `build: pin php 8.4 across the project` |
| Docker Compose environment, server apps only (removing Sail and `artisan serve` usage if present) | `build: add docker compose environment` |
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
| Release pipeline, CLIs and libraries, only once the project leaves the early phase (e.g. GoReleaser on a `vX.Y.Z` tag) | `ci: release binaries on version tags` |

Before every commit, and at the end of each iteration of work, run the formatter, static analysis and every test suite, and make sure they pass. Never commit a red build.

## Step 4: One version everywhere

Choose the language version once, e.g. PHP `8.4`, and use exactly that value in every place it appears. Where a tool can read the version from a file, point it at that file rather than repeating the number.

- **PHP:** `composer.json` `require.php` (`^8.4`) and `config.platform.php` (`8.4`); `ARG PHP_VERSION=8.4` in the Dockerfile; `php-version` in `shivammathur/setup-php` in every CI job; Rector's PHP set; PHPStan's `phpVersion` if set.
- **Node:** `.nvmrc` or `.node-version` (the source of truth), `engines.node` in `package.json`, `ARG NODE_VERSION` in the Dockerfile, and `node-version-file` in `actions/setup-node`.
- **Python:** `.python-version` (the source of truth), `requires-python`, Ruff's `target-version`, mypy's `python_version`, the Dockerfile, and `python-version-file` in `actions/setup-python`.
- **Go:** `go.mod` is the source of truth. Its `go` directive (e.g. `1.26.0`, which the `go` command insists on) sets the language version, and its `toolchain` directive the exact Go that CI and releases build with. `actions/setup-go` reads it with `go-version-file: go.mod`, and so does the Dockerfile if there is one. Bump `toolchain` when a patch release ships.
- **PostgreSQL:** the same major version in `compose.yaml` and in the CI service container.

When the version changes later, change every location in the same commit. The reviewer checks this.

## Step 5: Docker Compose

- Write a project `Dockerfile` for local development, based on the official language image, with the version taken from a build `ARG` set to the pinned value. Install only the extensions and tools the project needs (for PHP: e.g. `pdo_pgsql` or `pdo_sqlite`, `intl`, `opcache`, plus Composer copied from the official `composer` image). Do not add a production stage during the early phases.
- Write `compose.yaml` (not `docker-compose.yml`, and no top-level `version:` key) with:
  - `app`: built from the Dockerfile, with the source bind-mounted, running as a non-root user whose UID/GID matches the host.
  - a real web/app server: `nginx` in front of php-fpm, or FrankenPHP as a single container, for PHP. Use the runtime's own server for other stacks. Never use framework dev servers such as `php artisan serve`.
  - `postgres` when PostgreSQL is used (see Step 7), with `depends_on` and `condition: service_healthy`.
  - local substitutes such as Mailpit, only once a feature needs them (see Early phases).
  - Named volumes for database data.
- Bind published ports to `127.0.0.1` so nothing is exposed beyond the developer's machine.
- Configure everything through `.env`. Commit `.env.example` with local-only values and no third-party keys. Never commit `.env`.
- For Laravel, in the Compose commit: run `composer remove --dev laravel/sail`, and remove or rewrite the scaffold's `dev` composer script, which runs `php artisan serve`.
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

The framework's own HTTP layer (controllers, requests, resources, routes) stays thin. It maps HTTP to application commands or queries and maps results back. This layer is also where the OpenAPI generator reads from, so it must be well typed (see Step 8).

Dependency rule: `Domain` depends on nothing. `Application` depends only on `Domain`. `Infrastructure` and the framework layer depend inward. Enforce this with architecture tests or linter allow-lists: Pest `arch()`, dependency-cruiser for TypeScript, import-linter for Python, deptrac, or golangci-lint's `depguard` in strict list mode for Go (see Stack presets).

Ports go where their concept lives. Ports about domain concepts (repositories, external systems the domain drives) live in `Domain`. Ports for talking to the user (forms, confirmation prompts, an editor, pickers) live in `Application`. Every adapter, UI screens included, lives in `Infrastructure`. Screens and forms hold no logic: they only collect answers, which domain constructors check, or a choice, which a use case carries out.

Create one small example vertical slice in the first context: a value object, an entity with real behaviour, a repository interface, a use case, an in-memory repository, meaningful unit tests, and one endpoint that appears in the generated OpenAPI spec. It should show the design principles in practice. Keep it small, and do not add empty folders or placeholder classes.

## Step 7: Database

Persistence is an infrastructure concern:

- Domain and application code never know which engine is used. They talk to repository interfaces.
- Unit tests use in-memory repository implementations and never touch a database.
- Feature tests use a real database.
- Migrations are forward-only (non-negotiable 6). Never edit a migration that has been merged; add a new one.
- Development data comes from factories and seeders with realistic fake data, never real customer data.

### PostgreSQL

- Local: add a `postgres` service to `compose.yaml` using the official `postgres` image at the pinned major version, with a named volume and a `pg_isready` healthcheck.
- Create a separate test database, e.g. `<app>_test`, so running tests never wipes development data. An init script mounted into `/docker-entrypoint-initdb.d/` can create it.
- `.env.example` contains the full set of connection variables with local defaults, using `DB_HOST=postgres` (the Compose service name).
- CI: run a `postgres` service container at the same major version, with a health check, and point the test environment at it.
- PostgreSQL-specific features (jsonb, partial indexes, enums, `uuid` columns) are fine in Infrastructure and migrations, but must not leak into Domain.

### SQLite

- Store the file at `database/database.sqlite` (or the stack's equivalent) and gitignore it. It lives on the bind-mounted source, so it persists across container restarts. Create it on setup with a script or composer/npm hook.
- Enable foreign keys (`PRAGMA foreign_keys = ON`) and WAL mode for app usage. Laravel enables foreign keys by default.
- Tests use `:memory:` for speed.
- Compose needs only the `app` service and the web server. CI needs no service container.

### Mixed (PostgreSQL as the main database, SQLite for fast tests)

- Compose runs `postgres` for development. Local tests default to SQLite `:memory:`.
- CI runs the suite twice, or uses a matrix: once on SQLite and once on PostgreSQL. A PostgreSQL failure blocks the merge.
- Keep migrations portable. If a PostgreSQL-only feature is needed, switch to PostgreSQL everywhere instead of maintaining engine-specific branches.

## Step 8: OpenAPI (auto-generated)

- Generate the spec from code using the stack's generator (see Stack presets). Prefer generators that infer from routes, validation and response types over ones that need hand-written annotations. If annotations or attributes are needed, put them only in the HTTP layer, never on Domain or Application classes.
- Add a single command that exports the spec to `docs/openapi.json` (OpenAPI 3.1 where the generator supports it), e.g. `make docs`. Commit the exported file so API changes show up in PR diffs.
- Generated docs are only as good as the code they read. Use typed request validation (e.g. FormRequests), typed response resources/DTOs, explicit status codes, and short summaries on endpoints. Use a consistent error response format (RFC 9457 problem+json) and declare security schemes.
- Serve the interactive docs UI locally only.
- CI has an `openapi` job that regenerates the spec, fails if `git diff --exit-code docs/openapi.json` shows changes (the committed spec is stale), and lints it with `npx @redocly/cli lint docs/openapi.json`.
- Where it adds real value, assert in feature tests that API responses match the generated spec, e.g. `hotmeteor/spectator` for Laravel.

## Step 9: GitHub

- `.github/workflows/ci.yml` runs on push and pull_request to `main`, with `concurrency` set to cancel superseded runs, and jobs for:
  - the formatter in check mode
  - static analysis
  - tests, against the chosen database as described in Step 7 (no coverage threshold)
  - the OpenAPI freshness check and lint
  - Rector dry-run (if used)
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
- The backlog lives in GitHub Issues, not in a file in the repo. A commit that finishes an issue closes it with `Closes #<n>`. Write the `gh` conventions the agent should follow into `docs/agents/issue-tracker.md`.
- If the user chose to create the remote: `gh repo create <name> --private --source=. --push` (or `--public` if asked). Otherwise, push only when asked.

## Step 10: Standing instructions in the repo

Write a `CLAUDE.md` (and an identical `AGENTS.md` if the user wants one for other tools) at the repo root so these rules apply to all future work, not just the bootstrap:

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
- <Docker Compose only (no Sail, no `php artisan serve`). Run commands through the Makefile or `docker compose exec app ...`. | No Docker: <the tool> drives the host's real <tmux, shell, files>.>
- <Language> version is <X.Y> everywhere (composer.json, Dockerfile, CI, tool configs). Change all of them together, or none.
- Storage: <PostgreSQL | SQLite | PostgreSQL main, SQLite for fast tests | plain YAML files under <dir>, with a JSON Schema kept in step and checked by a test>. Persistence lives in Infrastructure only. Fake data only, from factories and seeders.
- Migrations are forward-only: never write `down` methods and never edit a merged migration. Fix mistakes with a new migration.

## API docs
- OpenAPI docs are auto-generated. **After any change to an endpoint, request validation, response resource, status code, or auth requirement, run `make docs` and commit the updated docs/openapi.json in the same commit.** CI fails if it is stale. Never hand-edit it; fix the code it is generated from.

## Tests
- Meaningful tests over coverage: test behaviour through public APIs, one reason to fail per test, descriptive names. Prefer in-memory fakes to mocks. No coverage targets.
- Tests never touch the user's real state: each builds its own world (temp dirs, private sockets, its own environment) and removes it.
- Wait for a condition with a timeout, never for a fixed time.
- Never run tests in verbose mode (e.g. `go test -v`): the output floods the context. A failure prints without it; narrow it down with a filter.
- A bug found by hand gets a test that reproduces it.

## Docs
- A change updates, in the same commit, every doc it makes wrong: README, docs/*.md, schemas' descriptions, this file's glossary (its Code column included) and docs/agents/. Before committing, grep the docs for each key, flag, command, file and identifier the change renames or removes.
- Each fact lives in one doc; the others link to it. <list which doc owns what>
- Never list in full what the code lists: name a few as examples.
- User docs say what the tool does, not how: no internals, no history. History is in git, decisions in ADRs (docs/adr/), which are records and aren't updated.
- A screen shown in a doc is copied from a real run, never drawn by hand.
- Short sentences, and lists over long paragraphs.

## Workflow
- At the end of each iteration of work, run every test suite and every lint, and fix what fails before going on.
- At the end of each change, ask: review then commit / review-and-fix loop then commit / commit then review / commit without review. Nothing starts until I choose.
- Review-and-fix loop: 1 to 5 rounds (I pick the maximum and the baseline: uncommitted changes, the branch, or a commit). Each round: a fresh reviewer subagent, minimal fixes, then the full check. Stop early when clean. Goal: the smallest, simplest, performant and readable diff against the baseline, with no bugs or regressions.
- Reviews always run in a fresh subagent that has not seen the work, never in the main context. A review checks the docs a change touches against the Docs rules.
- A commit finishing an issue closes it with `Closes #<n>`.
- Commits follow Conventional Commits v1.0.0. Never add Co-Authored-By trailers or any mention of Claude/AI to commits or PRs.
- Use a Mermaid diagram (or an inline visual) when an explanation would otherwise be long.
```

Fill the glossary with the example slice's concepts. Put the actual commands (build, run, test, lint, docs; up and stop for Compose) in `docs/development.md` and point this file at it, so they live in one place. Also add one short Mermaid diagram of the layers and bounded contexts to `docs/development.md`; GitHub renders it.

Keep this file to rules and the glossary. How-tos the agent needs for specific jobs (driving the terminal tests, the issue tracker, recording a demo) go in `docs/agents/<topic>.md`, linked from here.

## Docs layout

Lay the docs out by reader, and give each fact one home. The rules every doc follows are in the template's Docs section above.

- **Users:** the README (what it is, install, a short usage example), then one `docs/<topic>.md` per topic once the README would grow past that.
- **Contributors:** `docs/development.md` (commands, architecture diagram, issues, releasing), `docs/adr/` for decisions (records, never updated), and `docs/left-out.md` once there is something deliberately left out, with the reason.
- **Agents:** `CLAUDE.md` and `docs/agents/`.

Create a doc only when there is something to put in it.

## CLI and TUI projects

- **Layout (Go):** `cmd/<binary>` is a thin Cobra layer that parses flags and wires adapters to use cases. Bubble Tea screens are adapters in `infra`, behind ports in `app` (e.g. `ProjectForm`, `Confirmation`).
- **Unit-test screen models** where they hold state worth testing (a form's undo, validation as you type) by sending them messages and reading their view, without a terminal.
- **Test the rest in a real terminal emulator.** Use the `tui-test` library (load the `tui-test` skill) to run the binary in a headless emulator, through tmux if the tool lives in tmux. Each test gets its own directory under a short `/tmp` path (socket paths max out at 108 bytes), its own server and environment, and a clean `PATH` that starts with the binary under test. Keep these tests behind a build tag, and run them in CI and against released binaries.
  - Checks wait for what must show, up to a timeout. Check what must and must not show on a single capture, since a redraw can match half-drawn.
  - On failure, write a trace an agent can read (`trace.md`: expected and found) alongside a replayable recording. Upload traces as a CI artifact.
  - Keep whole-screen snapshot tests few, rewritten with `-update`, so the snapshot diff is what gets reviewed.
  - If the agent's shell runs inside the user's tmux, every tmux command names the test's socket (`tmux -S <sock>`) after `unset TMUX`, so it can't reach the user's server.
- **The README demo** is recorded by a test run with a flag (e.g. `-demo FILE`), not by hand, so it can be re-recorded when the look changes. It's the one test allowed to sleep, to pace the story.
- **Release,** once the project leaves the early phase, with GoReleaser (or the stack's equivalent) on a `vX.Y.Z` tag, after the tests pass.

## Review workflow

### The question

At the end of each change (each Step 3 row during bootstrap, and each feature or fix afterwards), give a one-line summary of the change, then ask with AskUserQuestion:

- **Review, then commit:** one review pass on the uncommitted changes; fix the findings the user accepts; then commit.
- **Review-and-fix loop, then commit:** run the loop below, then commit.
- **Commit, then review:** commit now, review `HEAD`, and put any accepted fixes in a follow-up commit (`fix:` or `refactor:`).
- **Commit, skip review:** commit without reviewing.

No review or loop starts until the user has chosen. If AskUserQuestion is unavailable, ask in plain text. If no one is available to answer, commit, skip the review, and say so.

The user can also ask for a review or a loop at any time, on the current branch or since a given commit. Ask the loop setup questions first in that case too.

### Single review

Reviews always run in a **fresh subagent** (the Agent tool with a general-purpose agent, never a fork of the current context). That way the reviewer judges the code on its own merits, without the reasoning that produced it. Give the subagent:

- the repo path and the exact diff command: `git diff HEAD` plus untracked files for review-then-commit, or `git show HEAD` for commit-then-review
- the path to `CLAUDE.md`, which it must read first
- the checklist below
- an instruction to read whatever surrounding code it needs, to not edit any files, and to return findings ranked by severity with `file:line`, a one-sentence problem, and a suggested fix. Each finding is tagged **blocking** (bug, regression, security, or project-rule violation) or **improvement**. It should say "no findings" rather than invent nitpicks.

Checklist:

1. **Correctness:** bugs, edge cases, error handling, security (injection, mass assignment, authz), and regressions in callers of the changed code.
2. **DDD and SOLID:** layer boundaries respected, behaviour in the domain, no anemic models, responsibilities in the right place.
3. **Design quality and readability:** clear naming in the ubiquitous language, value objects where they add meaning, fluent and elegant APIs, final/readonly/strict types, code that reads without comments explaining it.
4. **Minimalism and simplicity:** unneeded code, abstractions, dependencies, configuration or files. Is there a simpler correct solution?
5. **Performance:** N+1 queries, unbounded result sets, needless loops or allocations, and missing indexes for new queries.
6. **Tests:** meaningful, behaviour-focused, would catch a real regression. Flag tests that exist only for coverage or that over-mock.
7. **Project rules:** OpenAPI regenerated for API changes, migrations forward-only with no `down`, language version consistent everywhere, Docker Compose only for server apps.
8. **Language and docs:** every name matches the glossary, new concepts have an entry, and the docs the change makes wrong are updated and follow the Docs rules.
9. **Early phase:** nothing that needs hosting, costs money, requires a third-party account or key, or serves real external users.
10. **Commit:** a Conventional Commits message, one logical change, no AI attribution.

Present the findings to the user concisely, and ask which to fix (all, some, or none) before changing anything.

### Review-and-fix loop

The goal is the smallest, simplest, performant and readable diff against the baseline, with no bugs and no regressions.

**Setup.** When the user picks the loop, ask both questions in one AskUserQuestion call:

- **Maximum rounds:** 1, 2, 3 or 5. The user can type 4.
- **Baseline:** the uncommitted changes (`HEAD`), the whole branch (`git merge-base main HEAD`), or since a specific commit (the user types the SHA). At the end of a change, the default is the uncommitted changes.

Resolve the baseline to a SHA. Run the full check (`make check`: formatter, static analysis, full test suite, OpenAPI freshness) once before round 1, and note anything already failing so it is not mistaken for a regression.

Once the user has approved the loop, run all rounds without stopping to ask, unless something below says to stop. **Each round:**

1. **Review.** Start a new fresh reviewer subagent. Never reuse or fork an earlier one. Give it everything a single review gets, but with `git diff <baseline>` plus untracked files as the diff. Add these instructions:
   - Judge the whole diff against the baseline, not just the last round's fixes.
   - Flag anything in the diff that could be removed, or done with less code, without losing behaviour.
   - Check the callers and the tests of changed code for regressions. Running the test suite is allowed, but editing files is not.
   - Do not re-raise a finding listed as dismissed in an earlier round unless there is new evidence.
2. **Fix.** In the main context, fix each valid finding with the smallest change that resolves it. Do not refactor unrelated code or add features. For each real bug, add a test that fails without the fix. Do not apply a finding that is wrong, or that would undo an earlier round's fix; record it as dismissed with a one-line reason.
3. **Test.** Run the full check. If something fails because of this round's fixes, fix it or revert that fix before the round ends. Never end a round red.
4. **Decide.** Stop early when the reviewer reports no blocking findings and no new improvements worth making, and the check is green. Otherwise, start the next round until the maximum is reached.

Stop and ask the user instead of continuing if a fix would change behaviour the user asked for, would need a new dependency, or would go against a project rule.

**After the loop**, report briefly:

- a small table: round → findings (blocking / improvement) → fixed → dismissed, with reasons
- the final check status
- `git diff --stat <baseline>`
- anything still unresolved

Then commit. Loop fixes on uncommitted work become part of that change's commit. When the baseline includes existing commits, the fixes go in a follow-up commit (`fix:` or `refactor:`). If blocking findings remain after the last round, ask before committing.

## Communication

- When an explanation would take more than a short paragraph (architecture, request flow, aggregate relationships, CI pipeline), show a diagram instead of or alongside the text. In chat, use an inline visual if available, otherwise a Mermaid code block. In repo docs, use Mermaid.
- Keep summaries short. Show `git log --oneline` rather than describing every commit.

## Commits

Format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- Types: `feat` (MINOR), `fix` (PATCH), plus `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`, `revert`.
- Scope is optional. Use the bounded context or area, e.g. `feat(billing): add invoice numbering`.
- Description: imperative mood, lowercase, no trailing period, about 72 characters or fewer.
- Breaking changes: put `!` before the colon (`feat(api)!: drop v1 endpoints`) and/or add a `BREAKING CHANGE: <description>` footer, which must be uppercase.
- Footers use `Token: value` or `Token #value`, with hyphens in place of spaces in tokens, e.g. `Refs: #42`.
- Keep each commit to one logical change.
- Never add `Co-Authored-By`, `Generated with`, or similar AI attribution lines.

## Stack presets

### Laravel (PHP)

- **Docker:** official `php:<version>-fpm` image plus `nginx`, or FrankenPHP as a single container, with `postgres` when used. Remove `laravel/sail` and any `php artisan serve` usage after the bootstrap commit.
- **Local drivers:** `MAIL_MAILER=smtp` pointing at Mailpit once mail is needed (`log` before then), `FILESYSTEM_DISK=local`, `QUEUE_CONNECTION=database` or `sync`, `CACHE_STORE=database` or `file`.
- **Forward-only migrations:** run `php artisan stub:publish`, keep only the `migration*.stub` files (delete the other published stubs), and remove the `down()` method from them. Remove `down()` from the scaffold's default migrations in the same commit.
- **Tests:** Pest (`pestphp/pest`, `pestphp/pest-plugin-laravel`). Unit tests go in `tests/Unit/<Context>/...` and must not boot the framework. Feature tests go in `tests/Feature` and use `RefreshDatabase`. Architecture tests go in `tests/Arch` using `arch()`, e.g.:
  ```php
  arch('domain is framework-free')
      ->expect('Src\\*\\Domain')
      ->not->toUse(['Illuminate', 'Laravel']);
  arch('application is framework-free')
      ->expect('Src\\*\\Application')
      ->not->toUse(['Illuminate', 'Laravel']);
  arch()->preset()->php();
  arch()->preset()->security();
  ```
  Adjust the namespace to whatever the autoload uses. Consider `arch()->preset()->strict()` for `src/` if it does not fight the framework.
- **Database:** Laravel's scaffold defaults to SQLite.
  - For PostgreSQL: set `DB_CONNECTION=pgsql`, `DB_HOST=postgres` and the other connection variables in `.env.example`; set the test database in `phpunit.xml` (`DB_DATABASE=<app>_test`); install `pdo_pgsql` in the Dockerfile and in CI via `shivammathur/setup-php`.
  - For SQLite-only: keep the default and use `DB_DATABASE=:memory:` in `phpunit.xml`.
  - For the mixed setup: use SQLite `:memory:` in `phpunit.xml`, and set `DB_CONNECTION=pgsql` in a CI matrix leg.
- **OpenAPI:** Scramble (`dedoc/scramble`). It generates the spec from routes, FormRequests, API Resources and return types, with no annotations. Configure the API path, title, version and servers (local URL only) in `config/scramble.php`. Restrict the `/docs/api` UI to the local environment. Export with `php artisan scramble:export --path=docs/openapi.json` behind a `composer docs` script.
- **Code style:** Laravel Pint with a minimal `pint.json`: preset `laravel` plus only the rules that matter (`declare_strict_types`, `final_class`, `ordered_imports`). Run `vendor/bin/pint --test` in CI.
- **Static analysis:** PHPStan with Larastan (`larastan/larastan`) at `level: max`, analysing `app`, `src`, `config`, `database`, `routes` and `tests`. Do not create a baseline for a fresh project; fix the issues instead.
- **Rector (optional, ask):** `rector/rector` with `driftingly/rector-laravel`. Configure prepared sets for the pinned PHP version, code quality, dead code, type declarations, and the Laravel version. Run `vendor/bin/rector --dry-run` in CI.
- **Autoload:** add a PSR-4 entry for `src/` in `composer.json`, e.g. `"Src\\": "src/"`, or one namespace per context if preferred, then run `composer dump-autoload`.
- **Wiring:** bind domain repository interfaces and ports to Eloquent implementations or fake adapters in a per-context service provider under `src/<Context>/Infrastructure/`. Eloquent models live in Infrastructure; domain entities are plain PHP objects.
- **Composer scripts:** `test`, `lint` (pint --test), `format` (pint), `analyse` (phpstan), `refactor` (rector, if used), `docs` (scramble export), and `check` (runs everything). Makefile targets wrap these with `docker compose exec app`.

### Other stacks (adapt the same principles)

- **TypeScript / Node:** strict `tsconfig`, ESLint plus Prettier (or Biome), Vitest for unit tests, dependency-cruiser for layer rules. Use Drizzle or Kysely (with `pg` or `better-sqlite3`) behind repository interfaces, with forward-only migrations. OpenAPI: `@nestjs/swagger` with its CLI plugin for NestJS, `@fastify/swagger` with route schemas for Fastify, or zod-to-openapi for Express. Keep domain and application outside Nest modules.
- **Python:** uv, Ruff (lint and format), mypy `--strict`, pytest, import-linter for layer rules. Use SQLAlchemy 2 with Alembic, with `downgrade()` removed from the migration template. OpenAPI: FastAPI's built-in generator, or drf-spectacular for Django REST Framework. Export the spec with a script.
- **Go:** standard layout with `internal/<context>/{domain,app,infra}`, `go test`, golangci-lint v2 (`default: standard`, gofmt and goimports with `local-prefixes`). Enforce layers with `depguard` rules in `list-mode: strict`: `domain` files allow only `$gostd` and their own package, `app` files `$gostd`, `domain` and their own package (own package for external `_test` packages). Use pgx with sqlc for PostgreSQL, or modernc.org/sqlite for SQLite, with goose or golang-migrate using up-only migrations. OpenAPI: Huma, which generates the spec from typed handlers, or swaggo/swag if annotations are acceptable.
- **Symfony:** PHPUnit or Pest, PHP-CS-Fixer or Pint, PHPStan max, Rector, deptrac, Doctrine ORM with forward-only migrations (mapping in Infrastructure, e.g. XML or PHP mapping rather than attributes on domain classes). OpenAPI: NelmioApiDocBundle, exported with `bin/console nelmio:apidoc:dump`.

## Finish

When the bootstrap is done, show the user:
- `git log --oneline` of the bootstrap commits
- a Mermaid diagram (or inline visual) of the bounded contexts and layers, instead of a long description
- the commands to start the environment, run tests and checks, and regenerate the API docs
- the GitHub repo URL, if one was created

Then suggest the next step: model the first real use case in the chosen bounded context.