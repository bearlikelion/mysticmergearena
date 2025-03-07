extends Panel

@onready var match_battle: Node2D = %MatchBattle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	# match_battle.victory.connect(_on_victory)


func _on_victory(_turns_taken: int) -> void:
	show()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
