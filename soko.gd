extends Area2D

const FIRST_ANIM = "first"
const SECOND_ANIM = "second"

# @onready-ს ვიყენებთ, რომ დარწმუნებულნი ვიყოთ, ნოდები უკვე მზადაა
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.animation = FIRST_ANIM


func _on_body_entered(body):
	if sprite != null:
		sprite.animation = SECOND_ANIM
