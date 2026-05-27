extends CharacterBody2D

@export var speed: float = 50.0
@export var detection_range: float = 130.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _player: Node2D = null

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if _player == null:
		sprite.play("idle")
		return

	var to_player := _player.global_position - global_position
	var distance := to_player.length()

	if distance <= detection_range:
		velocity = to_player.normalized() * speed
		sprite.play("move")
		if to_player.x != 0.0:
			sprite.flip_h = to_player.x < 0.0
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	move_and_slide()
