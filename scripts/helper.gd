extends Node

const COLOR_SERVER := "#ffa500"   # bright red
const COLOR_CLIENT := "#55aaff"   # soft cyan


func log(caller: Object, msg: String) -> void:
	var prefix := _make_prefix()
	print_rich("%s[%s]: %s" % [
		prefix,
		caller,
		msg])

func _make_prefix() -> String:
	if multiplayer == null or not multiplayer.has_multiplayer_peer():
		return "[color=gray]OFFLINE[/color]"

	var peer := multiplayer.get_multiplayer_peer()
	if peer == null:
		return "[color=gray]NO PEER[/color]"

	var status := peer.get_connection_status()
	var id := 0

	match status:
		MultiplayerPeer.CONNECTION_CONNECTING:
			return "[color=%s]CLIENT[%s] (CONNECTING)[/color]" % [COLOR_CLIENT, id]
		MultiplayerPeer.CONNECTION_CONNECTED:
			id = multiplayer.get_unique_id()
			if id == 1:
				return "[color=%s]SERVER[%s][/color]" % [COLOR_SERVER, id]
			else:
				return "[color=%s]CLIENT[%s][/color]" % [COLOR_CLIENT, id]
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			# If we still have a valid unique_id, show it anyway
			return "[color=gray]CLIENT[%s] (DISCONNECTED)[/color]" % id
		_:
			return "[color=gray]UNKNOWN STATUS[/color]"
