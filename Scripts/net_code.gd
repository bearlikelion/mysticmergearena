extends Node


@rpc("any_peer", "call_local", "reliable")
func remove_piece(queued: bool, piece_path: NodePath) -> void:
	var piece_to_remove: Node = get_node(piece_path)
	if piece_to_remove:
		if queued:
			piece_to_remove.queue_free()
		else:
			piece_to_remove.free()
	else:
		print("[%s] MISSING PIECE: %s" % [multiplayer.get_unique_id(), piece_path])
		# remove_other_piece.rpc(queued, piece_name)


@rpc("any_peer", "call_remote", "reliable")
func add_piece(piece: Match3Piece) -> void:
	print("[%s] Add Piece Sender: %s" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id()])
	var board = get_tree().get_first_node_in_group("board_" + str(multiplayer.get_remote_sender_id()))
	if board:
		board.add_child(piece)


@rpc("any_peer", "call_remote", "reliable")
func send_board(player_board: Match3Board) -> void:
	print("Board Children: %s" % player_board.get_child_count())
