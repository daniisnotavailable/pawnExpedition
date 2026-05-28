extends CanvasLayer

@onready var rect: ColorRect = $ColorRect
@export var fade_duration: float = 0.5

func _ready() -> void:
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(path: String) -> void:
	var tween := create_tween()
	tween.tween_property(rect, "color:a", 1.0, fade_duration)
	await tween.finished
	get_tree().change_scene_to_file(path)
	tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, fade_duration)
