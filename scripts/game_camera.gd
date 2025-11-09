extends Camera3D

@export var focus: Node

func _process(delta: float) -> void:
	global_position = global_position.lerp(
		focus.global_position + Vector3(0, 20, 20), delta * 2.0)
