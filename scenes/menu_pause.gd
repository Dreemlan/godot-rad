extends Control

func _ready() -> void:
	%Settings.pressed.connect(_on_settings_pressed)
	%QuitToMain.pressed.connect(_on_quit_to_main_pressed)

func _on_settings_pressed() -> void:
	pass

func _on_quit_to_main_pressed() -> void:
	MenuManager.quit_to_main()
