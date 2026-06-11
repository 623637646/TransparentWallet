## Context

AI agents and developers modify Dart (Flutter) and Rust code files. Unformatted code can lead to check-in of inconsistent styling and formatting, making the codebase less readable and causing diff noise. Adding a formatting instruction to `AGENTS.md` enforces a clean codebase.

## Goals / Non-Goals

**Goals:**
- Add a new "6. Code Formatting" section to `AGENTS.md`.
- Instruct AI agents and developers to format modified Dart code using `dart format` and Rust code using `cargo fmt`.

**Non-Goals:**
- Running formatting automatically via git pre-commit hooks (this is a documentation/guideline change).

## Decisions

### Decision: Section Placement
- **Choice**: Add "6. Code Formatting" as a new section in the Development Guidelines in `AGENTS.md`.
- **Alternative**: Add it under the "Build" or "Testing" sections.
- **Rationale**: A dedicated section is more prominent and easier for AI agents to parse and follow as a distinct step.

## Risks / Trade-offs

- **Risk**: Agents might ignore the guideline.
- **Mitigation**: Place it clearly in the guidelines and highlight it as a requirement.
