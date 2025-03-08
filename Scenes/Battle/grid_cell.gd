extends Match3GridCell


func _ready() -> void:
	super()


func remove_piece(queued: bool = false) -> void:
	if has_piece():
		# print("[%s] Battle/grid_cell: Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
		NetCode.remove_piece.rpc(queued, piece)
		# if queued:
			# piece.queue_free()
		# else:
			# piece.free()

	piece = null
