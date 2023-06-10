extends MarginContainer

func _on_start_button_pressed():
	# await results in an instant transition; we want the crossfade effect
	LevelTransition.fade_from_black()
	
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
