extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

var game_in_progress: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")

func create_server() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	Helper.log(self, "Multiplayer peer: %s" % multiplayer.multiplayer_peer)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Helper.log(self, "Server started")

func shutdown_server() -> void:
	Helper.log(self, "Shutting down server")
	if not multiplayer.multiplayer_peer: return
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer, false)
	PlayerManager.clear_players()
	LevelManager.clear_level()
	MenuManager.is_ingame = false
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func shutdown_client() -> void:
	Helper.log(self, "Shutting down client")
	Helper.log(self, "Multiplayer peer: %s" % multiplayer.multiplayer_peer)
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	Helper.log(self, "Multiplayer peer: %s" % multiplayer.multiplayer_peer)

@rpc("any_peer", "call_local", "reliable")
func peer_login(id: int, display_name: String) -> void:
	Helper.log(self, "Requesting login to server...")
	PlayerManager.add_player.rpc(id, display_name)
	
	if multiplayer.is_server(): # Handshake with client
		peer_login.rpc_id(id, id, display_name)

func _on_peer_disconnected(id: int) -> void:
	Helper.log(self, "%s disconnected" % id)
	PlayerManager.remove_player(id)

func create_client(ip_address: String) -> void:
	Helper.log(self, "Client started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_server_disconnected() -> void:
	Helper.log(self, "Lost connection to server")
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	MenuManager.load_menu(MenuManager.MAIN)

func is_server() -> bool:
	if multiplayer.multiplayer_peer && multiplayer.is_server(): return true
	return false

func is_authority() -> bool:
	if multiplayer.multiplayer_peer && is_multiplayer_authority(): return true
	return false
