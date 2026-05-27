extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HUD: no encontre al Player en el grupo 'player'.")
		return
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, max_value: int) -> void:
	health_bar.max_value = max_value
	health_bar.value = current
