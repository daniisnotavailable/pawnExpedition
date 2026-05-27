extends CharacterBody2D

@export var speed: float = 90.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var _attacking: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if not _attacking:
		velocity = direction * speed
		move_and_slide()

	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0

	if not _attacking:
		_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not _attacking:
		_attacking = true
		velocity = Vector2.ZERO
		sprite.play("atacar")

func _update_animation(direction: Vector2) -> void:
	if direction.length() > 0.0:
		sprite.play("correr")
	else:
		sprite.play("idle")

func _on_animation_finished() -> void:
	if sprite.animation == "atacar":
		_attacking = false
