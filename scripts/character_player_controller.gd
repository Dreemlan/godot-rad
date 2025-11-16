# Client authority
extends Node

@onready var body = get_parent() as RigidBody3D

var input_dir: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_jump()

func _handle_movement() -> void:
	if multiplayer.is_server():
		_apply_movement()
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()
		if not multiplayer.is_server():
			server_receive_move.rpc_id(1, input_dir)
		#_apply_movement()

func _apply_movement() -> void:
	var move_dir = Vector3(input_dir.x, 0, input_dir.y)
	body.apply_central_force(move_dir * body.move_speed * body.mass)

func _handle_jump() -> void:
	if multiplayer.is_server():
		pass
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("jump") && body.is_on_floor():
			body.apply_central_impulse(Vector3.UP * body.jump_impulse * body.mass)
			if not multiplayer.is_server():
				server_receive_jump.rpc_id(1)

@rpc("any_peer")
func server_receive_move(client_input: Vector2) -> void:
	input_dir = client_input

@rpc("any_peer")
func server_receive_jump() -> void:
	if body.is_on_floor():
		body.apply_central_impulse(Vector3.UP * body.jump_impulse * body.mass)
