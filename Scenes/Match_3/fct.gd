extends Label

@onready var match_battle: Node2D = %MatchBattle


func _ready() -> void:
	# match_battle.dealt_damage.connect(_on_dealt_damage)
	hide()


func _on_dealt_damage(value: float) -> void:
	show()
	modulate = Color.WHITE
	text = str(value) + " dmg"
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(255, 0, 0, 0), 1.5)
