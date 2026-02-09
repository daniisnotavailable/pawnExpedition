extends Area2D

@export var damage: float = 20.0
func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		body.take_damage(damage)
		print("Recibes daño (en teoría)")
