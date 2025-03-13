extends Panel

@onready var match_battle: Node2D = %MatchBattle
@onready var victory: Label = $VBoxContainer/Victory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_battle.victory.connect(_on_victory)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _on_victory(is_winner: bool) -> void:
	get_tree().paused = true
	if not is_winner:
		victory.text = "DEFEAT"
	show()


func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
