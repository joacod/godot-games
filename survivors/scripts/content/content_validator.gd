extends RefCounted

# Return actionable diagnostics instead of allowing partially configured runs.
static func validate(content: SurvivorRunData, theme: SurvivorThemeData) -> PackedStringArray:
    var errors := PackedStringArray()
    if content == null:
        errors.append("run: required content Resource is missing")
        return errors
    if content.character == null:
        errors.append("character: required Resource is missing")
    else:
        _identity(content.character, "character", errors)
        _positive(content.character.max_health, "character.max_health", errors)
        _positive(content.character.speed, "character.speed", errors)
        _scene(content.character.visual_scene, "character.visual_scene", errors)
    _positive(content.duration, "run.duration", errors)
    _positive(content.ordinary_cap, "run.ordinary_cap", errors)
    _positive(content.first_level_xp, "run.first_level_xp", errors)
    _positive(content.level_xp_increment, "run.level_xp_increment", errors)
    _positive(content.damage_cooldown, "run.damage_cooldown", errors)
    _positive(content.pickup_radius, "run.pickup_radius", errors)
    if content.arena_size != Vector2(960, 640):
        errors.append("run.arena_size: foundation arena requires 960 x 640; update geometry with dimensions")
    if not is_finite(content.elite_spawn_seconds) or content.elite_spawn_seconds <= 0 or content.elite_spawn_seconds >= content.duration:
        errors.append("run.elite_spawn_seconds: must be between zero and duration")
    var weapon_ids: Array[StringName] = []
    var behaviors: Array[int] = []
    if content.weapons.size() != 4:
        errors.append("weapons: exactly four base weapon definitions are required")
    for weapon in content.weapons:
        if weapon == null:
            errors.append("weapons: missing Resource")
            continue
        _identity(weapon, "weapon", errors)
        _unique(weapon.id, weapon_ids, "weapon", errors)
        if weapon.behavior < 0 or weapon.behavior > 3 or weapon.behavior in behaviors:
            errors.append("weapon %s.behavior: require one of each of the four behavior kinds" % weapon.id)
        behaviors.append(weapon.behavior)
        if weapon.rank_damage.size() != 3:
            errors.append("weapon %s.rank_damage: require exactly three ranks" % weapon.id)
        for damage in weapon.rank_damage:
            _positive(damage, "weapon %s.rank_damage" % weapon.id, errors)
        _positive(weapon.cadence, "weapon %s.cadence" % weapon.id, errors)
        _positive(weapon.lifetime, "weapon %s.lifetime" % weapon.id, errors)
        _nonnegative(weapon.radius, "weapon %s.radius" % weapon.id, errors)
        _nonnegative(weapon.projectile_speed, "weapon %s.projectile_speed" % weapon.id, errors)
        if weapon.behavior in [1, 2]:
            _positive(weapon.radius, "weapon %s.radius" % weapon.id, errors)
        if weapon.behavior in [0, 3]:
            _positive(weapon.projectile_speed, "weapon %s.projectile_speed" % weapon.id, errors)
        _scene(weapon.attack_scene, "weapon %s.attack_scene" % weapon.id, errors)
    if content.starting_weapon_id not in weapon_ids:
        errors.append("run.starting_weapon_id: must reference a defined base weapon")
    var enemy_ids: Array[StringName] = []
    if content.enemies.size() != 2 or content.enemies[0] == null or content.enemies[1] == null:
        errors.append("enemies: require ordinary crawler then elite variant")
    elif content.enemies[0].elite or not content.enemies[1].elite:
        errors.append("enemies: ordinary must precede elite variant")
    for enemy in content.enemies:
        if enemy == null:
            continue
        _identity(enemy, "enemy", errors)
        _unique(enemy.id, enemy_ids, "enemy", errors)
        for field in ["max_health", "speed", "contact_damage", "xp_reward"]:
            _positive(enemy.get(field), "enemy %s.%s" % [enemy.id, field], errors)
        _scene(enemy.visual_scene, "enemy %s.visual_scene" % enemy.id, errors)
    var upgrade_ids: Array[StringName] = []
    var passive_ids: Array[StringName] = []
    var upgraded_weapons: Array[StringName] = []
    var kinds: Array[int] = []
    var evolution_count := 0
    for upgrade in content.upgrades:
        if upgrade == null:
            errors.append("upgrades: missing Resource")
            continue
        _identity(upgrade, "upgrade", errors)
        _unique(upgrade.id, upgrade_ids, "upgrade", errors)
        if upgrade.description.strip_edges().is_empty():
            errors.append("upgrade %s.description: required text is empty" % upgrade.id)
        _scene(upgrade.icon_scene, "upgrade %s.icon_scene" % upgrade.id, errors)
        if upgrade.kind < 0 or upgrade.kind > 5:
            errors.append("upgrade %s.kind: unknown kind" % upgrade.id)
        kinds.append(upgrade.kind)
        if upgrade.kind == SurvivorUpgradeData.Kind.WEAPON:
            if upgrade.target_id not in weapon_ids or upgrade.target_id in upgraded_weapons or upgrade.max_rank != 3:
                errors.append("upgrade %s: must target a distinct base weapon with three ranks" % upgrade.id)
            upgraded_weapons.append(upgrade.target_id)
        elif upgrade.kind == SurvivorUpgradeData.Kind.PASSIVE:
            passive_ids.append(upgrade.id)
            if upgrade.max_rank != 1 or upgrade.target_id != upgrade.id:
                errors.append("upgrade %s: passive requires one rank and matching target ID" % upgrade.id)
            _positive(upgrade.modifier, "upgrade %s.modifier" % upgrade.id, errors)
        elif upgrade.kind in [2, 3, 4]:
            if upgrade.max_rank != 0:
                errors.append("upgrade %s.max_rank: repeatable choices must be uncapped (0)" % upgrade.id)
            _positive(upgrade.modifier, "upgrade %s.modifier" % upgrade.id, errors)
        elif upgrade.kind == SurvivorUpgradeData.Kind.EVOLUTION:
            evolution_count += 1
    if upgraded_weapons.size() != 4 or passive_ids.size() != 1 or evolution_count != 1:
        errors.append("upgrades: require four weapon choices, one passive, and one evolution")
    for kind in [2, 3, 4]:
        if kinds.count(kind) != 1:
            errors.append("upgrades: require one each of Recovery, Power and Reach")
    for upgrade in content.upgrades:
        if upgrade == null or upgrade.kind != SurvivorUpgradeData.Kind.EVOLUTION:
            continue
        if upgrade.required_weapon_id not in weapon_ids or upgrade.required_passive_id not in passive_ids or upgrade.required_weapon_rank != 3 or upgrade.target_id != upgrade.required_weapon_id or upgrade.replacement_id.is_empty() or upgrade.replacement_id in weapon_ids or upgrade.chain_limit != 3:
            errors.append("upgrade %s: invalid rank-3 weapon/passive replacement recipe or chain limit" % upgrade.id)
    if content.spawn_phases.size() != 3:
        errors.append("run.spawn_phases: require three ordered phases")
    var previous := -1.0
    for i in content.spawn_phases.size():
        var phase := content.spawn_phases[i]
        if phase == null:
            errors.append("run.spawn_phases[%d]: missing Resource" % i)
            continue
        if not is_finite(phase.start_seconds) or phase.start_seconds <= previous or phase.start_seconds >= content.duration or (i == 0 and phase.start_seconds != 0):
            errors.append("run.spawn_phases[%d].start_seconds: must start at zero then increase below duration" % i)
        previous = phase.start_seconds
        _positive(phase.interval, "run.spawn_phases[%d].interval" % i, errors)
    if theme == null:
        errors.append("theme: required Resource is missing")
    else:
        for field in ["title", "start_label", "return_label", "victory_label", "defeat_label", "pause_label", "resume_label", "retry_label", "foundation_label", "foundation_note"]:
            if str(theme.get(field)).strip_edges().is_empty():
                errors.append("theme.%s: required text is empty" % field)
        if theme.ui_theme == null:
            errors.append("theme.ui_theme: required Theme is missing")
        _scene(theme.arena_visual_scene, "theme.arena_visual_scene", errors)
    return errors

static func _identity(value: Resource, label: String, errors: PackedStringArray) -> void:
    if str(value.get("id")).strip_edges().is_empty():
        errors.append("%s.id: required stable ID is empty" % label)
    if str(value.get("display_name")).strip_edges().is_empty():
        errors.append("%s.display_name: required text is empty" % label)

static func _unique(id: StringName, ids: Array[StringName], label: String, errors: PackedStringArray) -> void:
    if id in ids:
        errors.append("%s.id: duplicate ID '%s'" % [label, id])
    ids.append(id)

static func _positive(value: float, label: String, errors: PackedStringArray) -> void:
    if not is_finite(value) or value <= 0:
        errors.append("%s: must be finite and greater than zero" % label)

static func _nonnegative(value: float, label: String, errors: PackedStringArray) -> void:
    if not is_finite(value) or value < 0:
        errors.append("%s: must be finite and nonnegative" % label)

static func _scene(path: String, label: String, errors: PackedStringArray) -> void:
    if not path.begins_with("res://") or ".." in path or not path.ends_with(".tscn") or not ResourceLoader.exists(path, "PackedScene"):
        errors.append("%s: missing project-local visual scene '%s'" % [label, path])
        return
    var packed := load(path) as PackedScene
    if packed == null:
        errors.append("%s: cannot load PackedScene '%s'" % [label, path])
        return
    var state := packed.get_state()
    if state.get_node_count() == 0 or state.get_node_type(0) != &"Node2D":
        errors.append("%s: visual root must be Node2D" % label)
    for i in state.get_node_count():
        if state.get_node_type(i) in [&"StaticBody2D", &"CharacterBody2D", &"RigidBody2D", &"Area2D", &"CollisionShape2D", &"CollisionPolygon2D"]:
            errors.append("%s: visual scenes must not own physics nodes" % label)
