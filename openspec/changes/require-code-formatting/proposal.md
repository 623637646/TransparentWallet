## Why

To maintain code quality, readability, and consistency across the codebase. Currently, AI agents and developers may leave modified code unformatted, resulting in messy diffs, lint issues, and manual cleanups. Ensuring that all modified code is formatted after task completion helps keep the repository clean and standardized.

## What Changes

- Update `AGENTS.md` to add a new guideline instructing AI/developers to run code formatting tools (e.g., `dart format`, `cargo fmt`) on any modified files before finishing their tasks.

## Capabilities

### New Capabilities

### Modified Capabilities
- `guidelines`: Add a requirement for mandatory code formatting of all modified files after task completion.

## Impact

- Affects developer and AI agent workflow guidelines. No runtime code or API changes.
