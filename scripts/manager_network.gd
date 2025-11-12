extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

var game_in_progress: bool = false

func _ready() -> void:
	print("[Manager:Network] ready")

func create_server() -> void:
	print("Server started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

@rpc("any_peer", "call_local", "reliable")
func peer_login(id: int, display_name: String) -> void:
	print("%s requesting login to server" % id)
	PlayerManager.add_player.rpc(id, display_name)
	
	if multiplayer.is_server(): # Handshake with client
		peer_login.rpc_id(id, id, display_name)

func _on_peer_disconnected(id: int) -> void:
	print("%s disconnected" % id)
	PlayerManager.remove_player(id)

func create_client(ip_address: String) -> void:
	print("Client started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
