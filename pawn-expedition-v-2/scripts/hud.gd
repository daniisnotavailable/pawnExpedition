extends CanvasLayer

@onready var health_bar: Range = $TextureProgressBar
@onready var wave_label: Label = $WaveLabel

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)

	var spawner := get_tree().get_first_node_in_group("spawner")
	if spawner != null:
		if spawner.has_signal("wave_started"):
			spawner.wave_started.connect(_on_wave_started)
		if spawner.has_signal("horde_completed"):
			spawner.horde_completed.connect(_on_horde_completed)
	else:
		wave_label.text = ""

func _on_health_changed(current: int, max_value: int) -> void:
	health_bar.max_value = max_value
	health_bar.value = current

func _on_wave_started(wave_number: int, total: int) -> void:
	wave_label.text = "Oleada %d / %d" % [wave_number, total]

func _on_horde_completed() -> void:
	wave_label.text = "¡Oleada superada!"
