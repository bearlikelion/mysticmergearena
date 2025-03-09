class_name BoardSpawner
extends MultiplayerSpawner

const MATCH_3_BOARD = preload("res://Scenes/Battle/match_3_board.tscn")

@onready var player_boards: Node = $"../MatchBattle/PlayerBoards"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = spawn_board
	if multiplayer.is_server():
		spawn(1) # Spawn Host Board
		for peer_id: int in multiplayer.get_peers():
			spawn(peer_id) # Spawn Client Board
			# var client_board: Match3Board = spawn(peer_id)
			# client_board.set_multiplayer_authority(peer_id, true)


func spawn_board(peer_id: int) -> Match3Board:
	print("[%s] Spawn Board for %s" % [multiplayer.get_unique_id(), peer_id])
	var board: Match3Board = MATCH_3_BOARD.instantiate()
	board.add_to_group("board_" + str(multiplayer.get_unique_id()))
	board.set_multiplayer_authority(peer_id)
	board.name = str(peer_id)
	# board.lock()

	if peer_id == multiplayer.get_unique_id():
		board.position = Vector2(300, 460) # Place on bottom
	else:
		board.position = Vector2(300, 60) # Place on top

	return board
