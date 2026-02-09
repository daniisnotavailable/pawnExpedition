extends Resource

class_name DataNiveles
@export var num_salas := 6
@export var tamanho_salas := Vector2(384, 384)
@export var aspecto_salas := PackedScene
@export var min_enemigo_por_sala := 5
@export var max_enemigo_por_sala := 15

## Array porque van a haber más de un enemigo
@export var escenas_enemigos: Array[PackedScene] 
@export var guardar_datos: Array
