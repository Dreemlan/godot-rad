extends Node

# Player
const PLAYER = preload("res://scenes/player.tscn")
var players: Dictionary[int, Node] = {}

# Spawn Points
var spawn_points: Node = null

func add_player(id: int) -> void:
	if not spawn_points: return
	var pos = spawn_points.get_free()
	spawn_player.rpc(id, pos)

func remove_player(id: int) -> void:
	players.erase(id)
	despawn_player.rpc(id)

@rpc("authority", "call_local", "reliable")
func spawn_player(id: int, pos: Vector3) -> void:
	if has_node(str(id)): return
	
	var inst = PLAYER.instantiate()
	inst.name = str(id)
	players.set(id, inst)
	add_child(inst)
	inst.global_position = pos
	
	for existing_id in multiplayer.get_peers():
		if existing_id == 1 or id == 1: return
		spawn_player.rpc_id(id, existing_id, pos)

@rpc("authority", "call_local", "reliable")
func despawn_player(id: int) -> void:
	if not has_node(str(id)): return
	call_deferred("queue_free", get_node(str(id)))
