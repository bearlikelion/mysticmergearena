extends Match3Board

signal dealt_damage(amount: float)
signal victory(turns_taken: int)

var damage: int = 0
var multiplier: float = 0.75
var total_damage: float = 0.0
var turns: int = 0
var chirp_pitch_scale: float = 1.0

@onready var cell_spawner: MultiplayerSpawner = $CellSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell_spawner.spawn_function = spawn_grid
	super()
	consumed_sequence.connect(_on_consumed_sequence)


func spawn_grid(grid_array: Array) -> Match3GridCell:
	var column = grid_array[0]
	var row = grid_array[1]
	if grid_cells_flattened.any(func(cell: Match3GridCell): cell.in_same_grid_position_as(Vector2i(column, row))):
		return

	var cell: Match3GridCell =  configuration.grid_cell_scene.instantiate()
	# cell.set_multiplayer_authority(get_multiplayer_authority())
	cell.size = configuration.cell_size
	cell.column = column
	cell.row = row
	cell.position = Vector2(
		configuration.cell_size.x * cell.column, configuration.cell_size.y * cell.row
		) * cell.texture_scale

	cell.position.x += configuration.cell_offset.x * column
	cell.position.y += configuration.cell_offset.y * row

	if cell.board_position() in configuration.empty_cells:
		clear_cell(cell, true)

	# add_child(cell)

	drawed_cell.emit(cell)
	return cell


func draw_cells() -> Match3Board:
	if grid_cells.is_empty():
		for column in configuration.grid_width:
			grid_cells.append([])

			for row in configuration.grid_height:
				# grid_cells[column].append(draw_cell(column, row))
				grid_cells[column].append(cell_spawner.spawn([column, row]))

		grid_cells_flattened.append_array(Match3BoardPluginUtilities.flatten(grid_cells))
		_update_grid_cells_neighbours(grid_cells_flattened)


		if animator:
			if configuration.draw_cells_and_pieces_animation_is_serial():
				await animator.run(Match3Animator.DrawCellsAnimation, [grid_cells_flattened])
			elif configuration.draw_cells_and_pieces_animation_is_parallel():
				animator.run(Match3Animator.DrawCellsAnimation, [grid_cells_flattened])

		drawed_cells.emit(grid_cells_flattened)

	return self


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


func draw_piece_on_cell(cell: Match3GridCell, piece: Match3Piece, replace: bool = false) -> void:
	if cell.can_contain_piece and (cell.is_empty() or replace):
		piece.cell = cell
		piece.position = cell.position

		if replace and cell.has_piece():
			cell.remove_piece()

		cell.piece = piece

		if not piece.is_inside_tree():
			add_child(piece)
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


func draw_pieces() -> Match3Board:
	assert(configuration.available_pieces.size() > 0, "Match3Board: No available pieces are set for this board, the pieces cannot be drawed")

	for cell: Match3GridCell in grid_cells_flattened:
		draw_random_piece_on_cell(cell)

	lock_all_pieces()
#
	if animator:
		if configuration.draw_cells_and_pieces_animation_is_serial():
			await animator.run(Match3Animator.DrawPiecesAnimation, [pieces()])
		elif configuration.draw_cells_and_pieces_animation_is_parallel():
			animator.run(Match3Animator.DrawPiecesAnimation, [pieces()])

	unlock_all_pieces()
	# drawed_pieces.emit(pieces())

	return self
