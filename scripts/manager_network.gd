extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

var game_in_progress: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Helper.log(self, "Server started")

func shutdown_server() -> void:
	if not multiplayer.multiplayer_peer: return
	
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer, true)
	
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	
	
	PlayerManager.clear_players()
	LevelManager.clear_level()
	MenuManager.is_ingame = false

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

func is_server() -> bool:
	if multiplayer.multiplayer_peer && multiplayer.is_server(): return true
	return false
