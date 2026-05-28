extends Node
class_name GridManager

@export var grid_width: int = 6
@export var grid_height: int = 6
@export var tile_size: int = 16
@export var origin: Vector2 = Vector2(0, 0)

var occupants: Dictionary = {}

func _ready() -> void:
	add_to_group("grid_manager")

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return origin + Vector2(grid_pos.x * tile_size + tile_size / 2.0,
							grid_pos.y * tile_size + tile_size / 2.0)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - origin
	return Vector2i(int(local.x / tile_size), int(local.y / tile_size))

func is_in_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_width \
		and grid_pos.y >= 0 and grid_pos.y < grid_height

func is_empty(grid_pos: Vector2i) -> bool:
	return is_in_bounds(grid_pos) and not occupants.has(grid_pos)

func get_occupant(grid_pos: Vector2i) -> Node:
	if occupants.has(grid_pos):
		return occupants[grid_pos]
	return null

func register(piece: Node, grid_pos: Vector2i) -> void:
	occupants[grid_pos] = piece
	if piece is Node2D:
		piece.global_position = grid_to_world(grid_pos)

func move_piece(from: Vector2i, to: Vector2i) -> void:
	if not occupants.has(from):
		return
	var piece = occupants[from]
	occupants.erase(from)
	occupants[to] = piece
	if piece is Node2D:
		piece.global_position = grid_to_world(to)

func unregister(grid_pos: Vector2i) -> void:
	occupants.erase(grid_pos)
