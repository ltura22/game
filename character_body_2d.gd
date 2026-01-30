extends CharacterBody2D

@export var speed := 300.0

var move_dir := Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input.length() > 0:
		move_dir = input.normalized()
	else:
		move_dir = Vector2.ZERO

	velocity = move_dir * speed
	move_and_slide()
