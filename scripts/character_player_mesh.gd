extends Node3D

@onready var controller = get_parent() as Node3D

var follow_speed:float	= 10.0
var turn_speed: float	= 10.0

var pos_smooth_time : float = 0.03   # seconds
var rot_smooth_time : float = 0.06

var target_basis: Basis

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	_handle_position(delta)
	_handle_rotation_match_move_dir(delta * turn_speed)

func _handle_position(delta) -> void:
	var t: float = 1.0 - exp(-delta / pos_smooth_time)
	global_position = global_position.lerp(controller.global_position, t)

func _handle_rotation_match_move_dir(delta) -> void:
	if controller.move_dir == Vector3.ZERO: return
	target_basis = Basis.looking_at(controller.move_dir, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, delta)

func set_color(color: Color) -> void:
	Helper.log(self, "Setting color: %s" % color)
	var src_mat: StandardMaterial3D = %Body.material_override as StandardMaterial3D
	var uniq_mat: StandardMaterial3D

	if src_mat:
		uniq_mat = src_mat.duplicate() as StandardMaterial3D
	else:
		uniq_mat = StandardMaterial3D.new()
	
	%Body.material_override = uniq_mat
	uniq_mat.albedo_color = color
