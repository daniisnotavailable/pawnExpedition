extends Node

signal wave_started(wave_number: int, total_waves: int)
signal wave_completed(wave_number: int)
signal horde_completed

@export var goblin_scene: PackedScene
@export var fly_scene: PackedScene
@export var boar_scene: PackedScene

@export var spawn_radius_min: float = 200.0
@export var spawn_radius_max: float = 320.0
@export var delay_between_waves: float = 2.0

var waves: Array = [
	{"goblin": 3},
	{"goblin": 4, "fly": 1},
	{"goblin": 4, "fly": 2},
	{"goblin": 3, "fly": 2, "boar": 1},
	{"goblin": 5, "fly": 3, "boar": 2},
]

var _current_wave_index: int = 0
var _alive_enemies: Array = []
var _player: Node2D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		push_warning("WaveSpawner: no encontre al Player en grupo 'player'.")
		return
	_start_next_wave.call_deferred()

func _start_next_wave() -> void:
	if _current_wave_index >= waves.size():
		print("Horde completado")
		horde_completed.emit()
		return
	_current_wave_index += 1
	var wave: Dictionary = waves[_current_wave_index - 1]
	print("Oleada %d/%d" % [_current_wave_index, waves.size()])
	wave_started.emit(_current_wave_index, waves.size())
	for enemy_type in wave.keys():
		var count: int = wave[enemy_type]
		for i in range(count):
			_spawn_enemy(enemy_type)

func _spawn_enemy(type: String) -> void:
	var scene: PackedScene
	match type:
		"goblin": scene = goblin_scene
		"fly": scene = fly_scene
		"boar": scene = boar_scene
		_: return
	if scene == null:
		push_warning("WaveSpawner: escena no asignada para tipo " + type)
		return
	var enemy: Node2D = scene.instantiate()
	var angle := randf() * TAU
	var dist := randf_range(spawn_radius_min, spawn_radius_max)
	enemy.global_position = _player.global_position + Vector2(cos(angle), sin(angle)) * dist
	get_parent().add_child.call_deferred(enemy)
	_alive_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_freed.bind(enemy))

func _on_enemy_freed(enemy: Node) -> void:
	_alive_enemies.erase(enemy)
	if _alive_enemies.is_empty():
		wave_completed.emit(_current_wave_index)
		_schedule_next_wave.call_deferred()

func _schedule_next_wave() -> void:
	await get_tree().create_timer(delay_between_waves).timeout
	_start_next_wave()
