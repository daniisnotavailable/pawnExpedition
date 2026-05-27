extends CharacterBody2D

@export var speed: float = 50.0
@export var detection_range: float = 130.0
@export var max_health: int = 100
@export var contact_damage: int = 10
@export var contact_cooldown: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _player: Node2D = null
var _current_health: int
var _can_damage: bool = true
var _dead: bool = false

func _ready() -> void:
	_current_health = max_health
	_player = get_tree().get_first_node_in_group("player")
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if _dead or _player == null:
		return

	var anim_busy := (sprite.animation == "attack" or sprite.animation == "hit") and sprite.is_playing()

	if anim_busy:
		velocity = Vector2.ZERO
	else:
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

	if _can_damage and not anim_busy:
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()
			if collider != null and collider.is_in_group("player") and collider.has_method("take_damage"):
				collider.take_damage(contact_damage)
				sprite.play("attack")
				_start_contact_cooldown()
				break

func _start_contact_cooldown() -> void:
	_can_damage = false
	await get_tree().create_timer(contact_cooldown).timeout
	_can_damage = true

func take_damage(amount: int) -> void:
	if _dead:
		return
	_current_health = max(_current_health - amount, 0)
	if _current_health == 0:
		_die()
	else:
		sprite.play("hit")

func _die() -> void:
	_dead = true
	velocity = Vector2.ZERO
	sprite.play("death")

func _on_animation_finished() -> void:
	if sprite.animation == "death":
		queue_free()
