# Symfony (PHP)

## Versions (Step 4)

The same places as for any PHP project: `composer.json` `require.php` and `config.platform.php`, `ARG PHP_VERSION` in the Dockerfile, `php-version` in `shivammathur/setup-php` in every CI job, and the PHP version in Rector and PHPStan configs.

## Docker (Step 5)

Official `php:<version>-fpm` image plus `nginx`, or FrankenPHP as a single container. Never the Symfony CLI's local server.

## Layers (Step 6)

Enforce boundaries with deptrac. Doctrine mapping lives in Infrastructure as XML or PHP mapping, never as attributes on domain classes.

## Database (Step 7)

Doctrine ORM with Doctrine Migrations, forward-only: remove `down()` from the migration template.

## OpenAPI (Step 8)

NelmioApiDocBundle, exported with `bin/console nelmio:apidoc:dump`.

## Tools

PHPUnit or Pest, PHP-CS-Fixer or Pint, PHPStan at max level, Rector.
