extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	PlayerManager.add_player(id)

func _on_peer_disconnected(id: int) -> void:
	PlayerManager.remove_player(id)

func create_client(ip_address: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
