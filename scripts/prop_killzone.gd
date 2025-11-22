extends Area3D

var eliminated: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	%AudioStreamPlayer3D.top_level = true

func _on_body_entered(body) -> void:
	%AudioStreamPlayer3D.global_position = body.global_position
	%AudioStreamPlayer3D.pitch_scale = randf_range(0.5, 1.5)
	%AudioStreamPlayer3D.playing = true
	
	if multiplayer.is_server():
		eliminated.append(int(body.name))
		
		body.linear_velocity = Vector3.ZERO
		body.global_position = Vector3(0, 10, 0)
