# Step 02 — Movement, depth and jump

Status: not started. Prerequisite: Step 01 accepted.

## Outcome

The hero can traverse and jump within a bounded test street with correct depth
sorting and camera behavior, using keyboard or controller.

## Work

1. Implement [ground-plane rules](../DESIGN.md#ground-plane-and-jump) with a
   grounded character root, raised visual child, shadow, and separate jump height.
2. Add normalized movement, stick deadzone, horizontal facing and idle/walk/jump
   presentation. Expose only needed speed, jump and bounds tuning.
3. Add street boundaries and a horizontally following camera with level limits.
   Place an actor/prop sample to inspect overlap and Y sorting.
4. Add a minimal pause/resume path and reset action for testing. All movement and
   jump state must freeze/reset correctly; final menu styling comes later.

## Acceptance

- Walk in all directions; diagonals are not faster; no stick drift at rest.
- Jump in place and while moving; land at the ground anchor; never cross bounds
  or change sorting because the visual sprite rose.
- Pause in midair and resume; reset midair; no stuck velocity or stale input.
- Validate keyboard visually and controller on hardware, reporting gaps separately.

Exclude attacks, enemies, encounters and final art polish.
Use [shared validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; commands/results; input and visual observations; controller
device or unverified status; intentionally untouched files; follow-ups.
