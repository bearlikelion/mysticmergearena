extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(queued: bool, piece_path: NodePath) -> void:
	var piece_to_remove: Node = get_node(piece_path)
	if piece_to_remove and piece_to_remove.is_multiplayer_authority():
		if queued:
			piece_to_remove.queue_free()
		else:
			piece_to_remove.free()
	else:
		print("[%s] MISSING PIECE: %s" % [multiplayer.get_unique_id(), piece_path])
