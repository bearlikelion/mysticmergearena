extends Label

@onready var match_battle: Node2D = %MatchBattle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# match_battle.victory.connect(_on_victory)
	pass


func _on_victory(turns_taken: int) -> void:
	text = "Turns Taken: %s" % str(turns_taken)
