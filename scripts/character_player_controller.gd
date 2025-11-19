# Client authority
extends Node3D

@onready var body = get_parent() as RigidBody3D

var rpc_enabled: bool = false

# Camera
var mouse_sensitivity: float	= 0.1
var twist_input: float 			= 0.0
var pitch_input: float			= 0.0

# Movement
var camera_dir: Vector3 = Vector3.ZERO
var input_dir: Vector2 = Vector2.ZERO
var jumping: bool = false

func _ready() -> void:
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if multiplayer.is_server():
		pass
	else:
		toggle_rpc(true)
		toggle_rpc.rpc_id(1, true)

func _physics_process(_delta: float) -> void:
	_handle_camera()
	_handle_movement()
	_handle_jump()
	
	for p in ManagerPlayer.fully_loaded_players:
		pass

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				_apply_camera(event)
				camera_dir = -basis.z.normalized()

func _handle_movement() -> void:
	if multiplayer.is_server():
		_apply_movement()
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()
		if not multiplayer.is_server():
			if not rpc_enabled: return
			server_receive_move.rpc_id(1, input_dir)
		# Client-side prediction
		#_apply_movement()

func _handle_jump() -> void:
	if multiplayer.is_server():
		_apply_jump()
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump") && body.is_on_floor():
			jumping = true
			server_receive_jump.rpc_id(1)

func _handle_camera() -> void:
	if not rpc_enabled: return
	server_receive_camera_basis.rpc_id(1, basis)

func _apply_camera(event: InputEventMouseMotion) -> void:
	twist_input -= event.relative.x * mouse_sensitivity
	pitch_input -= event.relative.y * mouse_sensitivity
	pitch_input = clamp(pitch_input, -85, 85)
	basis = _quat_rotate(twist_input, pitch_input)

func _apply_movement() -> void:
	if input_dir == Vector2.ZERO: return
	var move_dir = basis * Vector3(input_dir.x, 0, input_dir.y)
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

@rpc("any_peer", "call_remote", "reliable")
func toggle_rpc(state: bool) -> void:
	rpc_enabled = state

@rpc("any_peer", "call_local", "reliable")
func queue_deletion() -> void:
	Helper.log(self, "Queued for deletion")
	toggle_rpc(false)
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")

@rpc("any_peer")
func server_receive_move(client_input: Vector2) -> void:
	input_dir = client_input

@rpc("any_peer", "call_local")
func server_receive_jump() -> void:
	if body.is_on_floor():
		jumping = true
		_apply_jump()

@rpc("authority", "call_local", "unreliable")
func server_receive_camera_basis(target_basis: Basis) -> void:
	basis = target_basis
