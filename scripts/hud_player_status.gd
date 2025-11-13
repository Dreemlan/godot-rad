extends PanelContainer

var is_ready: bool = false

signal ready_status_changed(status: bool)

func _ready() -> void:
	%ReadyButton.toggled.connect(_on_toggle)

func _input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("space"):
		%ReadyButton.button_pressed = not %ReadyButton.button_pressed
		%ReadyButton.toggled.emit(%ReadyButton.button_pressed)

func _on_toggle(toggled_on: bool) -> void:
	if not is_multiplayer_authority(): return
	set_ready_status.rpc_id(1,
		toggled_on,
		multiplayer.get_unique_id())

func set_display_name(display_name: String) -> void:
	%DisplayName.text = display_name

@rpc("any_peer", "call_local", "reliable")
func set_ready_status(status: bool, id: int) -> void:
	# Ignore if already set
	if is_ready == status: return
	
	# Update local variable
	is_ready = status
	
	var display_name = PlayerManager.players[id]["display_name"]
	set_display_name(display_name)
	
	# Update GUI
	if status == true:
		%ReadyButton.text = "READY"
		%ReadyButton.modulate = Color.GREEN
	else:
		%ReadyButton.text = "NOT READY"
		%ReadyButton.modulate = Color.RED
	
	# Server sends to clients and emits signal for processing
	if multiplayer.is_server():
		set_ready_status.rpc(status, id)
		ready_status_changed.emit(id, status)
