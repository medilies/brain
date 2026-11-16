# Python

## Versions (Step 4)

`.python-version` is the source of truth. `requires-python`, Ruff's `target-version`, mypy's `python_version`, the Dockerfile, and `python-version-file` in `actions/setup-python` follow it.

## Docker (Step 5)

The official `python` image running a real app server (e.g. uvicorn or gunicorn). Never `manage.py runserver` or `fastapi dev`.

## Layers (Step 6)

Enforce boundaries with import-linter.

## Database (Step 7)

SQLAlchemy 2 with Alembic, with `downgrade()` removed from the migration template.

## OpenAPI (Step 8)

FastAPI's built-in generator, or drf-spectacular for Django REST Framework. Export the spec with a script.

## Tools

uv, Ruff (lint and format), mypy `--strict`, pytest.
