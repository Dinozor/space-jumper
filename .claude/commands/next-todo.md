Pick the first unchecked `- [ ]` item from the TODO section in CLAUDE.md and implement it.

Steps:
1. Read CLAUDE.md and find the first `- [ ]` item that is not yet done.
2. State clearly which task you are about to implement and ask the user to confirm before starting.
3. Implement the task, following all rules in CLAUDE.md: feature-folder layout, architecture rules, GDScript code style, naming conventions, 40-line function limit, static typing everywhere.
4. Run validation synchronously (never use run_in_background):
   - `~/.local/share/nvim/mason/bin/gdformat .`
   - `godot --headless --check-only`
   Fix any errors before proceeding.
5. Mark the completed item as `- [x]` in CLAUDE.md.
6. Commit everything with a Conventional Commit message (feat/fix/refactor/style/docs/chore as appropriate, with scope if helpful).
7. Report what was done and what the next unchecked TODO is.
