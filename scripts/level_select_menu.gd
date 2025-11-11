extends Control

var players_ready = []

func _ready() -> void:
	%LevelOne.pressed.connect(_on_level_one_select)
	_ready_cleanup()

func _ready_cleanup() -> void:
	for child in %PlayerContainer.get_children():
		child.queue_free()

@rpc("any_peer", "call_local", "reliable")
func setup_player(id: int, display_name: String) -> void:
	if players_ready.has(id): return
	var player_ready_status = load("res://scenes/hud_player_status.tscn").instantiate()
	player_ready_status.name = str(id)
	player_ready_status.set_multiplayer_authority(id)
	player_ready_status.set_display_name(display_name)
	players_ready.append(id)
	%PlayerContainer.add_child(player_ready_status)
	
	if multiplayer.is_server():
		for player in PlayerManager.players:
			setup_player.rpc_id(id, player, PlayerManager.players[player]["display_name"])
		setup_player.rpc(id, display_name)

func remove_player(id: int) -> void:
	players_ready.erase(id)
	%PlayerContainer.get_node(str(id)).call_deferred("queue_free")

func _on_level_one_select() -> void:
	# Check if all players are ready
	pass
	#%LevelManager.load_level()
