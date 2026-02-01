extends Node2D

func activate(player):
	player.set_respawn_position(global_position)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activate(body)
