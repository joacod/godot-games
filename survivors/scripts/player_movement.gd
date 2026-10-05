extends CharacterBody2D

var speed: float
var flash_remaining := 0.0

func _ready() -> void:
    $Health.damaged.connect(_on_damaged)

func _physics_process(delta: float) -> void:
    flash_remaining = maxf(0.0, flash_remaining - delta)
    $Visual.modulate = Color(2, 2, 2, 1) if flash_remaining > 0 else Color.WHITE
    if $Health.current == 0:
        velocity = Vector2.ZERO
        return
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = direction * speed
    if not direction.is_zero_approx():
        $Visual.rotation = direction.angle() + PI / 2.0
    move_and_slide()
    # Poll persistent contact, not only entry: invulnerability is shared by all
    # enemies touching this player and contact can hurt again after its interval.
    for body in $Hurtbox.get_overlapping_bodies():
        if body is CharacterBody2D and body.has_method("get_contact_damage"):
            $Health.take_damage(body.get_contact_damage())

func _on_damaged(_amount: int, _remaining: int) -> void:
    flash_remaining = 0.16
    $Visual.modulate = Color(2, 2, 2, 1)
