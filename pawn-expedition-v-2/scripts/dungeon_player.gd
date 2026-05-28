extends Node2D
class_name DungeonPlayer

signal moved(from_pos: Vector2i, to_pos: Vector2i)
signal turn_ended
signal health_changed(current: int, max_value: int)
signal died

@export var start_grid_pos: Vector2i = Vector2i(3, 5)
@export var max_health: int = 3

var grid: GridManager
var grid_pos: Vector2i
var _hp: int

func _ready() -> void:
	add_to_group("dungeon_player")
	grid = get_tree().get_first_node_in_group("grid_manager")
	if grid == null:
		push_error("DungeonPlayer: no encontre el GridManager.")
		return
	grid_pos = start_grid_pos
	grid.register(self, grid_pos)
	_hp = max_health
	health_changed.emit(_hp, max_health)

func _unhandled_input(event: InputEvent) -> void:
	if grid == null:
		return
	var dir := Vector2i.ZERO
	if event.is_action_pressed("move_up"):
		dir = Vector2i(0, -1)
	elif event.is_action_pressed("move_down"):
		dir = Vector2i(0, 1)
	elif event.is_action_pressed("move_left"):
		dir = Vector2i(-1, 0)
	elif event.is_action_pressed("move_right"):
		dir = Vector2i(1, 0)
	if dir != Vector2i.ZERO:
		_try_move(dir)

func _try_move(dir: Vector2i) -> void:
	var target := grid_pos + dir
	if not grid.is_in_bounds(target):
		return
	var occupant := grid.get_occupant(target)
	if occupant != null:
		if occupant.is_in_group("dungeon_enemy") and occupant.has_method("capture"):
			occupant.capture()
		else:
			return
	var from := grid_pos
	grid.move_piece(from, target)
	grid_pos = target
	moved.emit(from, target)
	turn_ended.emit()

func take_damage(amount: int) -> void:
	_hp = max(_hp - amount, 0)
	health_changed.emit(_hp, max_health)
	if _hp == 0:
		died.emit()
		print("Has caido en la mazmorra")
