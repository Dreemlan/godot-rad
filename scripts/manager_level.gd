extends Node

var level_in_progress: bool = false

func _ready() -> void:
	Helper.log(self, "Ready")

@rpc("authority", "call_local", "reliable")
func load_level(level_basename: String) -> void:
	if level_in_progress:
		print("Game is in progress")
		return
	var level_inst = load("res://scenes/%s.tscn" % level_basename).instantiate()
	add_child(level_inst)
	level_in_progress = true
	Helper.log(self, "Added level to scene tree")
