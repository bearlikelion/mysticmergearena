extends Label

@onready var match_battle: Node2D = %MatchBattle


func _ready() -> void:
	# match_battle.dealt_damage.connect(_on_dealt_damage)
	match_battle.player_turn.connect(_on_player_turn)
	hide()


func _on_dealt_damage(value: float) -> void:
	show()
	modulate = Color.WHITE
	text = str(value) + " dmg"
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(255, 0, 0, 0), 2.0)


func _on_player_turn(turn_text: String) -> void:
	show()
	modulate = Color.WHITE
	text = turn_text
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(255, 0, 0, 0), 2.0)
