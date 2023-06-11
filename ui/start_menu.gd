extends MarginContainer

@onready var start_button: Button = %StartButton

func _ready() -> void:
	start_button.grab_focus()
	
func _on_start_button_pressed() -> void:
	# await results in an instant transition; we want the crossfade effect
	LevelTransition.fade_from_black()
	
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
