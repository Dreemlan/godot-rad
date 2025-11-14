extends Control

var gui_player_ready = []
var ready_statuses: Dictionary[int, bool] = {}

func _ready() -> void:
	Helper.log(self, "Ready")
	_ready_cleanup()
	
	setup_player.rpc_id(1,
		multiplayer.get_unique_id(),
		PlayerManager.players[multiplayer.get_unique_id()]["display_name"])
	
	%LevelOne.pressed.connect(_on_level_one_select.bind("level_one"))

func _input(event: InputEvent) -> void:
	if MenuManager.is_ingame: return
	if not MenuManager.active_menu_node == self: return
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			MenuManager.quit_to_main(self)

func _ready_cleanup() -> void:
	for child in %PlayerContainer.get_children():
		child.queue_free()

func _all_ready() -> bool:
	# Check if all are ready
	for rs in ready_statuses.values():
		if rs == false:
			return false
	return true

func _on_ready_status_changed(id, status) -> void:
	ready_statuses.set(id, status)

@rpc("any_peer", "call_local", "reliable")
func setup_player(id: int, display_name: String) -> void:
	if gui_player_ready.has(id): return
	var player_ready_status = load("res://scenes/hud_lobby_player_status.tscn").instantiate()
	player_ready_status.name = str(id)
	player_ready_status.set_multiplayer_authority(id)
	player_ready_status.set_display_name(display_name)
	gui_player_ready.append(id)
	ready_statuses.set(id, false)
	
	if LevelManager.level_in_progress:
		%Spectate.show()
	
	%PlayerContainer.add_child(player_ready_status)
	player_ready_status.ready_status_changed.connect(_on_ready_status_changed)
	
	if multiplayer.is_server():
		for player in PlayerManager.players:
			setup_player.rpc_id(id, player, PlayerManager.players[player]["display_name"])
		setup_player.rpc(id, display_name)
	
	Helper.log(self, "Added 'GUI Ready Status' for 'Player' %s to scene tree" % [id])

func remove_player(id: int) -> void:
	gui_player_ready.erase(id)
	%PlayerContainer.get_node(str(id)).call_deferred("queue_free")

func _on_level_one_select(level_basename: String) -> void:
	if not is_multiplayer_authority(): return
	
	if _all_ready():
		MenuManager.is_ingame = true
		LevelManager.load_level(level_basename)
		MenuManager.hide_active_menu.rpc()
	else:
		print("Not all players are ready")

@rpc("authority", "call_local", "reliable")
func hide_menu() -> void:
	hide()
