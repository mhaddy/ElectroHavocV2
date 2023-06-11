extends ColorRect

@onready var start_button: Button = %StartButton
@onready var logo = $CenterContainer/Logo

func _ready() -> void:
	Globals.tween_fade_in(logo, 0.5)
	start_button.grab_focus()
	
	# create save file, or load it
	Globals.create_or_load_save()
	
func _on_start_button_pressed() -> void:
	# await results in an instant transition; we want the crossfade effect
	LevelTransition.fade_from_black()
	
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
