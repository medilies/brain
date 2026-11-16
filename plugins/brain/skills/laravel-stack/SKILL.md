---
name: laravel-stack
description: Laravel (PHP) project preferences (versions, Docker, layer boundaries, database, OpenAPI, tools). Use whenever working in or bootstrapping a Laravel project.
---

# Laravel (PHP) stack

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

Headings name the `start-project` step they serve during a bootstrap. Outside a bootstrap, follow them whenever the topic comes up.

## Ask in Step 1

- Whether to include Rector.

## Versions (Step 4)

- `composer.json` `require.php` (`^8.4`) and `config.platform.php` (`8.4`)
- `ARG PHP_VERSION=8.4` in the Dockerfile
- `php-version` in `shivammathur/setup-php` in every CI job
- Rector's PHP set, and PHPStan's `phpVersion` if set

## Docker (Step 5)

- Official `php:<version>-fpm` image plus `nginx`, or FrankenPHP as a single container, with `postgres` when used. Install only the extensions needed (e.g. `pdo_pgsql` or `pdo_sqlite`, `intl`, `opcache`), plus Composer copied from the official `composer` image.
- In the Compose commit: run `composer remove --dev laravel/sail`, and remove or rewrite the scaffold's `dev` composer script, which runs `php artisan serve`. Never use Sail or `php artisan serve`.
- **Local drivers:** `MAIL_MAILER=smtp` pointing at Mailpit once mail is needed (`log` before then), `FILESYSTEM_DISK=local`, `QUEUE_CONNECTION=database` or `sync`, `CACHE_STORE=database` or `file`.

## Layers (Step 6)

- **Autoload:** add a PSR-4 entry for `src/` in `composer.json`, e.g. `"Src\\": "src/"`, or one namespace per context if preferred, then run `composer dump-autoload`.
- **Wiring:** bind domain repository interfaces and ports to Eloquent implementations or fake adapters in a per-context service provider under `src/<Context>/Infrastructure/`. Eloquent models live in Infrastructure; domain entities are plain PHP objects.
- **Enforcement:** architecture tests in `tests/Arch` using Pest's `arch()`:
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

## Database (Step 7)

Laravel's scaffold defaults to SQLite, and enables SQLite foreign keys by default.

- **Forward-only migrations:** run `php artisan stub:publish`, keep only the `migration*.stub` files (delete the other published stubs), and remove the `down()` method from them. Remove `down()` from the scaffold's default migrations in the same commit.
- **PostgreSQL:** set `DB_CONNECTION=pgsql`, `DB_HOST=postgres` and the other connection variables in `.env.example`; set the test database in `phpunit.xml` (`DB_DATABASE=<app>_test`); install `pdo_pgsql` in the Dockerfile and in CI via `shivammathur/setup-php`.
- **SQLite only:** keep the default and use `DB_DATABASE=:memory:` in `phpunit.xml`.
- **Mixed:** use SQLite `:memory:` in `phpunit.xml`, and set `DB_CONNECTION=pgsql` in a CI matrix leg.

## OpenAPI (Step 8)

Scramble (`dedoc/scramble`). It generates the spec from routes, FormRequests, API Resources and return types, with no annotations. Configure the API path, title, version and servers (local URL only) in `config/scramble.php`. Restrict the `/docs/api` UI to the local environment. Export with `php artisan scramble:export --path=docs/openapi.json` behind a `composer docs` script. Use `hotmeteor/spectator` where asserting responses against the spec adds real value.

## Tools

- **Tests:** Pest (`pestphp/pest`, `pestphp/pest-plugin-laravel`). Unit tests go in `tests/Unit/<Context>/...` and must not boot the framework. Feature tests go in `tests/Feature` and use `RefreshDatabase`.
- **Code style:** Laravel Pint with a minimal `pint.json`: preset `laravel` plus only the rules that matter (`declare_strict_types`, `final_class`, `ordered_imports`). Run `vendor/bin/pint --test` in CI.
- **Static analysis:** PHPStan with Larastan (`larastan/larastan`) at `level: max`, analysing `app`, `src`, `config`, `database`, `routes` and `tests`. Do not create a baseline for a fresh project; fix the issues instead.
- **Rector (if chosen):** `rector/rector` with `driftingly/rector-laravel`. Configure prepared sets for the pinned PHP version, code quality, dead code, type declarations, and the Laravel version. Run `vendor/bin/rector --dry-run` in CI.
- **Composer scripts:** `test`, `lint` (pint --test), `format` (pint), `analyse` (phpstan), `refactor` (rector, if used), `docs` (scramble export), and `check` (runs everything). Makefile targets wrap these with `docker compose exec app`.
