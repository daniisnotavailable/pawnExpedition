extends Node

const DB_PATH := "user://game.db"

var db: SQLite
var max_levels: int = 5
var current_level: int = 0
var level_difficulty: Array[int] = [5, 8, 12, 15, 20]

var player_hp: float = 100.0
var player_max_hp: float = 100.0
var player_gold: int = 0

func _ready() -> void:
	_init_database()
	load_game()

func _init_database() -> void:
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	db.query(
		"CREATE TABLE IF NOT EXISTS save_data ("
		+ "id INTEGER PRIMARY KEY AUTOINCREMENT, "
		+ "hp REAL DEFAULT 100.0, "
		+ "gold INTEGER DEFAULT 0, "
		+ "current_level INTEGER DEFAULT 0"
		+ ");"
	)
	db.query("SELECT COUNT(*) AS total FROM save_data;")
	if db.query_result[0]["total"] == 0:
		db.query(
			"INSERT INTO save_data (hp, gold, current_level) VALUES (%f, %d, %d);"
			% [player_max_hp, 0, 0]
		)

func save_game() -> void:
	db.query(
		"UPDATE save_data SET hp = %f, gold = %d, current_level = %d WHERE id = 1;"
		% [player_hp, player_gold, current_level]
	)

func load_game() -> void:
	db.query("SELECT * FROM save_data WHERE id = 1;")
	if db.query_result.is_empty():
		return
	var row: Dictionary = db.query_result[0]
	player_hp = row["hp"]
	player_gold = row["gold"]
	current_level = row["current_level"]

func reset_run() -> void:
	current_level = 0
	player_hp = player_max_hp
	player_gold = 0
	save_game()

func get_box_count_for_level() -> int:
	if current_level < level_difficulty.size():
		return level_difficulty[current_level]
	return level_difficulty.back()

func advance_level() -> bool:
	current_level += 1
	save_game()
	return current_level < max_levels

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		if db:
			db.close_db()
