extends Node

const MATCH_BATTLE = preload("res://Scenes/Battle/match_battle.tscn")

@onready var level: Node = $Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.start_game.connect(_on_start_game)


func _on_start_game() -> void:
	for child: Node in level.get_children():
		level.remove_child(child)
		child.queue_free()

	level.add_child(MATCH_BATTLE.instantiate())
