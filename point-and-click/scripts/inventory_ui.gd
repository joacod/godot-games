extends HBoxContainer

var inventory: Node
var interaction: Node
var slots: Array[Button] = []


func configure(item_store: Node, controller: Node) -> void:
	inventory = item_store
	interaction = controller
	for index in range(inventory.CAPACITY):
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(96, 32)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.add_theme_font_size_override("font_size", 12)
		slot.toggle_mode = true
		slot.pressed.connect(_select.bind(index))
		add_child(slot)
		slots.append(slot)
	inventory.changed.connect(refresh)
	interaction.selection_changed.connect(func(_item: String): refresh())
	refresh()


func _select(index: int) -> void:
	if index < inventory.items.size():
		interaction.select_item(inventory.items[index])


func refresh() -> void:
	for index in range(slots.size()):
		var occupied: bool = index < inventory.items.size()
		var slot := slots[index]
		slot.disabled = not occupied
		slot.text = inventory.definitions[inventory.items[index]].name if occupied else "—"
		slot.tooltip_text = inventory.definitions[inventory.items[index]].description if occupied else ""
		slot.set_pressed_no_signal(occupied and inventory.items[index] == interaction.selected_item)
