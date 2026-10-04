extends Node

signal changed
signal dialogue_requested(node_id: String)
signal finished

var completed := false

var flags: Dictionary = {}
var inventory: Node


func configure(initial_flags: Dictionary, item_store: Node) -> void:
	flags = initial_flags.duplicate(true)
	inventory = item_store


func supports(rule: Dictionary) -> bool:
	for effect in rule.effects:
		if effect.type not in ["set_flag", "grant_item", "consume_item", "show_text", "start_dialogue", "finish"]:
			return false
	return true


func conditions_met(conditions: Array) -> bool:
	for condition in conditions:
		if condition.has("flag") and flags[condition.flag] != condition.value:
			return false
		if condition.has("item") and (condition.item in inventory.items) != condition.owned:
			return false
	return true


func apply(rule: Dictionary) -> Dictionary:
	if not supports(rule) or not conditions_met(rule.requires):
		return {"ok": false, "capacity": false, "text": rule.failure_text}
	var next_flags := flags.duplicate(true)
	var next_items: Array[String] = inventory.items.duplicate()
	var lines := PackedStringArray()
	var dialogue_id := ""
	var finish_requested := false
	for effect in rule.effects:
		match effect.type:
			"set_flag":
				next_flags[effect.flag_id] = effect.value
			"grant_item":
				if effect.item_id in next_items:
					return {"ok": false, "capacity": false, "text": rule.failure_text}
				next_items.append(effect.item_id)
			"consume_item":
				if effect.item_id not in next_items:
					return {"ok": false, "capacity": false, "text": rule.failure_text}
				next_items.erase(effect.item_id)
			"show_text":
				lines.append(effect.text)
			"start_dialogue":
				dialogue_id = effect.node_id
			"finish":
				finish_requested = true
	if not inventory.can_store(next_items):
		return {"ok": false, "capacity": next_items.size() > inventory.CAPACITY, "text": rule.failure_text}
	var state_changed: bool = next_flags != flags or next_items != inventory.items
	# Publish signals only after both stores have committed the complete action.
	inventory.replace_items(next_items)
	flags = next_flags
	var emit_finish := finish_requested and not completed
	completed = completed or finish_requested
	if state_changed:
		inventory.publish_changed()
		changed.emit()
	if not dialogue_id.is_empty():
		dialogue_requested.emit(dialogue_id)
	if emit_finish:
		finished.emit()
	return {"ok": true, "capacity": false, "text": "\n".join(lines)}
