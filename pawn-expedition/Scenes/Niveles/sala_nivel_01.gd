extends Node2D

@export var obstaculo_scene: PackedScene
@export var player_scene: PackedScene
@export var llave_scene: PackedScene
@export var trampa_scene: PackedScene

@export var spawn_area_min: Vector2 = Vector2(-150, -150)
@export var spawn_area_max: Vector2 = Vector2(150, 150)
@export var spawn_player_pos: Vector2 = Vector2(0, 0)

var posiciones_ocupadas: Array[Vector2] = []

@onready var barra_vida: ProgressBar = $HUDTemporal/BarraVida
@onready var etiqueta: Label = $HUDTemporal/DatosEtiqueta

func _ready() -> void:
	randomize()
	posiciones_ocupadas.clear()
	posiciones_ocupadas.append(spawn_player_pos)
	spawn_generico(trampa_scene, 3)
	spawn_generico(llave_scene, 2)
	spawn_generico(obstaculo_scene, GameGlobal.get_box_count_for_level())


	spawn_players()
	
func spawn_generico(escena: PackedScene, cantidad: int) -> void:
	if escena == null: return
	var distancia_minima: float = 30.0
	for i in range(cantidad):
		var objeto = escena.instantiate()
		var pos_valida = false
		var intentos = 0
		var pos_final = Vector2.ZERO
		
		while not pos_valida and intentos < 100:
			intentos += 1
			var test_pos = Vector2(
				randf_range(spawn_area_min.x, spawn_area_max.x),
				randf_range(spawn_area_min.y, spawn_area_max.y)
			)
			
			var choca = false
			for ocupada in posiciones_ocupadas:
				if test_pos.distance_to(ocupada) < distancia_minima:
					choca = true
					break
			
			if not choca:
				pos_final = test_pos
				pos_valida = true
			
		if pos_valida:
			objeto.position = pos_final
			add_child(objeto)
			posiciones_ocupadas.append(pos_final)
		else:
			objeto.queue_free()
	
func _process(_delta: float) -> void:
	if barra_vida:
		barra_vida.max_value = 100
		barra_vida.value = GameGlobal.player_hp
	
	if etiqueta:
		etiqueta.text = "Nivel: %d | Llaves: %d" % [GameGlobal.current_level, GameGlobal.player_gold]
		
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
