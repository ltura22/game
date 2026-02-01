extends Node

@onready var level01 := $Level01
@onready var mainmenu_layer := $MainMenu/CanvasLayer
@onready var pausemenu := $PauseMenu/CanvasLayer

var is_paused := false

func _ready() -> void:
	mainmenu_layer.show()      # Make sure menu is visible
	level01.hide()       # Hide level at start
	pausemenu.hide()
	$MainMenu/CanvasLayer/StartButton.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	mainmenu_layer.hide()
	level01.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	


func toggle_pause():
	is_paused = not is_paused
	if is_paused:
		pausemenu.show()
		Engine.time_scale = 0.0
		
	else:
		pausemenu.hide()
		Engine.time_scale = 1.0
		
		
