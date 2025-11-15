extends Camera3D

@export var focus: Node

func _ready() -> void:
	Helper.log(self, "Added to scene tree")
	#await get_tree().process_frame
	#focus = PlayerManager.get_node(str(multiplayer.get_unique_id()))

func _process(delta: float) -> void:
	if focus == null: return
	
	global_position = global_position.lerp(
		focus.global_position + Vector3(0, 20, 20), delta * 2.0)
