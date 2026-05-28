extends Node2D
class_name TransformTile

enum PieceType { PAWN, BISHOP, KNIGHT }

@export var target_type: PieceType = PieceType.BISHOP

var grid: GridManager
var grid_pos: Vector2i

func _ready() -> void:
	add_to_group("transform_tile")
	grid = get_tree().get_first_node_in_group("grid_manager")
	if grid != null:
		grid_pos = grid.world_to_grid(global_position)
		global_position = grid.grid_to_world(grid_pos)
