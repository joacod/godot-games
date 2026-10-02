# Agent guidance

This repository contains small Godot games for learning and experimentation.
Prioritize complete, understandable gameplay over frameworks or speculative reuse.

- Read the relevant project, scenes, scripts, and plan before editing. For
  `2d-platform`, use [the completion plan](2d-platform/PLAN.md).
- If requirements are unclear, ask before coding. Explain the approach and wait
  for confirmation before non-trivial features, architecture changes, or broad rewrites.
- When asked for a numbered step, complete only that step and report its validation.
- Make the smallest correct change. Preserve existing conventions and unrelated
  worktree changes. Avoid new dependencies and unrelated refactors.
- Keep each game's configured Godot version and renderer unless a requested fix
  requires a change. Use GDScript for `2d-platform`.
- For `2d-platform`, use Godot 4.7 (development checks use 4.7.2) and the Mobile
  renderer. See [the project README](2d-platform/README.md) for setup and validation
  commands and [project.godot](2d-platform/project.godot) for engine settings.
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
