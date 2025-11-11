extends Node

var scores: Dictionary[int, int] = {} # Store score per player

func add_player_score(id: int) -> void:
	if scores.has(id): return
	scores.set(id, 0)

func remove_player_score(id: int) -> void:
	if not scores.has(id): return
	scores.erase(id)
