extends Node

const PLAYER = preload("res://scenes/character_player.tscn")
var players: Dictionary[int, Dictionary] = {}
var fully_loaded_players: Array = []
var active_player_nodes: Dictionary[int, Node] = {}

var spawn_points = null

func _ready() -> void:
	Helper.log(self, "Ready")

@rpc("authority", "call_local", "reliable")
func register_player(new_id: int, display_name: String) -> void:
	players[new_id] = { "display_name": display_name }
	
	if multiplayer.is_server():
		for existing_id in ManagerPlayer.players:
			if existing_id == new_id: continue
			register_player.rpc_id(new_id, existing_id, players[existing_id]["display_name"])
		ManagerMenu.process_join.rpc_id(new_id)
	
	Helper.log(self, "Successfully registered player %s to 'players'" % display_name)

@rpc("any_peer", "call_local", "reliable")
func remove_player(id: int) -> void:
	players.erase(id)
	fully_loaded_players.erase(id)
	active_player_nodes.erase(id)
	despawn_player(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int) -> void:
	if has_node(str(id)): return
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	
	inst.player_spawned.connect(_on_player_spawned)
	
	active_player_nodes.set(id, inst)
	
	add_child(inst)
	inst.global_position = ManagerLevel.get_free()
	Helper.log(self, "Added 'Player' %s to scene tree" % ManagerPlayer.players[id]["display_name"])

func despawn_player(id: int) -> void:
	if not has_node(str(id)): return
	get_node(str(id)).call_deferred("queue_free")

@rpc("any_peer", "call_local", "reliable")
func spawn_all_players() -> void:
	if multiplayer.is_server():
		for id in players:
			spawn_player.rpc(id)

func clear_players() -> void:
	players = {}
	fully_loaded_players = []
	active_player_nodes = {}
	for player in get_children():
		player.queue_free()

func clear_player_nodes() -> void:
	for player in get_children():
		player.queue_deletion.rpc()

func _on_player_spawned(id: int) -> void:
	if id == multiplayer.get_unique_id():
		ManagerLevel.set_camera_focus(active_player_nodes[id])
