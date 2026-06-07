## Context

The `AGENTS.md` file serves as the development guidelines for agents and developers working on the Janus Wallet codebase. Currently, it has minor grammatical errors, hardcoded text references to files/folders (which violate formatting rules that mandate clickable links), and lacks mention of the automated `update-directory-structure` skill.

## Goals / Non-Goals

**Goals:**
- Fix grammar and formatting issues in `AGENTS.md`.
- Replace all file and folder references with clickable relative links.
- Add guidance in Section 6 to use the `update-directory-structure` skill to automatically update the directory structure in `AGENTS.md`.

**Non-Goals:**
- Change actual project directories, file structure, or codebase functionality.
- Modify files other than `AGENTS.md` (or the change artifacts themselves).

## Decisions

### 1. Clickable Markdown Links
Convert all inline-code file references in `AGENTS.md` to clickable relative links, such as `[design_tokens.dart](lib/src/utils/design_tokens.dart)`.
- **Rationale**: Relative links keep files clickable in IDEs and on GitHub/GitLab without leaking local machine-specific absolute paths.

### 2. Skill integration
Explicitly document the `update-directory-structure` skill in the guidelines.
- **Rationale**: Automation ensures the directory structure is updated correctly and prevents developer errors.

## Risks / Trade-offs

- **Risk**: Relative links might not resolve if accessed from non-root contexts, but guidelines are at the root level.
- **Mitigation**: Using project-relative paths is standard practice for repository documentation.
