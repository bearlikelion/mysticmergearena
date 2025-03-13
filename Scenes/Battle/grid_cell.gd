extends Match3GridCell


func _ready() -> void:
	super()


func _enter_tree() -> void:
	add_to_group(GroupName)
	name = "Cell_%s_%d_%d" % [get_multiplayer_authority(), column, row]


func remove_piece(_queued: bool = true) -> void:
	print("[%s] Remove Piece %s" % [multiplayer.get_unique_id(), piece.name])
	remove_piece_rpc.rpc(piece.get_path())


@rpc("any_peer", "call_local", "reliable")
func remove_piece_rpc(piece_path: NodePath) -> void:
	var piece_to_remove: Node = get_node(piece_path)
	if piece_to_remove and piece_to_remove.is_multiplayer_authority():
		piece_to_remove.queue_free()
	# else:
		# print("[%s] MISSING PIECE: %s" % [multiplayer.get_unique_id(), piece_path])
