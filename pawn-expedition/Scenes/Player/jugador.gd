extends CharacterBody2D

class_name Jugador
@export var move_speed := 200
@onready var sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D
var target_position: Vector2

var hp: float
var gold: int

func _ready() -> void:
	hp = GameGlobal.player_hp
	gold = GameGlobal.player_gold
	target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	if global_position.distance_to(target_position) > 10.0:
		var direction = global_position.direction_to(target_position)
		velocity = direction * move_speed
		move_and_slide()
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		if sprite.sprite_frames.has_animation("iddle"):
			sprite.play("iddle")
	
func take_damage (amount: float) -> void:
	hp -= amount
	GameGlobal.player_hp = hp
	if hp <= 0.0:
		GameGlobal.reset_run()
		get_tree().reload_current_scene()

func add_gold (amount: int) -> void:
	gold += amount
	GameGlobal.player_gold = gold
