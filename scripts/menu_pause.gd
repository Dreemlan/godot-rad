extends Control

func _ready() -> void:
	%DebugPeerID.text = str(multiplayer.get_unique_id())
	#%Settings.pressed.connect(_on_settings_pressed)
	#%QuitToLobby.pressed.connect(_on_quit_to_lobby_pressed)
	%QuitToMain.pressed.connect(_on_quit_to_main_pressed)
	
	%MasterVolumeSlider.value_changed.connect(_on_master_vol_changed)
	%MouseSensSlider.value_changed.connect(_on_mouse_sens_changed)
	
	_on_master_vol_changed(%MasterVolumeSlider.value)
	_on_mouse_sens_changed(%MouseSensSlider.value)
	_toggle_mouse_mode()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			_toggle_mouse_mode()

func _toggle_mouse_mode() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_settings_pressed() -> void:
	pass

func _on_quit_to_lobby_pressed() -> void:
	if multiplayer.is_server():
		ManagerMenu.quit_to_lobby.rpc()

func _on_quit_to_main_pressed() -> void:
	ManagerMenu.quit_to_main()

func _on_master_vol_changed(value) -> void:
	var bus := AudioServer.get_bus_index("Master")
	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(bus, db)

func _on_mouse_sens_changed(value) -> void:
	ManagerConfig.mouse_look_sensitivity = value
