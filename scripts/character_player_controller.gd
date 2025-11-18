# Client authority
extends Node

@onready var body = get_parent() as RigidBody3D

var rpc_enabled: bool = false

var input_dir: Vector2 = Vector2.ZERO
var jumping: bool = false

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_jump()

func _ready() -> void:
	if multiplayer.is_server():
		pass
	else:
		toggle_rpc(true)
		toggle_rpc.rpc_id(1, true)

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

func _apply_movement() -> void:
	if input_dir == Vector2.ZERO: return
	var move_dir = Vector3(input_dir.x, 0, input_dir.y)
	body.apply_central_force(move_dir * body.move_speed * body.mass)

func _apply_jump() -> void:
	if jumping:
		body.linear_damp = 0
		body.apply_central_impulse(Vector3.UP * body.jump_impulse * body.mass)
		jumping = false

func _handle_jump() -> void:
	if multiplayer.is_server():
		_apply_jump()
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump") && body.is_on_floor():
			jumping = true
			server_receive_jump.rpc_id(1)

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
