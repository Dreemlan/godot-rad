extends Control

func _ready() -> void:
	%Settings.pressed.connect(_on_settings_pressed)
	%QuitToLobby.pressed.connect(_on_quit_to_lobby_pressed)
	%QuitToMain.pressed.connect(_on_quit_to_main_pressed)

func _on_settings_pressed() -> void:
	pass

func _on_quit_to_lobby_pressed() -> void:
	if multiplayer.is_server():
		ManagerMenu.quit_to_lobby.rpc()

func _on_quit_to_main_pressed() -> void:
	ManagerMenu.quit_to_main()
