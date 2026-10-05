extends ColorRect

signal chosen(upgrade: SurvivorUpgradeData)

var choices: Array[SurvivorUpgradeData] = []
var selected := -1
var locked := true

func _ready() -> void:
    for index in 3:
        _button(index).pressed.connect(select.bind(index))

func _button(index: int) -> Button:
    return $Center/Panel/Margin/Column.get_node("Choice%d" % index)

func present(options: Array[SurvivorUpgradeData], level: int) -> void:
    choices = options
    selected = -1
    locked = false
    $Center/Panel/Margin/Column/Title.text = "Level %d — choose an upgrade" % level
    for index in 3:
        var button := _button(index)
        button.text = options[index].display_name + "\n" + options[index].description
        button.disabled = false
    show()
    _button(0).grab_focus()

func select(index: int) -> void:
    if locked or not visible or index < 0 or index >= choices.size():
        return
    locked = true
    selected = index
    for item in 3:
        _button(item).disabled = true
    get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
    if not visible:
        return
    if event.is_action("confirm") or event.is_action("ui_accept"):
        if event.is_pressed() and not event.is_echo():
            for index in 3:
                if _button(index).has_focus():
                    select(index)
                    break
        get_viewport().set_input_as_handled()
    elif event.is_action("cancel"):
        get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
    # Keep the run paused until the confirming key/click is released. One held
    # event cannot choose twice or leak into the newly resumed run.
    if selected < 0 or Input.is_action_pressed("confirm") or Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        return
    var upgrade := choices[selected]
    selected = -1
    chosen.emit(upgrade)
