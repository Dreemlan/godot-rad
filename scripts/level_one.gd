extends Node

@export var spawn_point_path: Node

var spawn_points: Dictionary = {}

func _ready() -> void:
	# Set all spawn points to free, then spawn all players
	for i in spawn_point_path.get_child_count():
		var point = spawn_point_path.get_child(i)
		spawn_points.set(i, {
			"pos": point.global_position,
			"free": true
		})
	PlayerManager.spawn_all_players()

func get_free() -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	for i in spawn_points.size():
		pos = spawn_points[i]["pos"]
		if spawn_points[i]["free"] == true:
			spawn_points[i]["free"] = false
			return pos
	return pos


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			await get_tree().process_frame
			MenuManager.load_menu(MenuManager.PAUSE)
