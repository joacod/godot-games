# Agent guidance

This repository contains small Godot games for learning and experimentation.
Prioritize complete, understandable gameplay over frameworks or speculative reuse.

- Read the relevant project, scenes, and scripts before editing. For
  `2d-platform`, use [the game README](2d-platform/README.md) and
  [the art reference](2d-platform/ASSETS.md).
- If requirements are unclear, ask before coding. Explain the approach and wait
  for confirmation before non-trivial features, architecture changes, or broad rewrites.
- When asked for a numbered step, complete only that step and report its validation.
- Make the smallest correct change. Preserve existing conventions and unrelated
  worktree changes. Avoid new dependencies and unrelated refactors.
- Keep each game's configured Godot version and renderer unless a requested fix
  requires a change. Use GDScript for `2d-platform`.
- Use Godot 4.7 for all current and future projects in this repository;
  development checks use 4.7.2. Confirm that skills and MCP tools use this engine
  version before running project operations. Read each project's README and
  `project.godot` for setup, validation commands, and renderer settings.
- Consult [godot-gdscript-patterns](.agents/skills/godot-gdscript-patterns/SKILL.md)
  on demand for relevant GDScript, scene architecture, game state, or performance
  work. Repository and project constraints take precedence over its generic
  Godot 4.x examples; use only patterns needed for the requested task.
- For all games, look for suitable assets on [CraftPix](https://craftpix.net/)
  before creating replacements. Prefer free assets or assets already available
  through the user's account. Agents may browse and download using the user's
  logged-in session through computer use or equivalent browser tools. If that
  capability is unavailable, describe the needed asset, style, and format so the
  user can find and download it.
- Track Godot-generated `.gd.uid` files alongside their scripts. Include a new
  script's UID in the same commit once Godot generates it. Before committing,
  check for missing or untracked UIDs for scripts in scope; do not ignore these
  files or treat them as disposable cache. Preserve unrelated pre-existing
  changes, and report any UID that cannot be included in the current scope.
- Ask before deletes, overwrites, migrations, dependency removal, commits,
  branches, pushes, PRs, publishing, external API calls, or outbound messages,
  unless the user has explicitly authorized the action in the current task.
- Validate changed scenes and scripts. A headless startup cannot prove gameplay:
  report visual, input, controller, and playtest checks separately and honestly.
- Finish with files changed, behavior changed, files intentionally untouched,
  verification commands/results, and remaining follow-ups. Lead with the outcome.
