extends Match3GridCell


func _ready() -> void:
	super()


func _enter_tree() -> void:
	add_to_group(GroupName)
	name = "Cell_%s_%d_%d" % [get_multiplayer_authority(), column, row]


func remove_piece(queued: bool = true) -> void:
	print("[%s] Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
	NetCode.remove_piece.rpc(queued, piece.get_path())
	# super(queued)
		#if has_piece():
			#if queued:
				#piece.queue_free()
			#else:
				#piece.free()

		#piece = null
