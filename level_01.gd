extends Node2D

@onready var tilemap_blue := $BlueTileMap
@onready var tilemap_red := $RedTileMap
@onready var player := $CharacterBody2D

@export var alien_scene: PackedScene
@export var alien_spawn_delay := 1.5
@onready var alien_container := $AlienContainer  # make a Node2D in your scene to hold aliens




var isRedActive := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isRedActive = false
	tilemap_red.visible = false
	tilemap_red.collision_enabled = false
	tilemap_blue.visible = true
	tilemap_blue.collision_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch"):
		isRedActive = not isRedActive
		player.change_time(isRedActive)
		if isRedActive:
			tilemap_red.visible = true
			tilemap_red.collision_enabled = true
			tilemap_blue.visible = false
			tilemap_blue.collision_enabled = false
		else:
			tilemap_red.visible = false
			tilemap_red.collision_enabled = false
			tilemap_blue.visible = true
			tilemap_blue.collision_enabled = true
			

func spawn_alien_at_player_respawn():
	var spawn_pos = player.respawn_position

	for old_alien in alien_container.get_children():
		old_alien.queue_free()
	await get_tree().create_timer(alien_spawn_delay).timeout

	var alien = alien_scene.instantiate()
	alien.global_position = spawn_pos
	alien_container.add_child(alien)
