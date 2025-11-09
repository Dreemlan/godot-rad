extends Control

func _ready() -> void:
	%Host.pressed.connect(_on_host)
	%Join.pressed.connect(_on_join)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_host() -> void:
	hide()
	NetworkManager.create_server()

func _on_join() -> void:
	%LoadingScreen.show()
	
	if %IPAddress.text == "":
		%IPAddress.text = %IPAddress.placeholder_text
	
	NetworkManager.create_client(%IPAddress.text)

func _on_connected_to_server() -> void:
	hide()
