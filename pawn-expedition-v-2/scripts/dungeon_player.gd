extends Node2D
class_name DungeonPlayer

signal moved(from_pos: Vector2i, to_pos: Vector2i)
signal turn_ended
signal health_changed(current: int, max_value: int)
signal died
signal transformed(new_type: int)

enum PieceType { PAWN, BISHOP, KNIGHT }

@export var start_grid_pos: Vector2i = Vector2i(2, 5)
@export var max_health: int = 3
@export var start_type: PieceType = PieceType.PAWN
@export var pawn_texture: Texture2D
@export var bishop_texture: Texture2D
@export var knight_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var grid: GridManager
var grid_pos: Vector2i
var piece_type: PieceType
var _hp: int
var _valid_moves: Array = []
var _move_markers: Array = []

func _ready() -> void:
	add_to_group("dungeon_player")
	grid = get_tree().get_first_node_in_group("grid_manager")
	if grid == null:
		push_error("DungeonPlayer: no encontre el GridManager.")
		return
	grid_pos = start_grid_pos
	grid.register(self, grid_pos)
	piece_type = start_type
	_apply_texture()
	_hp = max_health
	health_changed.emit(_hp, max_health)

func start_turn() -> void:
	_show_moves()

func _unhandled_input(event: InputEvent) -> void:
	if grid == null:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell := grid.world_to_grid(get_global_mouse_position())
		if cell in _valid_moves:
			_move_to(cell)

func _move_to(cell: Vector2i) -> void:
	var occ := grid.get_occupant(cell)
	if occ != null and occ.is_in_group("dungeon_enemy") and occ.has_method("capture"):
		occ.capture()
	var from := grid_pos
	grid.move_piece(from, cell)
	grid_pos = cell
	_clear_markers()
	_check_transform()
	moved.emit(from, cell)
	turn_ended.emit()


func _compute_valid_moves() -> Array:
	match piece_type:
		PieceType.PAWN: return _pawn_moves()
		PieceType.BISHOP: return _bishop_moves()
		PieceType.KNIGHT: return _knight_moves()
	return []

func _pawn_moves() -> Array:
	var moves: Array = []
	for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var t: Vector2i = grid_pos + d
		if grid.is_in_bounds(t) and _can_land(t):
			moves.append(t)
	return moves

func _bishop_moves() -> Array:
	var moves: Array = []
	for d in [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		var t: Vector2i = grid_pos + d
		while grid.is_in_bounds(t):
			var occ := grid.get_occupant(t)
			if occ == null:
				moves.append(t)
				t += d
			elif occ.is_in_group("dungeon_enemy"):
				moves.append(t)
				break
			else:
				break 
	return moves

func _knight_moves() -> Array:
	var moves: Array = []
	var offsets := [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1),
					Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
	for o in offsets:
		var t: Vector2i = grid_pos + o
		if grid.is_in_bounds(t) and _can_land(t):
			moves.append(t)
	return moves

func _can_land(cell: Vector2i) -> bool:
	var occ := grid.get_occupant(cell)
	if occ == null:
		return true
	return occ.is_in_group("dungeon_enemy")  


func _show_moves() -> void:
	_clear_markers()
	_valid_moves = _compute_valid_moves()
	var s := float(grid.tile_size)
	for cell in _valid_moves:
		var m := Polygon2D.new()
		m.polygon = PackedVector2Array([Vector2(0, 0), Vector2(s, 0), Vector2(s, s), Vector2(0, s)])
		m.color = Color(0.3, 0.8, 1.0, 0.35)
		m.top_level = true
		m.global_position = grid.grid_to_world(cell) - Vector2(s / 2.0, s / 2.0)
		add_child(m)
		_move_markers.append(m)

func _clear_markers() -> void:
	for m in _move_markers:
		if is_instance_valid(m):
			m.queue_free()
	_move_markers.clear()


func _check_transform() -> void:
	for tile in get_tree().get_nodes_in_group("transform_tile"):
		var tile_cell: Vector2i = grid.world_to_grid(tile.global_position)
		print("[transform] casilla en ", tile_cell, " | jugador en ", grid_pos)
		if tile_cell == grid_pos:
			_transform_to(tile.target_type)
			break

func _transform_to(new_type: int) -> void:
	piece_type = new_type
	_apply_texture()
	transformed.emit(new_type)

func _apply_texture() -> void:
	match piece_type:
		PieceType.PAWN:
			if pawn_texture != null: sprite.texture = pawn_texture
		PieceType.BISHOP:
			if bishop_texture != null: sprite.texture = bishop_texture
		PieceType.KNIGHT:
			if knight_texture != null: sprite.texture = knight_texture


func take_damage(amount: int) -> void:
	_hp = max(_hp - amount, 0)
	health_changed.emit(_hp, max_health)
	if _hp == 0:
		died.emit()
		print("Has caido en la mazmorra")
