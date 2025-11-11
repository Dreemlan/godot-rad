extends PanelContainer

var is_ready: bool = false

func _ready() -> void:
	%ReadyButton.toggled.connect(_on_toggle)

func _on_toggle(toggled_on: bool) -> void:
	if not is_multiplayer_authority(): return
	set_ready_status.rpc_id(1,
		toggled_on,
		PlayerManager.players[multiplayer.get_unique_id()]["display_name"])

func set_display_name(display_name: String) -> void:
	%DisplayName.text = display_name

@rpc("any_peer", "call_local", "reliable")
func set_ready_status(status: bool, display_name: String) -> void:
	# Ignore if already set
	if is_ready == status: return
	
	# Update local variable
	is_ready = status
	
	set_display_name(display_name)
	
	# Update GUI
	if status == true:
		%ReadyButton.text = "READY"
		%ReadyButton.modulate = Color.GREEN
	else:
		%ReadyButton.text = "NOT READY"
		%ReadyButton.modulate = Color.RED
	
	# Server sends to clients
	if multiplayer.is_server():
		set_ready_status.rpc(status, display_name)
