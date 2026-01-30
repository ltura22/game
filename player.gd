extends CharacterBody2D

@export var speed := 300
@export var jump_velocity := -400
@export var gravity := 1200

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Horizontal input
	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * speed

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_velocity

	if velocity.x < 0:
		sprite.flip_h = true
		sprite.play("walk")
	elif velocity.x > 0:
		sprite.flip_h = false
		sprite.play("walk")
	else:
		sprite.play("idle");

	# Move character
	move_and_slide()
