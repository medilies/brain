# Go

## Versions (Step 4)

`go.mod` is the source of truth. Its `go` directive (e.g. `1.26.0`, which the `go` command insists on) sets the language version, and its `toolchain` directive the exact Go that CI and releases build with. `actions/setup-go` reads it with `go-version-file: go.mod`, and so does the Dockerfile if there is one. Bump `toolchain` when a patch release ships.

## Layers (Step 6)

- Layout: `internal/<context>/{domain,app,infra}`.
- Enforce boundaries with golangci-lint's `depguard` in `list-mode: strict`: `domain` files allow only `$gostd` and their own package; `app` files allow `$gostd`, `domain` and their own package (own package for external `_test` packages).

## Database (Step 7)

pgx with sqlc for PostgreSQL, or modernc.org/sqlite for SQLite, with goose or golang-migrate using up-only migrations.

## OpenAPI (Step 8)

Huma, which generates the spec from typed handlers, or swaggo/swag if annotations are acceptable.

## Tools

`go test`, golangci-lint v2 (`default: standard`, gofmt and goimports with `local-prefixes`).

## CLIs and TUIs

- **Layout:** `cmd/<binary>` is a thin Cobra layer that parses flags and wires adapters to use cases. Bubble Tea screens are adapters in `infra`, behind ports in `app` (e.g. `ProjectForm`, `Confirmation`).
- **Tests:** unit-test Bubble Tea models by sending them messages and reading their view. Test the rest in a real terminal, as `write-tests` says.
- **Release,** once the project leaves the early phase: GoReleaser on a `vX.Y.Z` tag, after the tests pass.
