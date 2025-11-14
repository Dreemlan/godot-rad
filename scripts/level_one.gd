extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			await get_tree().process_frame
			MenuManager.load_menu(MenuManager.PAUSE)
