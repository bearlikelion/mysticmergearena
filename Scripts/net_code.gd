extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(queued: bool, piece: Match3Piece) -> void:
	# print("Remove Piece: %s" % piece.name)
	if queued:
		piece.queue_free()
	else:
		piece.free()
