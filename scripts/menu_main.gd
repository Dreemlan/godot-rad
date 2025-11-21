extends Control

func _ready() -> void:
	Helper.log(self, "Ready")
	
	%DedicatedServer.pressed.connect(_on_dedicated_server)
	%Host.pressed.connect(_on_host)
	%Join.pressed.connect(_on_join)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)

func _on_dedicated_server() -> void:
	ManagerNetwork.create_server()

func _on_host() -> void:
	ManagerNetwork.create_server()
	
	if %DisplayName.text == "":
		%DisplayName.text = %DisplayName.placeholder_text
	
	ManagerNetwork.join_request(1, %DisplayName.text, %ColorPicker.color)

func _on_join() -> void:
	if %IPAddress.text == "":
		%IPAddress.text = %IPAddress.placeholder_text
	
	ManagerNetwork.create_client(%IPAddress.text)
	hide()
	#%LoadingScreen.show()

func _on_connected_to_server() -> void:
	if %DisplayName.text == "":
		%DisplayName.text = %DisplayName.placeholder_text
	ManagerNetwork.join_request.rpc_id(1, multiplayer.get_unique_id(), %DisplayName.text, %ColorPicker.color)

func progress_to_lobby() -> void:
	hide()
	%MenuLobby.setup_player.rpc_id(1, multiplayer.get_unique_id(), %DisplayName.text)
	%MenuLobby.show()

func peer_login_approved() -> void:
	hide()
	%MenuLobby.setup_player.rpc_id(1, multiplayer.get_unique_id())
	%MenuLobby.show()

func _on_peer_disconnect(_id: int) -> void:
	pass
