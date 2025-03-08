extends MultiplayerSpawner

const MATCH_3_BOARD = preload("res://Scenes/Battle/match_3_board.tscn")

@onready var player_boards: Node = $"../MatchBattle/PlayerBoards"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.allow_object_decoding = true
	spawn_function = spawn_board
	if multiplayer.is_server():
		spawn(1) # Spawn Host Board
		for peer_id: int in multiplayer.get_peers():
			spawn(peer_id) # Spawn Client Board


func spawn_board(peer_id: int) -> Match3Board:
	var board: Match3Board = MATCH_3_BOARD.instantiate()
	board.set_multiplayer_authority(peer_id)
	board.name = str(peer_id)
	# board.lock()

	return board


@rpc("authority", "call_remote", "reliable")
func send_client_boards(host_board: Match3Board, client_board: Match3Board) -> void:
	print(host_board)
	print(client_board)
