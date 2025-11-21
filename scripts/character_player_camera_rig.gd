extends Node3D

@onready var controller = get_parent() as Node3D

var pos_smooth_time : float = 0.3

func _ready() -> void:
	top_level = true
	
	if controller.is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	_handle_position(delta)
	_handle_rotation(controller.global_basis)

func _handle_position(delta) -> void:
	var t: float = 1.0 - exp(-delta / pos_smooth_time)
	global_position = global_position.lerp(controller.global_position, t)

func _handle_rotation(prev_basis) -> void:
	var q_prev = prev_basis.get_rotation_quaternion()
	var q_curr = controller.global_transform.basis.get_rotation_quaternion()
	var smooth_q = q_prev.slerp(q_curr, Engine.get_physics_interpolation_fraction()).normalized()
	global_transform.basis = Basis(smooth_q)
