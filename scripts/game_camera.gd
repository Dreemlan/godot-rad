extends Camera3D

@export var focus: Node

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	ManagerLevel.active_level_camera = self

func _process(delta: float) -> void:
	if focus == null: return
	
	global_position = global_position.lerp(
		focus.global_position + Vector3(0, 10, 10), delta * 2.0)
