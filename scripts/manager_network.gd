extends Node

const PORT: int = 42069
const MAX_CLIENTS: int = 8

func _ready() -> void:
	Helper.log(self, "Ready")

func create_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		Helper.log(self, "Failed to start server: %s" % err)
		return
	multiplayer.set_multiplayer_peer(peer)
	#multiplayer.multiplayer_peer = peer
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	Helper.log(self, "Server started")

func create_client(ip_address: String) -> void:
	Helper.log(self, "Client started")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func shutdown_server() -> void:
	Helper.log(self, "Shutting down server")
	if not multiplayer.multiplayer_peer: return
	for peer in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(peer, false)
	ManagerPlayer.clear_players()
	ManagerLevel.clear_level()
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func shutdown_client() -> void:
	Helper.log(self, "Shutting down client")
	ManagerPlayer.clear_players()
	ManagerLevel.clear_level()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func _on_peer_disconnected(id: int) -> void:
	Helper.log(self, "%s disconnected" % id)
	ManagerPlayer.remove_player(id)

func _on_server_disconnected() -> void:
	Helper.log(self, "Lost connection to server")
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	ManagerMenu.load_menu(ManagerMenu.MAIN)
	shutdown_client()

func is_server() -> bool:
	if multiplayer.multiplayer_peer && multiplayer.is_server(): return true
	return false

func is_authority() -> bool:
	if multiplayer.multiplayer_peer && is_multiplayer_authority(): return true
	return false

@rpc("any_peer", "call_local", "reliable")
func peer_login(id: int, display_name: String) -> void:
	Helper.log(self, "Requesting login to server...")
	ManagerPlayer.add_player.rpc(id, display_name)
	
	if multiplayer.is_server(): # Handshake with client
		peer_login.rpc_id(id, id, display_name)
