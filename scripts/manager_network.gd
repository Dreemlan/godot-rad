extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

var game_in_progress: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")

func create_server() -> void:
	Helper.log(self, "Server started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func shutdown_server() -> void:
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer, true)
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null

@rpc("any_peer", "call_local", "reliable")
func peer_login(id: int, display_name: String) -> void:
	Helper.log(self, "Requesting login to server...")
	PlayerManager.add_player.rpc(id, display_name)
	
	if multiplayer.is_server(): # Handshake with client
		peer_login.rpc_id(id, id, display_name)

func _on_peer_disconnected(id: int) -> void:
	print("%s disconnected" % id)
	PlayerManager.remove_player(id)

func create_client(ip_address: String) -> void:
	Helper.log(self, "Client started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
