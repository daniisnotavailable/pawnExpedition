extends Node2D

@export var obstaculo_scene: PackedScene
@export var player_scene: PackedScene

@export var spawn_area_min: Vector2 = Vector2(-150, -150)
@export var spawn_area_max: Vector2 = Vector2(150, 150)
@export var spawn_player_pos: Vector2 = Vector2(0, 0)

@onready var barra_vida: ProgressBar = $HUDTemporal/BarraVida
@onready var etiqueta: Label = $HUDTemporal/DatosEtiqueta

func _ready() -> void:
	spawn_obstaculos()
	spawn_players()
	
func _process(_delta: float) -> void:
	if barra_vida:
		barra_vida.max_value = 100
		barra_vida.value = GameGlobal.player_hp
	
	if etiqueta:
		etiqueta.text = "Nivel: %d | Oro: %d" % [GameGlobal.current_level, GameGlobal.player_gold]
	
func spawn_obstaculos() -> void:
	if not obstaculo_scene: return
	
	var count: int = GameGlobal.get_box_count_for_level()
	for i in range(count):
		var obstaculo: StaticBody2D = obstaculo_scene.instantiate()
		var pos_x = randf_range(spawn_area_min.x, spawn_area_max.x)
		var pos_y = randf_range(spawn_area_min.y, spawn_area_max.y)
		obstaculo.position = Vector2(pos_x, pos_y)
		add_child(obstaculo)
		
func spawn_players() -> void:
	if player_scene:
		var jugador: CharacterBody2D = player_scene.instantiate()
		jugador.position = spawn_player_pos
		add_child(jugador)
	
func _on_puerta_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body is CharacterBody2D:
		print("Pasando de nivel")
		if GameGlobal.advance_level():
			get_tree().reload_current_scene()
		else:
			print("Terminado")
			GameGlobal.reset_run()
			get_tree().reload_current_scene()
