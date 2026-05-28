extends CharacterBody2D

signal health_changed(current: int, max_value: int)
signal died

@export var speed: float = 90.0
@export var max_health: int = 100
@export var invulnerability_time: float = 0.5
@export var attack_damage: int = 20

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

var _current_health: int
var _attacking: bool = false
var _being_hit: bool = false
var _invulnerable: bool = false
var _dead: bool = false
var _damaged_this_swing: Array = []

func _ready() -> void:
	_current_health = max_health
	sprite.animation_finished.connect(_on_animation_finished)
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	attack_hitbox.monitoring = false
	health_changed.emit(_current_health, max_health)

func _physics_process(_delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0

	if _attacking and attack_hitbox.monitoring:
		for body in attack_hitbox.get_overlapping_bodies():
			_try_damage_body(body)

	if not _attacking and not _being_hit:
		_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
	if _dead:
		return
	if event.is_action_pressed("attack") and not _attacking:
		_start_attack()

func _start_attack() -> void:
	_attacking = true
	_being_hit = false
	sprite.play("atacar")
	_damaged_this_swing.clear()
	attack_hitbox.position.x = -10.0 if sprite.flip_h else 10.0
	attack_hitbox.monitoring = true

func _on_hitbox_body_entered(body: Node) -> void:
	_try_damage_body(body)

func _try_damage_body(body: Node) -> void:
	if body in _damaged_this_swing:
		return
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		_damaged_this_swing.append(body)

func take_damage(amount: int) -> void:
	if _dead or _invulnerable:
		return

	_current_health = max(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)

	if _current_health == 0:
		_die()
		return

	if _attacking:
		_attacking = false
		attack_hitbox.monitoring = false

	_being_hit = true
	sprite.play("hit")
	_start_invulnerability()

func _start_invulnerability() -> void:
	_invulnerable = true
	_blink()
	await get_tree().create_timer(invulnerability_time).timeout
	_invulnerable = false
	sprite.modulate.a = 1.0

func _blink() -> void:
	var blinks := 5
	var step := invulnerability_time / float(blinks * 2)
	for i in range(blinks):
		sprite.modulate.a = 0.3
		await get_tree().create_timer(step).timeout
		sprite.modulate.a = 1.0
		await get_tree().create_timer(step).timeout

func _die() -> void:
	_dead = true
	sprite.play("muerte")
	died.emit()

func _update_animation(direction: Vector2) -> void:
	if direction.length() > 0.0:
		sprite.play("correr")
	else:
		sprite.play("idle")

func _on_animation_finished() -> void:
	if sprite.animation == "atacar":
		_attacking = false
		attack_hitbox.monitoring = false
	elif sprite.animation == "hit":
		_being_hit = false
