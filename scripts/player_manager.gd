extends Node

# Player
const PLAYER = preload("res://scenes/player.tscn")
var players: Dictionary[int, Dictionary] = {}

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, display_name: String) -> void:
	if players.has(id): return
	players[id] = { "display_name": display_name }
	
	if multiplayer.is_server():
		for player in PlayerManager.players:
			add_player.rpc_id(id, player, players[multiplayer.get_unique_id()]["display_name"])
		add_player.rpc(id, display_name)

@rpc("any_peer", "call_local", "reliable")
func remove_player(id: int) -> void:
	ScoreManager.remove_player_score(id)
	despawn_player(id)

func spawn_player(id: int) -> void:
	print("%s is spawning: %s" % [multiplayer.get_unique_id(), id])
	if has_node(str(id)): return
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	add_child(inst)

func despawn_player(id: int) -> void:
	players.erase(id)
	if not has_node(str(id)): return
	get_node(str(id)).call_deferred("queue_free")

@rpc("any_peer", "reliable")
func get_server_display_name() -> String:
	var id = multiplayer.get_remote_sender_id()
	return players[id]["display_name"] as String
