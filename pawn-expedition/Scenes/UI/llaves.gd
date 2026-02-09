extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		body.add_gold(1)
		queue_free()
#No tengo sprites para monedas, entonces, uso llaves
