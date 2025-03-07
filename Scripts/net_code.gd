extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(piece: Match3Piece) -> void:
	# piece.queue_free()
	print("Remove Piece: %s" % piece.name)
