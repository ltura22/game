extends CharacterBody2D

@export var speed := 1000.0
@export var stop_distance := 10.0

@onready var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
@onready var area := $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)

	if self is CharacterBody2D:
		collision_layer = 0
		collision_mask = 0

func _physics_process(delta: float) -> void:
	if player == null:
		queue_free()
		return

	var dir: Vector2 = player.global_position - global_position
	var dist: float = dir.length()

	if dist > stop_distance:
		velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.respawn()
