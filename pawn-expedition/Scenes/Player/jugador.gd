extends CharacterBody2D

class_name Jugador
@export var move_speed := 200
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

var hp: float
var gold: int

func _ready() -> void:
	hp = GameGlobal.player_hp
	gold = GameGlobal.player_gold
	
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			nav_agent.target_position = get_global_mouse_position()
			
func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		if sprite.sprite_frames.has_animation("iddle"):
			sprite.play("iddle")
		return

	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_pos)
	velocity = direction * move_speed
	move_and_slide()
	
	if (direction.x > 0.1):
		sprite.flip_h = false
	elif (direction.x < -0.1):
		sprite.flip_h = true
	if (sprite.sprite_frames.has_animation("move")):
		sprite.play("move")
	
func take_damage (amount: float) -> void:
	hp -= amount
	GameGlobal.player_hp = hp
	if hp <= 0.0:
		GameGlobal.reset_run()
		get_tree().reload_current_scene()

func add_gold (amount: int) -> void:
	gold += amount
	GameGlobal.player_gold = gold
