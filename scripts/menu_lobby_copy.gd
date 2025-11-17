extends Control

var active_gui_nodes: Dictionary[int, Node] = {}
var ready_statuses: Dictionary[int, Dictionary] = {}

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	
	# Client requests setup on server
	# This is IMPORTANT because it forces the client to load existing data first
	gui_add_player_ready.rpc_id(1,
		multiplayer.get_unique_id(),
		ManagerPlayer.players[multiplayer.get_unique_id()]["display_name"])
	
	# Connect signals on server
	if multiplayer.is_server():
		%LevelOne.pressed.connect(_on_level_one_select.bind("level_one"))
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _input(event: InputEvent) -> void:
	if ManagerLevel.active_level_node: return
	if not ManagerMenu.active_menu_node == self: return
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			ManagerMenu.quit_to_main()

func _on_ready_status_changed(id, status) -> void:
	ready_statuses.set(id, {
		"status": status,
	})

func _on_level_one_select(level_basename: String) -> void:
	if not is_multiplayer_authority(): return
	
	if _check_all_ready():
		ManagerLevel.load_level.rpc(level_basename)
	else:
		print("Not all players are ready")

func _on_peer_disconnected(id: int) -> void:
	Helper.log(self, "Peer disconnected %s" % id)
	gui_remove_player_ready.rpc(id)

func _check_all_ready() -> bool:
	# Check if all are ready
	for id in ready_statuses:
		var status = ready_statuses[id]["status"]
		if status == false:
			return false
	return true

func _update_all_gui() -> void:
	for id in active_gui_nodes:
		var node = active_gui_nodes[id]
		node.set_display_name(ManagerPlayer.players[id])
		node.set_ready_status(ready_statuses[id]["status"])

@rpc("any_peer", "call_local", "reliable")
func gui_add_player_ready(id: int, display_name: String) -> void:
	if active_gui_nodes.has(id): return
	
	if not ready_statuses.has(id):
		ready_statuses.set(id, {
			"display_name": display_name,
			"status": false,
		})
	
	var gui_node = load("res://scenes/hud_lobby_player_status.tscn").instantiate()
	gui_node.name = str(id)
	gui_node.set_multiplayer_authority(id)
	gui_node.set_display_name(display_name)
	gui_node.set_ready_status(ready_statuses[id]["status"])
	
	%PlayerContainer.add_child(gui_node)
	gui_node.ready_status_changed.connect(_on_ready_status_changed)
	
	active_gui_nodes.set(id, gui_node)
	
	if multiplayer.is_server():
		for player in ManagerPlayer.players:
			gui_add_player_ready.rpc_id(id, player, ManagerPlayer.players[player]["display_name"])
		gui_add_player_ready.rpc(id, display_name)

@rpc("authority", "call_local", "reliable")
func gui_remove_player_ready(id: int) -> void:
	ready_statuses.erase(id)
	if %PlayerContainer.has_node(str(id)):
		%PlayerContainer.get_node(str(id)).call_deferred("queue_free")
