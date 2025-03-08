extends Match3GridCell


func _ready() -> void:
	super()


func remove_piece(queued: bool = true) -> void:
	if piece:
		print("[%s] Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
		NetCode.remove_piece.rpc(queued, piece.name)
		#if has_piece():
			#if queued:
				#piece.queue_free()
			#else:
				#piece.free()

		piece = null
