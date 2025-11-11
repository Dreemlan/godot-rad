extends Node

# Player
const PLAYER = preload("res://scenes/player.tscn")
var players: Dictionary[int, Node] = {}

# Spawn Points
var spawn_points: Node = null

func add_player(id: int) -> void:
	if not spawn_points: return
	spawn_player.rpc(id)

func remove_player(id: int) -> void:
	players.erase(id)
	despawn_player.rpc(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int) -> void:
	if has_node(str(id)): return
	
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	players.set(id, inst)
	add_child(inst)
	
	if multiplayer.is_server():
		inst.global_position = spawn_points.get_free()
	
	elif id == multiplayer.get_unique_id():
		for existing_id in multiplayer.get_peers():
			if existing_id == 1: continue
			spawn_player(existing_id)

@rpc("authority", "call_local", "reliable")
func despawn_player(id: int) -> void:
	if not has_node(str(id)): return
	get_node(str(id)).call_deferred("queue_free")
