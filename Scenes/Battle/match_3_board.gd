extends Match3Board

signal dealt_damage(amount: float)
signal victory(turns_taken: int)

var damage: int = 0
var multiplier: float = 0.75
var total_damage: float = 0.0
var turns: int = 0
var chirp_pitch_scale: float = 1.0

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var board_pieces: Node2D = $BoardPieces

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_spawner.spawn_function = add_piece
	# multiplayer_spawner.spawn_path = get_path()
	super()
	if is_multiplayer_authority():
		consumed_sequence.connect(_on_consumed_sequence)
		unlocked.connect(_on_board_unlocked)


func add_piece(piece: Match3Piece) -> Match3Piece:
	piece.name = "%s_%s_%s" % [piece.id, multiplayer.get_unique_id(), randi_range(0, 10000)]
	piece.set_multiplayer_authority(multiplayer.get_unique_id())
	return piece


func draw_piece_on_cell(cell: Match3GridCell, piece: Match3Piece, replace: bool = false) -> void:
	if cell.can_contain_piece and (cell.is_empty() or replace):
		piece.cell = cell
		piece.position = cell.position

		#if replace and cell.has_piece():
			#cell.remove_piece()

		cell.piece = piece

		if not piece.is_inside_tree():
			if is_multiplayer_authority():
				multiplayer_spawner.spawn(piece)
			# board_pieces.add_child(piece, true)
			#add_child(piece, true)
			drawed_piece.emit(piece)


func _on_consumed_sequence(sequence: Match3Sequence) -> void:
	var _pieces = sequence.normal_pieces()
	if _pieces.size() > 0:
		print(_pieces[0].id)
	# multiplier += 0.25
	damage += _pieces.size()
	await get_tree().create_timer(0.15).timeout
	AudioManager.play("res://Assets/Audio/SFX/clear.ogg", chirp_pitch_scale)
	chirp_pitch_scale += 0.25


func _on_board_unlocked() -> void:
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
