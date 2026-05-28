extends Node

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("dungeon_player")
	if player != null and player.has_signal("turn_ended"):
		player.turn_ended.connect(_on_player_turn_ended)

func _on_player_turn_ended() -> void:
	for e in get_tree().get_nodes_in_group("dungeon_enemy"):
		if is_instance_valid(e):
			e.execute_move()
	for e in get_tree().get_nodes_in_group("dungeon_enemy"):
		if is_instance_valid(e):
			e.plan_move()
