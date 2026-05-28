extends Node2D
class_name DungeonPlayer

signal moved(from_pos: Vector2i, to_pos: Vector2i)
signal turn_ended

@export var start_grid_pos: Vector2i = Vector2i(3, 6)

var grid: GridManager
var grid_pos: Vector2i

func _ready() -> void:
	grid = get_tree().get_first_node_in_group("grid_manager")
	if grid == null:
		push_error("DungeonPlayer: no encontre el GridManager.")
		return
	grid_pos = start_grid_pos
	grid.register(self, grid_pos)

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
	if not grid.is_empty(target):
		return 
	var from := grid_pos
	grid.move_piece(grid_pos, target)
	grid_pos = target
	moved.emit(from, target)
	turn_ended.emit()
