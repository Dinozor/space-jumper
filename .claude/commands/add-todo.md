Add one or more new unchecked items to TODO.md.

The user's message (after the slash command) is the item text. Multiple items may be listed.

Steps:
1. Read TODO.md to understand the existing sections.
2. For each item, pick the most appropriate existing section based on the item's nature:
   - Crash / wrong behaviour → **Bugs**
   - Visual, HUD, menus → **UI / HUD**
   - Jump, bounce, movement feel → **Gameplay mechanics**
   - Health / boost drops → **Pickups**
   - Level .tres files, LevelData fields, scripted sections → **Level design**
   - Code cleanup, refactor, no behaviour change → **Tech / refactor**
   - Spawn tables, object resources, tuning data → **Content / data**
   - GitHub Actions, butler, itch.io → **CI/CD**
   - Settings screen, control remapping → **Settings / Options**
   - Intro boost, countdown → **Intro sequence**
   - Cable ending, win cinematic → **Ending sequence**
   - Physics reframe items (station_escape_speed, drag, distance thresholds) → **Physics reframe — "station flies away"**
   - Anything else: create a new section at the end with a descriptive heading.
3. Append `- [ ] <item text>` at the end of the chosen section, before the next blank line / heading.
4. If the user provided multiple items, place each in its correct section (they need not all be the same section).
5. Commit with:
   ```
   docs: add TODO item(s) — <one-line summary of what was added>
   ```
6. Report which section each item was added to and what the current first unchecked TODO is.
