extends Node

const LEVEL_ONE: String = "level_one"
const LEVEL_LOBBY: String = "level_lobby"

var active_level_node: Node = null
var active_level_basename: String = ""
var active_level_spawn_points: Dictionary = {}

func _ready() -> void:
	Helper.log(self, "Ready")

func process_join() -> void:
	if ManagerNetwork.is_server():
		client_receieve_active_level_basename.rpc(active_level_basename)

@rpc("authority", "reliable")
func client_receieve_active_level_basename(server_value: String) -> void:
	Helper.log(self, "Client received active level from server %s" % server_value)
	active_level_basename = server_value

@rpc("authority", "call_local", "reliable")
func load_level(level_basename: String) -> void:
	ManagerMenu.hide_active_menu()
	#if active_level_node:
		#print("Game is in progress")
		#return
	
	if active_level_node:
		active_level_node.queue_free()
	
	var level_inst = load("res://scenes/%s.tscn" % level_basename).instantiate()
	call_deferred("add_child", level_inst)
	active_level_node = level_inst
	active_level_basename = level_basename
	Helper.log(self, "Added level to scene tree")

func clear_level() -> void:
	active_level_node = null
	active_level_basename = ""
	for level in get_children():
		level.queue_free()

func get_free_spawn_point() -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	var sp = active_level_spawn_points
	for i in sp.size():
		pos = sp[i]["pos"]
		if sp[i]["free"] == true:
			sp[i]["free"] = false
			return pos
	return pos
