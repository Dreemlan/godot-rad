extends PanelContainer

var is_ready: bool = false

signal ready_status_changed(status: bool)

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	%ReadyButton.toggled.connect(_on_toggle)

func _input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if ManagerLevel.active_level_basename != "": return
	if not ManagerMenu.active_menu_path == ManagerMenu.LOBBY: return
	if Input.is_action_just_pressed("space"):
		%ReadyButton.button_pressed = not %ReadyButton.button_pressed
		%ReadyButton.toggled.emit(%ReadyButton.button_pressed)

func _on_toggle(toggled: bool) -> void:
	if not is_multiplayer_authority(): return
	update_ready_status.rpc_id(1, multiplayer.get_unique_id(), toggled)

func set_display_name(display_name: String) -> void:
	%DisplayName.text = display_name

func set_ready_status(status: bool) -> void:
	if status == true:
		%ReadyButton.text = "READY"
		%ReadyButton.modulate = Color.GREEN
	else:
		%ReadyButton.text = "NOT READY"
		%ReadyButton.modulate = Color.RED

@rpc("any_peer", "call_local", "reliable")
func update_ready_status(id: int, status: bool) -> void:
	if is_ready == status: return
	is_ready = status
	Helper.log(self, "Updating ready status %s" % status)
	
	set_display_name(ManagerPlayer.players[id]["display_name"])
	set_ready_status(status)
	
	if multiplayer.is_server():
		update_ready_status.rpc(id, status)
		ready_status_changed.emit(id, status)
