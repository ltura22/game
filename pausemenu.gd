extends Control


var master_bus := AudioServer.get_bus_index("Master")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	get_parent().toggle_pause()


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, value)
