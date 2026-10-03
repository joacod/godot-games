# OpenSpec game research handoff

Research dated 2026-10-03. The three changes below are proposals with complete
designs and future implementation steps. No gameplay has been implemented by
this handoff. All implementation tasks remain unchecked.

| Game | Design | Steps | Requirements |
| --- | --- | --- | --- |
| Survivors | [Design](../survivors/docs/DESIGN.md) | [Six steps](../survivors/docs/STEPS.md) | [Spec](changes/add-survivors/specs/survivors-slice/spec.md) |
| Point-and-click | [Design](../point-and-click/docs/DESIGN.md) | [Six steps](../point-and-click/docs/STEPS.md) | [Spec](changes/add-point-and-click/specs/point-and-click-slice/spec.md) |
| Shooter | [Design](../shooter/docs/DESIGN.md) | [Six steps](../shooter/docs/STEPS.md) | [Spec](changes/add-shooter/specs/shooter-slice/spec.md) |

## Workflow

OpenSpec 1.14.0 was already installed. Initialized with `--tools none` so this
handoff adds planning files without installing integrations or changing agent
instructions. The [OpenSpec workflow](https://openspec.dev/) separates proposal,
specifications, design, tasks, implementation and archive. Its
[CLI reference](https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/cli.md)
documents validation and status commands.

From the repository root:

```sh
OPENSPEC_TELEMETRY=0 openspec list
OPENSPEC_TELEMETRY=0 openspec status --change add-survivors
OPENSPEC_TELEMETRY=0 openspec validate --all --strict --no-interactive
```

Substitute `add-point-and-click` or `add-shooter` for the other changes.
Choose a game and request one numbered step. Read its spec, canonical design
and step guide before implementing. Update that change's task checkboxes only
after the step's evidence exists. Artifact completeness means ready for
implementation, not a completed game. Archive only after gameplay acceptance;
`openspec/specs/` intentionally has no implemented capability baselines yet.

## Evidence boundary

Official Godot API documentation and CraftPix product/license pages are linked
beside the relevant findings in each design. Candidate art has not been downloaded
or inspected. No project.godot, gameplay scripts, scenes or tests exist in these
three folders yet; they are explicit future deliverables. The installed Godot
binary reported `4.7.2.stable.official.ed1daf0bf`; no game operation was needed
for this research. Existing game folders and the root README are untouched.
