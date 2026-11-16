---
name: write-tests
description: Write meaningful tests that would fail if behaviour broke - no coverage targets, never touching the user's real state, and real-terminal tests for CLIs and TUIs. Use whenever adding or changing behaviour, fixing a bug, or setting up a test suite.
---

# Write tests

## Project overrides

Before following a step, check the project's `CLAUDE.md` and `AGENTS.md`, and the files they link to, for rules on the same step. Where they conflict with this skill, follow the project. Where they add to it, do both.

## What to test

- **Meaningful tests over coverage.** Every domain behaviour and use case has unit tests that would fail if the behaviour broke. Coverage is never a target: no coverage thresholds, and no tests written only to raise the number.
- Test behaviour through public APIs, with one reason to fail per test and a name that says what should happen.
- Prefer in-memory fakes to mocks. Unit tests never touch a database or boot the framework.
- Framework-level feature tests are added on top of unit tests, never instead of them, and use a real database.
- A bug found by hand gets a test that reproduces it, and fails without the fix.

## How tests run

- **Tests never touch the user's real state:** their sessions, servers, home directory or configs. Each test builds a world of its own (temp dirs, private sockets, its own environment, e.g. a temp `HOME`) and removes it.
- Wait for a condition with a timeout, never for a fixed time.
- Never run tests in verbose mode (e.g. `go test -v`): the output floods the context. A failure prints without it; narrow it down with a filter.
- At the end of each iteration of work, run every test suite and fix what fails before going on.

## CLIs and TUIs

- **Unit-test screen models** where they hold state worth testing (a form's undo, validation as you type) by sending them messages and reading their view, without a terminal.
- **Test the rest in a real terminal emulator.** Use the `tui-test` library (load the `tui-test` skill) to run the binary in a headless emulator, through tmux if the tool lives in tmux. Each test gets its own directory under a short `/tmp` path (socket paths max out at 108 bytes), its own server and environment, and a clean `PATH` that starts with the binary under test. Keep these tests behind a build tag, and run them in CI and against released binaries.
  - Checks wait for what must show, up to a timeout. Check what must and must not show on a single capture, since a redraw can match half-drawn.
  - On failure, write a trace an agent can read (`trace.md`: expected and found) alongside a replayable recording. Upload traces as a CI artifact.
  - Keep whole-screen snapshot tests few, rewritten with `-update`, so the snapshot diff is what gets reviewed.
  - If the agent's shell runs inside the user's tmux, every tmux command names the test's socket (`tmux -S <sock>`) after `unset TMUX`, so it can't reach the user's server.
- **The README demo** is recorded by a test run with a flag (e.g. `-demo FILE`), not by hand, so it can be re-recorded when the look changes. It's the one test allowed to sleep, to pace the story.
