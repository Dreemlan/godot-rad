# Client authority
# Client controls their own camera and input, movement is derived from that then sent to server
extends Node3D

@onready var body = get_parent() as RigidBody3D

# Look
var mouse_look_delta: Vector2 = Vector2.ZERO
var twist_input: float 			= 0.0
var pitch_input: float			= 0.0

# Movement
var input_dir: Vector2 = Vector2.ZERO
var move_dir: Vector3 = Vector3.ZERO
var jumping: bool = false

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	if not is_multiplayer_authority():
		%Camera3D.current = false
	else:
		%Camera3D.current = true

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_authority_movement(delta)

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_jump()

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				mouse_look_delta += event.relative

func _authority_movement(delta) -> void:
	_apply_camera_mouse(delta)
	_apply_camera_joypad(delta)
	
	input_dir = Focus.input_get_vector("left", "right", "up", "down").normalized()
	var right_3d = basis.x
	var forward_3d = basis.z
	var right_2d = Vector2(right_3d.x, right_3d.z).normalized()
	var forward_2d = Vector2(forward_3d.x, forward_3d.z).normalized()
	var move_dir_2d = right_2d * input_dir.x + forward_2d * input_dir.y
	move_dir = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
	
	mouse_look_delta = Vector2.ZERO

func _handle_movement() -> void:
	if multiplayer.is_server():
		_apply_movement()
		if not body.rpc_enabled: return
		for p in ManagerPlayer.fully_loaded_players:
			client_receive_move_dir.rpc_id(p, move_dir)
	if is_multiplayer_authority():
		if not multiplayer.is_server():
			server_receive_move.rpc_id(1, move_dir)
			#server_receive_controller_basis.rpc_id(1, basis)

func _handle_jump() -> void:
	if multiplayer.is_server():
		_apply_jump()
	if is_multiplayer_authority():
		if Focus.input_is_action_just_pressed("jump") && body.is_on_floor():
			jumping = true
			_apply_jump()
			if not multiplayer.is_server():
				server_recieve_jump.rpc_id(1)

func _apply_camera_mouse(delta: float) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	if not is_multiplayer_authority(): return
	twist_input -= mouse_look_delta.x * ManagerConfig.mouse_look_sensitivity * delta
	pitch_input -= mouse_look_delta.y * ManagerConfig.mouse_look_sensitivity * delta
	pitch_input = clamp(pitch_input, -85, 85)
	basis = _quat_rotate(twist_input, pitch_input)

func _apply_camera_joypad(delta: float) -> void:
	if not is_multiplayer_authority(): return
	twist_input -= Focus.input_get_axis("look_left", "look_right") * ManagerConfig.joypad_look_sensitivity * delta
	pitch_input -= Focus.input_get_axis("look_up", "look_down") * ManagerConfig.joypad_look_sensitivity * delta
	pitch_input = clamp(pitch_input, -85, 85)
	basis = _quat_rotate(twist_input, pitch_input)

func _apply_movement() -> void:
	if not body.is_on_floor(): return
	body.apply_central_force(move_dir * body.move_speed * body.mass)

func _apply_jump() -> void:
	if jumping:
		body.linear_damp = 0
		body.apply_central_impulse(Vector3.UP * body.jump_impulse * body.mass)
		jumping = false

func _toggle_mouse_mode() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _quat_rotate(twist, pitch) -> Basis:
	var twist_quat = Quaternion(Vector3.UP, deg_to_rad(twist))
	var pitch_quat = Quaternion(Vector3.RIGHT, deg_to_rad(pitch))
	return Basis(twist_quat * pitch_quat)

@rpc("any_peer", "call_local", "unreliable")
func server_receive_move(client_state) -> void:
	move_dir = client_state

@rpc("any_peer")
func client_receive_move_dir(server_move_dir) -> void:
	move_dir = server_move_dir

@rpc("authority")
func server_recieve_jump() -> void:
	jumping = true
