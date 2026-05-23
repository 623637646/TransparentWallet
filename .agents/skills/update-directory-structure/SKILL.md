---
name: update-directory-structure
description: Use this skill immediately before completing any task that involves creating, modifying, or deleting files or directories to incrementally update the Directory Structure in AGENTS.md. Alternatively, use this skill when the user explicitly requests to update the directory structure, in which case you should perform a full scan and full update.
---

# Update Directory Structure

This skill ensures that the `AGENTS.md` file's Directory Structure section accurately reflects the current state of the codebase. The behavior changes depending on how the skill is triggered:

## Scenario 1: Automatic Trigger (End of AI Task)

When you are wrapping up a task that involved creating, modifying, or deleting files:

1. **Incremental Update**: Identify ONLY the files and directories you have changed during your current task. Do NOT perform a full project scan.
2. **Review Requirements**: Read the "Directory Structure" section (specifically the Requirements) in `AGENTS.md` to understand what paths need to be documented and how they should be formatted.
3. **Update Contents**: Modify the "Directory Structure" contents in `AGENTS.md` to reflect the incremental changes you made. 
   - Add new files/directories with a brief explanation of their purpose.
   - Update descriptions of modified files if their purpose changed.
   - Remove entries for deleted files.
   - Preserve the existing tree formatting (`├──`, `│`, `└──`, etc.).
   - Ensure the explanations are concise and follow the style of the existing entries.

## Scenario 2: Manual Trigger (User Request)

When the user explicitly asks you to update the directory structure or run this skill:

1. **Full Scan**: Perform a comprehensive scan of the project's directory structure, focusing on the paths specified in the `AGENTS.md` Requirements.
2. **Full Update**: Completely review and update the "Directory Structure" contents in `AGENTS.md` to match the full structure found on disk. Ensure all files and directories are accounted for, missing files are documented, and obsolete entries are removed.
3. **Format**: Maintain the existing tree formatting and concise description style.

**Finally**, save your changes to `AGENTS.md`.
