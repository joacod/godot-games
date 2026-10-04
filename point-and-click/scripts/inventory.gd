extends Node

signal changed

const CAPACITY := 6
var items: Array[String] = []
var definitions: Dictionary = {}


func configure(data: Dictionary) -> void:
	for item in data.items:
		definitions[item.id] = item


func can_store(candidate: Array[String]) -> bool:
	if candidate.size() > CAPACITY:
		return false
	var seen: Array[String] = []
	for item in candidate:
		if not definitions.has(item) or item in seen:
			return false
		seen.append(item)
	return true


func replace_items(candidate: Array[String]) -> bool:
	if not can_store(candidate):
		return false
	items = candidate.duplicate()
	return true


func publish_changed() -> void:
	changed.emit()
