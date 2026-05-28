extends Node2D
class_name DungeonEnemy

var grid: GridManager
var grid_pos: Vector2i
var _planned_move: Vector2i
var _telegraph: Polygon2D

func _ready() -> void:
	add_to_group("dungeon_enemy")
	grid = get_tree().get_first_node_in_group("grid_manager")
	if grid == null:
		push_error("DungeonEnemy: no encontre el GridManager.")
		return
	grid_pos = grid.world_to_grid(global_position)
	grid.register(self, grid_pos)
	_create_telegraph()
	plan_move()

func _create_telegraph() -> void:
	_telegraph = Polygon2D.new()
	var s := float(grid.tile_size)
	_telegraph.polygon = PackedVector2Array([Vector2(0, 0), Vector2(s, 0), Vector2(s, s), Vector2(0, s)])
	_telegraph.color = Color(1, 0, 0, 0.35)
	_telegraph.top_level = true
	_telegraph.visible = false
	add_child(_telegraph)

func plan_move() -> void:
	var player := get_tree().get_first_node_in_group("dungeon_player")
	if player == null:
		return
	var delta: Vector2i = player.grid_pos - grid_pos
	var step := Vector2i(signi(delta.x), signi(delta.y))
	var target := grid_pos + step
	if not grid.is_in_bounds(target):
		target = grid_pos
	_planned_move = target
	_show_telegraph(target)

func execute_move() -> void:
	if _planned_move == grid_pos:
		return
	var occupant := grid.get_occupant(_planned_move)
	if occupant != null:
		if occupant.is_in_group("dungeon_player") and occupant.has_method("take_damage"):
			occupant.take_damage(1)
		return
	grid.move_piece(grid_pos, _planned_move)
	grid_pos = _planned_move
	_hide_telegraph()

func capture() -> void:
	grid.unregister(grid_pos)
	if _telegraph != null:
		_telegraph.queue_free()
	queue_free()

func _show_telegraph(tile: Vector2i) -> void:
	var s := float(grid.tile_size)
	_telegraph.global_position = grid.grid_to_world(tile) - Vector2(s / 2.0, s / 2.0)
	_telegraph.visible = true

func _hide_telegraph() -> void:
	_telegraph.visible = false
