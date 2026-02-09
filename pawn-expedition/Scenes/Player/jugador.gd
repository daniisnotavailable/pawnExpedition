extends CharacterBody2D

class_name Jugador
@export var stats: DataPiezas
@export var move_speed := 200
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

var can_move := true
var movement: Vector2
var direction: Vector2
