extends Match3GridCell


func _ready() -> void:
	super()


func remove_piece(queued: bool = true) -> void:
	print("[%s] Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
	queued = true
	if has_piece():
		if queued:
			if piece.is_multiplayer_authority():
				piece.queue_free()
		else:
			if piece.is_multiplayer_authority():
				piece.free()

	piece = null
