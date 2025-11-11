extends Control

func _ready() -> void:
	%DedicatedServer.pressed.connect(_on_dedicated_server)
	%Host.pressed.connect(_on_host)
	%Join.pressed.connect(_on_join)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)

func _on_dedicated_server() -> void:
	NetworkManager.create_server()
	hide()

func _on_host() -> void:
	NetworkManager.create_server()
	
	if %DisplayName.text == "":
		%DisplayName.text = %DisplayName.placeholder_text
	
	PlayerManager.add_player(1, %DisplayName.text)
	
	%LevelSelectMenu.setup_player.rpc_id(1,
		multiplayer.get_unique_id(),
		PlayerManager.players[multiplayer.get_unique_id()]["display_name"])
	
	hide()
	%LevelSelectMenu.show()

func _on_join() -> void:
	if %IPAddress.text == "":
		%IPAddress.text = %IPAddress.placeholder_text
	
	NetworkManager.create_client(%IPAddress.text)
	hide()
	%LoadingScreen.show()

func _on_connected_to_server() -> void:
	if %DisplayName.text == "":
		%DisplayName.text = %DisplayName.placeholder_text
	NetworkManager.peer_login_request.rpc_id(1, multiplayer.get_unique_id(), %DisplayName.text)
	
	hide()
	%LevelSelectMenu.setup_player.rpc_id(1, multiplayer.get_unique_id(), %DisplayName.text)
	%LevelSelectMenu.show()

func peer_login_approved() -> void:
	hide()
	%LevelSelectMenu.setup_player.rpc_id(1, multiplayer.get_unique_id())
	%LevelSelectMenu.show()

func _on_peer_disconnect(id: int) -> void:
	%LevelSelectMenu.remove_player(id)
