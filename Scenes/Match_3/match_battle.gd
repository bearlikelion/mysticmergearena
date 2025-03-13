extends Node2D

signal dealt_damage(amount: float)
signal victory(turns_taken: int)

var damage: int = 0
var chirp_pitch_scale: float = 1.0
var total_damage: float = 0.0
var turns: int = 0

@onready var match_3_board: Match3Board = %Match3Board
@onready var progress_bar: ProgressBar = %ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_3_board.consumed_sequence.connect(_on_consumed_sequence)
	match_3_board.unlocked.connect(_on_board_unlocked)


func _on_consumed_sequence(sequence: Match3Sequence) -> void:
	var _pieces = sequence.normal_pieces()
	if _pieces.size() > 0:
		print(_pieces[0].id)
	# multiplier += 0.25
	damage += _pieces.size()
	AudioManager.play("res://Assets/Audio/SFX/clear.ogg", chirp_pitch_scale)
	chirp_pitch_scale += 0.25


func _on_board_unlocked() -> void:
	chirp_pitch_scale = 1.0
	if damage > 0:
		turns += 1
		total_damage += damage
		print("Deal damage %s" % str(damage))
		progress_bar.value -= damage
		dealt_damage.emit(damage)
		print("Total Damage Dealt %s" % total_damage)
		damage = 0
		# multiplier = 0.75
		# print("Deal damage %s x %s = %s" % [str(damage), str(multiplier), str(damage * multiplier)])

	if total_damage >= 100:
		victory.emit(turns)
		hide()
