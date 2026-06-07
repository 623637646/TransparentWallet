# Guidelines Spec

## Purpose
Define the requirements for project documentation, style guidelines, and automated directory structure synchronization to ensure documentation health and clarity.

## Requirements

### Requirement: Document Clarity and Correctness
The `AGENTS.md` guidelines SHALL use correct grammar, standard punctuation, and a professional tone.

#### Scenario: Verify grammar fix
- **WHEN** reading Section 2 of `AGENTS.md`
- **THEN** the text SHALL say "This section applies specifically to UI development" instead of "apply".

### Requirement: Clickable File Links
All file and directory references in `AGENTS.md` SHALL be clickable relative links.

#### Scenario: Verify file link formatting
- **WHEN** viewing the development guidelines or directory structure in `AGENTS.md`
- **THEN** all referenced files like `design_tokens.dart` and `localized_text.dart` SHALL be clickable links matching the relative path format `[filename](path/to/file)`.

### Requirement: Automated Directory Structure Updates
The guidelines SHALL instruct developers/agents to run the `update-directory-structure` skill before completing any task that adds, modifies, or deletes files/directories.

#### Scenario: Verify update skill instructions
- **WHEN** reading Section 6 of `AGENTS.md`
- **THEN** it SHALL recommend executing the `update-directory-structure` skill to ensure the Directory Structure contents remain accurate.
