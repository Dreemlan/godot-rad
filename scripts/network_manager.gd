extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

@rpc("any_peer", "call_local", "reliable")
func peer_login_request(id: int, display_name: String) -> void:
	PlayerManager.add_player.rpc(id, display_name)

func _on_peer_disconnected(id: int) -> void:
	PlayerManager.remove_player(id)

func create_client(ip_address: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
