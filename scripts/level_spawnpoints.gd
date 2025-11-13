extends Node

var spawn_points: Dictionary = {}

func _ready() -> void:
	Helper.log(self, "Spawn points ready")
	
	# Set all spots to free
	for i in get_child_count():
		var node = get_child(i)
		spawn_points.set(i, {
			"pos": node.global_position,
			"free": true
		})
	# Set spawn path in PlayerManager
	PlayerManager.spawn_all_players()

func get_free() -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	for i in spawn_points.size():
		pos = spawn_points[i]["pos"]
		if spawn_points[i]["free"] == true:
			spawn_points[i]["free"] = false
			return pos
	return pos
