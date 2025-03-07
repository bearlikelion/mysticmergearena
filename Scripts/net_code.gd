extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(piece: Match3Piece) -> void:
	print("Remove Piece: %s" % piece.name)
	piece.queue_free()
