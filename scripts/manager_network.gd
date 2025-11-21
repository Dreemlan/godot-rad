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
	multiplayer.multiplayer_peer = peer
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
	ManagerPlayer.remove_player.rpc(id)

func _on_server_disconnected() -> void:
	Helper.log(self, "Lost connection to server")
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	ManagerMenu.load_menu(ManagerMenu.MAIN)
	shutdown_client()

# Called when client has successfully connected to server
@rpc("any_peer", "call_local", "reliable")
func join_request(id: int, display_name: String, color: Color) -> void:
	if ManagerPlayer.players.has(id): return
	if multiplayer.is_server(): # Handshake with client
		Helper.log(self, "%s requesting to join server..." % id)
		ManagerPlayer.register_player.rpc(id, display_name, color)
		join_request.rpc_id(id, id, display_name, color)
