extends Node

@export var spawn_point_path: Node

func _ready() -> void:
	# Set all spawn points to free, then spawn all players
	for i in spawn_point_path.get_child_count():
		var point = spawn_point_path.get_child(i)
		ManagerLevel.active_level_spawn_points.set(i, {
			"pos": point.global_position,
			"free": true
		})
	ManagerPlayer.spawn_all_players.rpc_id(1)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			await get_tree().process_frame
			ManagerMenu.load_menu(ManagerMenu.PAUSE)
