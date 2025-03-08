extends Match3Board

signal dealt_damage(amount: float)
signal victory(turns_taken: int)

var damage: int = 0
var multiplier: float = 0.75
var total_damage: float = 0.0
var turns: int = 0
var chirp_pitch_scale: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("board_" + str(multiplayer.get_unique_id()))
	add_pieces_to_generator(configuration.available_pieces)
	if is_multiplayer_authority():
		super()
		consumed_sequence.connect(_on_consumed_sequence)


func _on_consumed_sequence(sequence: Match3Sequence) -> void:
	var _pieces = sequence.normal_pieces()
	if _pieces.size() > 0:
		print(_pieces[0].id)
	# multiplier += 0.25
	damage += _pieces.size()
	# await get_tree().create_timer(0.15).timeout
	AudioManager.play("res://Assets/Audio/SFX/clear.ogg", chirp_pitch_scale)
	chirp_pitch_scale += 0.25


func on_drawed_pieces(_pieces: Array[Match3Piece]) -> void:
	if configuration.allow_matches_on_start:
		travel_to(BoardState.Consume)
	else:
		remove_matches_from_board()


func draw_cell(column: int, row: int) -> Match3GridCell:
	if grid_cells_flattened.any(func(cell: Match3GridCell): cell.in_same_grid_position_as(Vector2i(column, row))):
		return

	var cell: Match3GridCell =  configuration.grid_cell_scene.instantiate()
	cell.size = configuration.cell_size
	cell.column = column
	cell.row = row
	cell.position = Vector2(
		configuration.cell_size.x * cell.column, configuration.cell_size.y * cell.row
		) * cell.texture_scale

	cell.position.x += configuration.cell_offset.x * column
	cell.position.y += configuration.cell_offset.y * row
	# cell.set_multiplayer_authority(get_multiplayer_authority())

	if cell.board_position() in configuration.empty_cells:
		clear_cell(cell, true)

	add_child(cell, true)

	drawed_cell.emit(cell)

	return cell


func draw_piece_on_cell(cell: Match3GridCell, piece: Match3Piece, replace: bool = false) -> void:
	if cell.can_contain_piece and (cell.is_empty() or replace):
		piece.cell = cell
		piece.position = cell.position
		# piece.set_multiplayer_authority(get_multiplayer_authority())

		if replace and cell.has_piece():
			cell.remove_piece()

		cell.piece = piece

		if not piece.is_inside_tree():
			add_child(piece, true)
			drawed_piece.emit(piece)


func on_board_state_changed(from: BoardState, to: BoardState) -> void:
	print("[%s] FROM: %s TO: %s" % [multiplayer.get_unique_id(), from, to])
	match to:
		BoardState.WaitForInput:
			unlock()

		BoardState.Consume:
			lock()
			await consume_sequences(sequence_detector.find_board_sequences())

		BoardState.SpecialConsume:
			lock()
			if pending_special_pieces.is_empty():
				travel_to(BoardState.Fall)
			else:
				consume_special_pieces(pending_special_pieces)

		BoardState.Fall:
			lock()
			await fall_pieces()
			await get_tree().process_frame

			travel_to(BoardState.Fill)

		BoardState.Fill:
			lock()
			await fill_pieces()
			await get_tree().process_frame

			if sequence_detector.find_board_sequences().is_empty():
				travel_to(BoardState.WaitForInput)
			else:
				travel_to(BoardState.Consume)


func on_board_unlocked() -> void:
	super()

	chirp_pitch_scale = 1.0
	if damage > 0:
		turns += 1
		total_damage += damage
		print("Deal damage %s" % str(damage))
		dealt_damage.emit(damage)
		print("Total Damage Dealt %s" % total_damage)
		damage = 0
		# multiplier = 0.75
		# print("Deal damage %s x %s = %s" % [str(damage), str(multiplier), str(damage * multiplier)])

	if total_damage >= 100:
		victory.emit(turns)
		hide()
