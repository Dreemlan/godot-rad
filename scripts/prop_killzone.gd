extends Area3D

var eliminated: Array = []

#signal all_eliminated

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if multiplayer.is_server():
		print("%s eliminated" % body)
		eliminated.append(body)
		# WIP handle node behavior
		body.freeze = true
