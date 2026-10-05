extends Node

var content: SurvivorRunData
var rack: Node
var health: Node
var lens_owned := false
var pickup_radius: float
var reach_bonus := 0.0
var evolved := false

func eligible(upgrade: SurvivorUpgradeData) -> bool:
    match upgrade.kind:
        SurvivorUpgradeData.Kind.WEAPON:
            return not (evolved and upgrade.target_id == recipe().required_weapon_id) and rank(upgrade.target_id) < upgrade.max_rank
        SurvivorUpgradeData.Kind.PASSIVE:
            return not lens_owned
        SurvivorUpgradeData.Kind.RECOVERY, SurvivorUpgradeData.Kind.POWER, SurvivorUpgradeData.Kind.REACH:
            return true
    return false

func rank(id: StringName) -> int:
    for index in rack.equipped.size():
        if rack.equipped[index].id == id:
            return rack.ranks[index]
    return 0

func recipe() -> SurvivorUpgradeData:
    for upgrade in content.upgrades:
        if upgrade.kind == SurvivorUpgradeData.Kind.EVOLUTION:
            return upgrade
    return null

func offers(level: int) -> Array[SurvivorUpgradeData]:
    var result: Array[SurvivorUpgradeData] = []
    # Fixed priorities make progress possible without lucky random rolls.
    for upgrade in content.upgrades:
        if upgrade.kind == SurvivorUpgradeData.Kind.WEAPON and rank(upgrade.target_id) == 0:
            result.append(upgrade)
            break
    if level >= 3 and not lens_owned:
        for upgrade in content.upgrades:
            if upgrade.kind == SurvivorUpgradeData.Kind.PASSIVE:
                result.append(upgrade)
    for upgrade in content.upgrades:
        if upgrade.kind == SurvivorUpgradeData.Kind.WEAPON and upgrade.target_id == recipe().required_weapon_id and eligible(upgrade):
            result.append(upgrade)
    for upgrade in content.upgrades:
        if result.size() == 3:
            break
        if eligible(upgrade) and upgrade not in result:
            result.append(upgrade)
    return result

func apply(upgrade: SurvivorUpgradeData) -> bool:
    if not eligible(upgrade):
        return false
    match upgrade.kind:
        SurvivorUpgradeData.Kind.WEAPON:
            var found := false
            for index in rack.equipped.size():
                if rack.equipped[index].id == upgrade.target_id:
                    rack.ranks[index] += 1
                    found = true
            if not found:
                for weapon in content.weapons:
                    if weapon.id == upgrade.target_id:
                        rack.equip(weapon)
        SurvivorUpgradeData.Kind.PASSIVE:
            lens_owned = true
            pickup_radius = maxf(content.pickup_radius, upgrade.modifier) + reach_bonus
        SurvivorUpgradeData.Kind.RECOVERY:
            health.recover(int(upgrade.modifier))
        SurvivorUpgradeData.Kind.POWER:
            rack.power_bonus += upgrade.modifier
        SurvivorUpgradeData.Kind.REACH:
            reach_bonus += upgrade.modifier
            pickup_radius += upgrade.modifier
    var evolution := recipe()
    if not evolved and lens_owned and rank(evolution.required_weapon_id) >= evolution.required_weapon_rank:
        evolved = true
        rack.evolve(evolution)
    rack.refresh_orbits()
    return true
