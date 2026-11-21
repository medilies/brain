---
name: python-stack
description: Python project preferences (versions, Docker, layer boundaries, database, OpenAPI, tools). Use whenever working in or bootstrapping a Python project.
---

# Python stack

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

Headings name the `start-project` step they serve during a bootstrap. Outside a bootstrap, follow them whenever the topic comes up.

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
