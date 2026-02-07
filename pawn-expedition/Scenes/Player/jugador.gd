extends CharacterBody2D

class_name Jugador
@export var stats: DataPiezas

@onready var pivot: Node2D = $Pivot
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var can_move := true
var movement: Vector2
var direction: Vector2
