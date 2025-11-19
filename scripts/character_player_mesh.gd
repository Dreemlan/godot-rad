extends Node3D

@onready var controller = get_parent() as Node3D

var controller_prev_transform_basis: Basis

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	#if not controller.is_multiplayer_authority(): return
	top_level = true

func _process(_delta: float) -> void:
	#if not controller.is_multiplayer_authority(): return
	var interp_frac = Engine.get_physics_interpolation_fraction()
	
	_handle_position(interp_frac)
	_handle_rotation(interp_frac)

func _physics_process(_delta: float) -> void:
	controller_prev_transform_basis = controller.global_transform.basis

func _handle_position(interp_frac) -> void:
	global_position = global_position.lerp(controller.global_position, interp_frac)

func _handle_rotation(interp_frac) -> void:
	if not controller_prev_transform_basis: return
	
	var q_prev = controller_prev_transform_basis.get_rotation_quaternion()
	var q_curr = controller.global_transform.basis.get_rotation_quaternion()
	var smooth_q = q_prev.slerp(q_curr, interp_frac).normalized()
	
	# Strip everything except yaw
	var euler = smooth_q.get_euler()
	var yaw_only_q = Quaternion.from_euler(Vector3(0, euler.y, 0))
	
	global_transform.basis = Basis(yaw_only_q)
