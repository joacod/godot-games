"""Create and audit the Step 06 standalone cosmetic reskin (standard library only)."""

import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile


source = Path(__file__).resolve().parents[1]
copy = Path(tempfile.mkdtemp(prefix="closed-gate-step06-", dir="/private/tmp")) / "harbor-gate"
shutil.copytree(source, copy, ignore=shutil.ignore_patterns(".godot", "__pycache__", "*.log"))
assert not (copy / ".godot").exists()
assert not any(path.is_symlink() for path in copy.rglob("*"))


def save_json(path, content):
    path.write_text(json.dumps(content, indent=2) + "\n")


def cosmetic_contract(value):
    if isinstance(value, dict):
        return {key: cosmetic_contract(item) for key, item in value.items()
                if key not in {"name", "description", "text", "failure_text", "failure_responses"}}
    if isinstance(value, list):
        return [cosmetic_contract(item) for item in value]
    return value


room = json.loads((copy / "data/room.json").read_text())
for hotspot in room["hotspots"]:
    hotspot["name"] = {"oil": "Amber oil", "clerk": "Keeper Mara"}.get(hotspot["id"], hotspot["name"])
save_json(copy / "data/room.json", room)
items = json.loads((copy / "data/items.json").read_text())
for item in items["items"]:
    item["name"] = {"oil": "Amber oil", "pass": "Harbor pass"}[item["id"]]
    item["description"] = {"oil": "Amber oil for the keeper's jammed stamp press.",
                           "pass": "Mara's stamped permission to leave the harbor."}[item["id"]]
save_json(copy / "data/items.json", items)
dialogue = json.loads((copy / "data/dialogue.json").read_text())
dialogue["speakers"][0]["name"] = "Keeper Mara"
lines = {
    "jammed": ("Welcome to the harbor. My stamp press is jammed; amber oil should free it.",
               ["I will find the amber oil."]),
    "repaired": ("The press runs smoothly again. Shall I stamp your harbor pass?",
                 ["A harbor pass, please.", "I will come back."]),
    "issued": ("Take your harbor pass to the exit gate. Safe travels!", ["Thanks, Mara."]),
}
for node in dialogue["nodes"]:
    node["text"], choices = lines[node["id"]]
    for choice, text in zip(node["choices"], choices, strict=True):
        choice["text"] = text
save_json(copy / "data/dialogue.json", dialogue)
puzzle = json.loads((copy / "data/puzzle.json").read_text())


def reskin_text(value):
    if isinstance(value, dict):
        for key, item in value.items():
            if key in {"text", "failure_text"} and isinstance(item, str):
                value[key] = item.replace("oil", "amber oil").replace("Oil", "Amber oil").replace("clerk", "keeper").replace("stamped pass", "harbor pass")
            else:
                reskin_text(item)
    elif isinstance(value, list):
        for item in value:
            reskin_text(item)


reskin_text(puzzle)
save_json(copy / "data/puzzle.json", puzzle)
background = copy / "scenes/visuals/background.tscn"
background.write_text(background.read_text().replace("Color(0.19, 0.23, 0.28, 1)", "Color(0.10, 0.25, 0.28, 1)")
                      .replace("Color(0.27, 0.29, 0.31, 1)", "Color(0.21, 0.31, 0.29, 1)")
                      .replace("Color(0.34, 0.38, 0.41, 1)", "Color(0.36, 0.49, 0.45, 1)")
                      .replace("Color(0.25, 0.29, 0.34, 1)", "Color(0.16, 0.34, 0.35, 1)"))
# Background palette is the changed room art; prop attachment nodes remain intact.
theme = copy / "data/theme.tres"
theme.write_text(theme.read_text().replace("THE CLOSED GATE", "THE HARBOR GATE")
                 .replace("The Closed Gate", "The Harbor Gate")
                 .replace("Gatehouse • a quiet afternoon", "Harbor office • the evening ferry")
                 .replace("talk to the clerk", "talk to Keeper Mara")
                 .replace("collected a stamped pass", "collected a harbor pass"))
project = copy / "project.godot"
project.write_text(project.read_text().replace('config/name="The Closed Gate"', 'config/name="The Harbor Gate"'))

for name in ["room", "items", "dialogue", "puzzle"]:
    original = json.loads((source / f"data/{name}.json").read_text())
    changed = json.loads((copy / f"data/{name}.json").read_text())
    assert cosmetic_contract(original) == cosmetic_contract(changed), name

hashes = {}
for path in sorted((source / "scripts").rglob("*")):
    if path.is_file():
        relative = path.relative_to(source)
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        assert digest == hashlib.sha256((copy / relative).read_bytes()).hexdigest(), relative
        hashes[str(relative)] = digest
scene_hashes = {}
for path in sorted((source / "scenes").rglob("*.tscn")):
    relative = path.relative_to(source)
    if relative == Path("scenes/visuals/background.tscn"):
        continue
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    assert digest == hashlib.sha256((copy / relative).read_bytes()).hexdigest(), relative
    scene_hashes[str(relative)] = digest
for path in copy.rglob("*.gd"):
    assert path.with_suffix(".gd.uid").is_file(), path
for path in copy.rglob("*"):
    if path.suffix in {".tscn", ".tres", ".json", ".gd", ".godot"} and ".godot" not in path.parts:
        for reference in re.findall(r'res://[^"\s]+', path.read_text()):
            if "missing-fixture" in reference:
                continue
            assert ".." not in Path(reference[6:]).parts, reference
            # The test runner deliberately references missing resources in negative fixtures.
            if "tests" not in path.relative_to(copy).parts:
                assert (copy / reference[6:]).exists(), (path, reference)

report = {
    "source": str(source), "copy": str(copy), "cache_omitted_before_import": True,
    "no_symlinks": True, "content_ids_geometry_conditions_effects_unchanged": True,
    "runtime_references_project_local": True, "all_gd_uids_present": True,
    "identical_runtime_script_and_uid_sha256": hashes,
    "identical_scene_sha256_except_background": scene_hashes,
    "changed_presentation": ["project.godot", "data/room.json", "data/items.json",
                             "data/dialogue.json", "data/puzzle.json", "data/theme.tres",
                             "scenes/visuals/background.tscn"],
}
(copy.parent / "reskin-audit.json").write_text(json.dumps(report, indent=2) + "\n")
print(copy)
print(f"Audit: {copy.parent / 'reskin-audit.json'}")
print(f"Unchanged runtime script/UID hashes: {len(hashes)}")
