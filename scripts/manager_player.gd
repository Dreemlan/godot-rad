extends Node

const PLAYER = preload("res://scenes/character_player.tscn")
var players: Dictionary[int, Dictionary] = {}

var spawn_points = null

func _ready() -> void:
	Helper.log(self, "Ready")

@rpc("any_peer", "call_local", "reliable")
func register_player(id: int, display_name: String) -> void:
	if players.has(id): return
	players[id] = { "display_name": display_name }
	
	if multiplayer.is_server():
		for player in ManagerPlayer.players:
			register_player.rpc_id(id, player, players[multiplayer.get_unique_id()]["display_name"])
	
	if id == multiplayer.get_unique_id():
		ManagerMenu.process_join()
	
	Helper.log(self, "Registered 'Player' %s nickname to 'Dictionary'" % [id])

@rpc("any_peer", "call_local", "reliable")
func remove_player(id: int) -> void:
	despawn_player(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int) -> void:
	if has_node(str(id)): return
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	add_child(inst)
	inst.global_position = ManagerLevel.get_free()
	Helper.log(self, "Added 'Player' %s to scene tree" % id)

func despawn_player(id: int) -> void:
	players.erase(id)
	if not has_node(str(id)): return
	get_node(str(id)).call_deferred("queue_free")

func spawn_all_players() -> void:
	if multiplayer.is_server():
		for id in players:
			spawn_player.rpc(id)

func clear_players() -> void:
	players = {}
	for player in get_children():
		player.queue_free()

func clear_player_nodes() -> void:
	for player in get_children():
		player.queue_deletion.rpc()
