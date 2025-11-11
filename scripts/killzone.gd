extends Area3D

var eliminated: Array = []

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if multiplayer.is_server():
		eliminated.append(body)
