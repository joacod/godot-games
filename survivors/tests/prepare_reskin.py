"""Prepare a fresh independent data-only reskin and record SHA-256 evidence."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil


def hashes(root):
    return {
        str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(root.rglob("*"))
        if path.is_file() and not any(
            part in {".godot", "exports", "__pycache__"}
            for part in path.relative_to(root).parts
        ) and path.suffix != ".log"
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="new directory outside the repository")
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[1]
    destination = args.destination.resolve()
    if destination.exists() or destination.is_relative_to(source.parent):
        parser.error("destination must be new and outside the repository")
    if any(path.is_symlink() for path in source.rglob("*")):
        parser.error("source must not contain symlinks")
    before = hashes(source)
    shutil.copytree(source, destination, ignore=shutil.ignore_patterns(
        ".godot", "exports", "*.log", "__pycache__"
    ))
    changes = {
        "data/characters/keeper.tres": {
            'display_name = "Keeper"': 'display_name = "Lantern"',
            'visual_scene = "res://scenes/visuals/keeper.tscn"':
                'visual_scene = "res://scenes/visuals/crawler.tscn"',
        },
        "data/theme.tres": {
            'title = "Last Light Clearing"': 'title = "Copper Marsh"',
            'background_color = Color(0.063, 0.106, 0.137, 1)':
                'background_color = Color(0.12, 0.07, 0.16, 1)',
            'floor_color = Color(0.137, 0.235, 0.231, 1)':
                'floor_color = Color(0.24, 0.12, 0.20, 1)',
            'boundary_color = Color(0.443, 0.561, 0.463, 1)':
                'boundary_color = Color(0.8, 0.48, 0.28, 1)',
            'player_color = Color(0.976, 0.847, 0.518, 1)':
                'player_color = Color(0.4, 0.95, 0.95, 1)',
            'enemy_color = Color(0.902, 0.522, 0.443, 1)':
                'enemy_color = Color(1, 0.65, 0.35, 1)',
        },
        "data/weapons/spark.tres": {'lifetime = 3.0': 'lifetime = 3.2'},
    }
    for relative, replacements in changes.items():
        path = destination / relative
        text = path.read_text()
        for old, new in replacements.items():
            if text.count(old) != 1:
                raise ValueError(f"Expected one {old!r} in {relative}")
            text = text.replace(old, new)
        path.write_text(text)
    after = hashes(destination)
    changed = [name for name in before if before[name] != after.get(name)]
    if sorted(changed) != sorted(changes) or before.keys() != after.keys():
        raise ValueError("Copy changed files outside the three reskin Resources")
    scripts = {name: digest for name, digest in before.items() if name.startswith("scripts/")}
    if not all(after[name] == digest for name, digest in scripts.items()):
        raise ValueError("Mechanics scripts changed")
    manifest = {
        "source": str(source), "copy": str(destination), "changes": changes,
        "before": before, "after": after, "scripts_unchanged": len(scripts),
        "scene_files_unchanged": sum(name.startswith("scenes/") for name in before),
    }
    manifest_path = destination.parent / (destination.name + "-manifest.json")
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Copy: {destination}\nChanged: {changed}\nManifest: {manifest_path}")


if __name__ == "__main__":
    main()
