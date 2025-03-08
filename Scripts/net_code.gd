extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(queued: bool, piece_name: String):
	var piece_to_remove = get_tree().get_first_node_in_group(piece_name)
	queued = true
	if piece_to_remove:
		if queued:
			piece_to_remove.queue_free()
		else:
			piece_to_remove.free()

		return true
	else:
		print("[%s] MISSING PIECE: %s" % [multiplayer.get_unique_id(), piece_name])
		return false
