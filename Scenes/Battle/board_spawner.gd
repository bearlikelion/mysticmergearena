extends MultiplayerSpawner

const MATCH_3_BOARD = preload("res://Scenes/Battle/match_3_board.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = spawn_board
	if multiplayer.is_server():
		call_deferred("spawn", 1)
		# multiplayer.peer_connected.connect(spawn_board)
		for peer_id: int in multiplayer.get_peers():
			# spawn(peer_id)
			var board = spawn(peer_id)
			await board.ready
			# board.set_multiplayer_authority(peer_id)
			#for board_piece: Node in board.get_children():
				#if board_piece.is_in_group("match3-pieces"):
					#board_piece.set_multiplayer_authority(peer_id)


func spawn_board(peer_id: int) -> Match3Board:
	var board: Match3Board = MATCH_3_BOARD.instantiate()
	board.set_multiplayer_authority(peer_id)
	board.name = str(peer_id)
	# board.lock()

	if peer_id == multiplayer.get_unique_id():
		board.position = Vector2(300, 460)
	else:
		board.position = Vector2(300, 60)

	return board
