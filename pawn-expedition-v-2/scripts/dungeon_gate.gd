extends Node2D

signal player_entered

@export var next_scene_path: String = "res://scenes/levels/Dungeon.tscn"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

var _open: bool = false
var _used: bool = false

func _ready() -> void:
	sprite.play("cerrada")
	area.body_entered.connect(_on_body_entered)
	var spawner := get_tree().get_first_node_in_group("spawner")
	if spawner != null and spawner.has_signal("horde_completed"):
		spawner.horde_completed.connect(_on_horde_completed)

func _on_horde_completed() -> void:
	open_gate()

func open_gate() -> void:
	if _open:
		return
	_open = true
	sprite.play("abrir")

func _on_body_entered(body: Node) -> void:
	if not _open or _used:
		return
	if body.is_in_group("player"):
		_used = true
		player_entered.emit()
		SceneTransition.change_scene(next_scene_path)
