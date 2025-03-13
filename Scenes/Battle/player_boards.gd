extends Node

var ready_boards: int = 0
var boards_found: bool = false
var players: Dictionary[int, float] = {}

var host_board: Match3Board
var client_board: Match3Board

var host_id: int = 1
var client_id: int = -1
var damage: int = 0
var starting_hp: int = 100

@onready var match_battle: MatchBattle = %MatchBattle
@onready var your_healthbar: ProgressBar = %YourHealthbar
@onready var their_healthbar: ProgressBar = %TheirHealthbar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		players[1] = starting_hp
		for peer:int in multiplayer.get_peers():
			client_id = peer
			players[peer] = starting_hp

		print("[%s] Players: %s" % [multiplayer.get_unique_id(), players])
		set_player_health.rpc(players)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not boards_found:
		var boards = get_child_count()
		if boards == 2:
			boards_found = true
			boards_ready.rpc()
			# start_boards()


@rpc("authority", "call_local", "reliable")
func set_player_health(player_dict: Dictionary) -> void:
	if players != player_dict:
		players = player_dict
		print("[%s] Players: %s" % [multiplayer.get_unique_id(), players])

	var other_player: Array = players.keys()
	other_player.erase(multiplayer.get_unique_id())

	your_healthbar.name = str(multiplayer.get_unique_id())+"_hp"
	their_healthbar.name = str(other_player[0])+"_hp"
	your_healthbar.value = starting_hp
	your_healthbar.max_value = starting_hp
	their_healthbar.value = starting_hp
	their_healthbar.max_value = starting_hp


@rpc("any_peer", "call_local", "reliable")
func boards_ready() -> void:
	ready_boards += 1
	if ready_boards == 2:
		start_boards()


func start_boards() -> void:
	print("[%s] Start Boards" % multiplayer.get_unique_id())
	host_board = get_child(0)
	client_board = get_child(1)
#
	if host_board.is_multiplayer_authority():
		host_board.drawed_pieces.emit(host_board.pieces())
		host_board.unlocked.connect(_on_board_unlocked)
		host_board.consumed_sequence.connect(_on_consumed_sequence)
	if client_board.is_multiplayer_authority():
		client_board.drawed_pieces.emit(client_board.pieces())
		client_board.unlocked.connect(_on_board_unlocked)
		client_board.consumed_sequence.connect(_on_consumed_sequence)

	if multiplayer.is_server():
		who_goes_first()


func who_goes_first() -> void:
	var peer_ids: Array = players.keys()
	var first_turn: int = peer_ids.pick_random()
	print("[%s] Player %s goes first" % [multiplayer.get_unique_id(), first_turn])
	set_player_turn.rpc(first_turn)


@rpc("any_peer", "call_local", "reliable")
func set_player_turn(peer_id: int) -> void:
	print("[%s] Player's Turn: %s" % [multiplayer.get_unique_id(), peer_id])

	if peer_id == multiplayer.get_unique_id():
		match_battle.player_turn.emit("Your Turn")
	else:
		match_battle.player_turn.emit("Their Turn")

	var board: Match3Board = get_tree().get_first_node_in_group("board_" + str(peer_id))
	if board:
		print("[%s] Unlock Pieces: %s" % [multiplayer.get_unique_id(), peer_id])
		# board.unlock()
		board.unlock_all_pieces()

	var _players: Array = players.keys()
	_players.erase(peer_id)
	var other_board: Match3Board = get_tree().get_first_node_in_group("board_" + str(_players[0]))
	if other_board:
		print("[%s] Lock Pieces: %s" % [multiplayer.get_unique_id(), _players[0]])
		# other_board.lock()
		other_board.lock_all_pieces()


func _on_board_unlocked() -> void:
	if damage > 0:
		if multiplayer.is_server():
			send_player_damage.rpc(client_id, damage)
		else:
			send_player_damage.rpc(host_id, damage)

	if multiplayer.is_server():
		set_player_turn.rpc(client_id)
	else:
		set_player_turn.rpc(host_id)


@rpc("any_peer", "call_local", "reliable")
func send_player_damage(peer_id: int, damage_amount: int) -> void:
	print("[%s] Player %s took %s damage" % [multiplayer.get_unique_id(), peer_id, damage_amount])
	if peer_id == multiplayer.get_unique_id():
		your_healthbar.value -= damage_amount
		match_battle.their_damage.emit(damage_amount)
	else:
		their_healthbar.value -= damage_amount
		match_battle.your_damage.emit(damage_amount)

	if your_healthbar.value <= 0:
		print("[%s] DEFEATED" % multiplayer.get_unique_id())
		match_battle.victory.emit(false)

	if their_healthbar.value <= 0:
		print("[%s] VICTORY" % multiplayer.get_unique_id())
		match_battle.victory.emit(true)

	damage = 0


func _on_consumed_sequence(sequence: Match3Sequence) -> void:
	var _pieces = sequence.normal_pieces()
	damage += _pieces.size()
