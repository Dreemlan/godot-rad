# Client authority
extends Node3D

@onready var body = get_parent() as RigidBody3D

var rpc_enabled: bool = false

# Look
var joypad_look_sensitivity = 200.0
var mouse_look_sensitivity = 3.0
var mouse_look_delta: Vector2 = Vector2.ZERO
var twist_input: float 			= 0.0
var pitch_input: float			= 0.0

# Movement
var move_dir_2d: Vector2 = Vector2.ZERO
var move_dir_3d: Vector3 = Vector3.ZERO
var look_dir: Vector3 = Vector3.ZERO
var input_dir: Vector2 = Vector2.ZERO
var jumping: bool = false

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		toggle_rpc(true)
		toggle_rpc.rpc_id(1, true)

func _process(delta: float) -> void:
	_apply_camera_mouse(delta)
	_apply_camera_joypad(delta)
	mouse_look_delta = Vector2.ZERO
	look_dir = -basis.z.normalized()
	
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_jump()

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				mouse_look_delta += event.relative
		#elif event is InputEventKey:
			#_toggle_mouse_mode()

func _handle_movement() -> void:
	# Server applies movement regardless of authority
	# Derived from input_dir which clients send
	if multiplayer.is_server():
		_apply_movement()
	if is_multiplayer_authority():
		pass
		#if not multiplayer.is_server():
			#if not rpc_enabled: return
			#server_receive_move.rpc_id(1, input_dir)

func _handle_jump() -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump") && body.is_on_floor():
			jumping = true
			_apply_jump()

func _apply_camera_mouse(delta: float) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	twist_input -= mouse_look_delta.x * mouse_look_sensitivity * delta
	pitch_input -= mouse_look_delta.y * mouse_look_sensitivity * delta
	pitch_input = clamp(pitch_input, -85, 85)
	basis = _quat_rotate(twist_input, pitch_input)

func _apply_camera_joypad(delta: float) -> void:
	twist_input -= Input.get_axis("look_left", "look_right") * joypad_look_sensitivity * delta
	pitch_input -= Input.get_axis("look_up", "look_down") * joypad_look_sensitivity * delta
	pitch_input = clamp(pitch_input, -85, 85)
	basis = _quat_rotate(twist_input, pitch_input)

func _apply_movement() -> void:
	if input_dir == Vector2.ZERO: return
	var right_3d = basis.x
	var forward_3d = basis.z
	var right_2d = Vector2(right_3d.x, right_3d.z).normalized()
	var forward_2d = Vector2(forward_3d.x, forward_3d.z).normalized()
	move_dir_2d = right_2d * input_dir.x + forward_2d * input_dir.y
	move_dir_3d = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
	if not body.is_on_floor(): return
	body.apply_central_force(move_dir_3d * body.move_speed * body.mass)

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
