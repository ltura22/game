extends Area2D

const FIRST_ANIM = "first"
const SECOND_ANIM = "second"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.animation = FIRST_ANIM


func _on_body_entered(body):
	if body is CharacterBody2D:
		sprite.animation = SECOND_ANIM
		body.velocity.y = -5000
