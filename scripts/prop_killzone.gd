extends Area3D

var eliminated: Array = []

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if multiplayer.is_server():
		print("%s eliminated" % body)
		eliminated.append(body)
		# WIP handle node behavior
		body.global_position = Vector3(0, 5, 0)
		body.linear_velocity = Vector3.ZERO
