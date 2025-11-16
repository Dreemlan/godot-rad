extends Control

var gui_player_ready = []
var ready_statuses: Dictionary[int, bool] = {}

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	
	# Client requests setup on server
	gui_add_player_ready.rpc_id(1,
		multiplayer.get_unique_id(),
		ManagerPlayer.players[multiplayer.get_unique_id()]["display_name"])
	
	# Connect signals on server
	if ManagerNetwork.is_server():
		%LevelOne.pressed.connect(_on_level_one_select.bind("level_one"))
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _input(event: InputEvent) -> void:
	if ManagerLevel.active_level_node: return
	if not ManagerMenu.active_menu_node == self: return
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			ManagerMenu.quit_to_main()

func _all_ready() -> bool:
	# Check if all are ready
	for rs in ready_statuses.values():
		if rs == false:
			return false
	return true

func _on_ready_status_changed(id, status) -> void:
	ready_statuses.set(id, status)


func _on_level_one_select(level_basename: String) -> void:
	if not is_multiplayer_authority(): return
	
	if _all_ready():
		ManagerLevel.load_level.rpc(level_basename)
	else:
		print("Not all players are ready")

func _on_peer_disconnected(id: int) -> void:
	Helper.log(self, "Peer disconnected %s" % id)
	gui_remove_player_ready(id)

@rpc("any_peer", "call_local", "reliable")
func gui_add_player_ready(id: int, display_name: String) -> void:
	if gui_player_ready.has(id): return
	var player_ready_status = load("res://scenes/hud_lobby_player_status.tscn").instantiate()
	player_ready_status.name = str(id)
	player_ready_status.set_multiplayer_authority(id)
	player_ready_status.set_display_name(display_name)
	gui_player_ready.append(id)
	ready_statuses.set(id, false)
	
	%PlayerContainer.add_child(player_ready_status)
	player_ready_status.ready_status_changed.connect(_on_ready_status_changed)
	
	if multiplayer.is_server():
		for player in ManagerPlayer.players:
			gui_add_player_ready.rpc_id(id, player, ManagerPlayer.players[player]["display_name"])
		gui_add_player_ready.rpc(id, display_name)

func gui_remove_player_ready(id: int) -> void:
	gui_player_ready.erase(id)
	if %PlayerContainer.has_node(str(id)):
		%PlayerContainer.get_node(str(id)).call_deferred("queue_free")
