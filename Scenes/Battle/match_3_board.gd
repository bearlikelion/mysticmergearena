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
	super()
	add_to_group("board_" + str(multiplayer.get_unique_id()))
	if is_multiplayer_authority():
		# consumed_sequence.connect(_on_consumed_sequence)
		# unlocked.connect(_on_board_unlocked)
		position = Vector2(300, 460) # Place on bottom
	else:
		position = Vector2(300, 60) # Place on top


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
