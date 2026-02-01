extends CharacterBody2D


@export var SPEED = 2000.0
@export var point_a: Vector2
@export var point_b: Vector2
var target := Vector2.ZERO

func _ready():
	target = point_b
	
func _physics_process(delta: float) -> void:
	position = position.move_toward(target, SPEED*delta)
	if position.is_equal_approx(target):
		target = point_a if target == point_b else point_b
