extends Camera2D

@export var character: CharacterBody2D
@export var right_margin_ratio := 0.7

func _process(delta: float) -> void:
	if character == null:
		return

	var screen_width := get_viewport_rect().size.x

	var char_x := character.global_position.x
	var cam_x := global_position.x

	var right_limit := cam_x + screen_width * right_margin_ratio

	if char_x > right_limit:
		global_position.x += char_x - right_limit
