extends Match3Board

signal dealt_damage(amount: float)
signal victory(turns_taken: int)

var damage: int = 0
var multiplier: float = 0.75
var total_damage: float = 0.0
var turns: int = 0
var chirp_pitch_scale: float = 1.0

@onready var cell_spawner: MultiplayerSpawner = $CellSpawner
@onready var piece_spawner: MultiplayerSpawner = $PieceSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell_spawner.spawn_function = spawn_grid
	piece_spawner.spawn_function = spawn_piece
	if is_multiplayer_authority():
		super()
		consumed_sequence.connect(_on_consumed_sequence)
		await draw_cells()
		await draw_pieces()


func spawn_grid(grid_array: Array) -> Match3GridCell:
	var column = grid_array[0]
	var row = grid_array[1]
	if grid_cells_flattened.any(func(spawned_cell: Match3GridCell): spawned_cell.in_same_grid_position_as(Vector2i(column, row))):
		return

	var cell: Match3GridCell =  configuration.grid_cell_scene.instantiate()
	cell.set_multiplayer_authority(get_multiplayer_authority())
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


func spawn_piece(piece_array: Array) -> Match3Piece:
	var cell = get_node(piece_array[0])
	var piece_configuration: Match3PieceConfiguration = load(piece_array[1])
	var piece: Match3Piece = Match3Piece.from_configuration(piece_configuration)
	piece.set_multiplayer_authority(get_multiplayer_authority())
	piece.cell = cell
	piece.position = cell.position
	cell.piece = piece

	return piece


func draw_random_piece_on_cell(cell: Match3GridCell, _replace: bool = false) -> Match3Piece:
	var piece_configuration: Match3PieceConfiguration = piece_generator.roll()
	# draw_piece_on_cell(cell, piece, replace)
	var spawned_piece = piece_spawner.spawn([cell.get_path(), piece_configuration.resource_path])
	drawed_piece.emit(spawned_piece)
	return spawned_piece


func _on_consumed_sequence(sequence: Match3Sequence) -> void:
	var _pieces = sequence.normal_pieces()
	if _pieces.size() > 0:
		print(_pieces[0].id)
	# multiplier += 0.25
	damage += _pieces.size()
	# await get_tree().create_timer(0.15).timeout
	AudioManager.play("res://Assets/Audio/SFX/clear.ogg", chirp_pitch_scale)
	chirp_pitch_scale += 0.25


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


func on_drawed_pieces(_pieces: Array[Match3Piece]) -> void:
	if configuration.allow_matches_on_start:
		travel_to(BoardState.Consume)
	else:
		remove_matches_from_board()


func remove_matches_from_board() -> void:
	if not is_multiplayer_authority():
		return

	var sequences: Array[Match3Sequence] = sequence_detector.find_board_sequences()

	while sequences.size() > 0:
		for sequence: Match3Sequence in sequences:
			@warning_ignore("integer_division")
			var cells_to_change = sequence.cells.slice(0, (sequence.cells.size() / configuration.min_match) + 1)
			var piece_exceptions: Array[Match3PieceConfiguration] = []

			piece_exceptions.assign(Match3BoardPluginUtilities.remove_duplicates(
				cells_to_change.map(
					func(cell: Match3GridCell):
						return configuration.available_pieces.filter(
							func(piece_conf: Match3PieceConfiguration): return cell.piece.id == piece_conf.id).front()
							)
					)
				)

			for current_cell: Match3GridCell in cells_to_change:
				current_cell.remove_piece()
				var new_piece_configuration: Match3PieceConfiguration = piece_generator.roll(piece_exceptions)
				piece_spawner.spawn([current_cell.get_path(), new_piece_configuration.resource_path])

		sequences = sequence_detector.find_board_sequences()
