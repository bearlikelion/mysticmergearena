extends Match3GridCell


func _ready() -> void:
	super()


func remove_piece(queued: bool = true) -> void:
	print("[%s] Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
	super(queued)
		#NetCode.remove_piece.rpc(queued, piece.name)
		#if has_piece():
			#if queued:
				#piece.queue_free()
			#else:
				#piece.free()

		#piece = null
