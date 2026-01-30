extends Node2D

@onready var tilemap_blue := $BlueTileMap
@onready var tilemap_red := $RedTileMap

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
	if Input.is_action_just_pressed("ui_select"):
		isRedActive = not isRedActive
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
		
	
