extends Control

var players_ready: int = 0

@onready var refresh_games: Button = $ButtonsVbox/RefreshGames
@onready var create_game: Button = $ButtonsVbox/CreateGame
@onready var ready_button: Button = $ButtonsVbox/ReadyButton
@onready var lobby_scroll_container: ScrollContainer = $MarginContainer/LobbyScrollContainer
@onready var lobby_versus: HBoxContainer = $MarginContainer/LobbyVersus
@onready var lobby_vbox: VBoxContainer = $MarginContainer/LobbyScrollContainer/LobbyVbox
@onready var player_1_name: Label = $MarginContainer/LobbyVersus/Player1/Player1Name
@onready var player_2_name: Label = $MarginContainer/LobbyVersus/Player2/Player2Name
@onready var dragon_button: Button = $ButtonsVbox/DragonButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.session_established.connect(_on_session_established)
	multiplayer.peer_connected.connect(_on_peer_connected)
	set_player_names()


func show_match() -> void:
	lobby_scroll_container.hide()
	dragon_button.hide()
	refresh_games.hide()
	create_game.hide()

	lobby_versus.show()
	ready_button.show()


func set_player_names() -> void:
	if Global.players.size() == 0:
		player_1_name.text = ""
		player_2_name.text = ""
	elif Global.players.size() == 1:
		player_1_name.text = str(Global.players.keys()[0])
	elif Global.players.size() == 2:
		player_1_name.text = str(Global.players.keys()[0])
		player_2_name.text = str(Global.players.keys()[1])


func refresh_lobbies() -> void:
	var min_players = 1
	var max_players = 2
	var limit = 2
	var authoritative = false
	var label = ""
	var query = ""
	var result: NakamaAPI.ApiMatchList = await Global.client.list_matches_async(Global.session,
		min_players,
		max_players,
		limit,
		authoritative,
		label,
		query
	)

	for lobby_button: Node in lobby_vbox.get_children():
		if lobby_button is Button:
			lobby_button.queue_free()

	for m in result.matches:
		var lobby_button: Button = Button.new()
		lobby_button.text = m.match_id
		lobby_button.pressed.connect(_on_lobby_button_pressed.bind(m.match_id))
		lobby_vbox.add_child(lobby_button)
		# print("%s: %s/2 players" % [m.match_id, m.size])


func _on_create_game_pressed() -> void:
	Global.multiplayer_bridge.create_match()


func _on_peer_connected(peer_id: int) -> void:
	print("Peer Connected %s" % peer_id)
	Global.players.get_or_add(peer_id)
	set_player_names()

	if Global.players.size() == 2:
		ready_button.disabled = false


func _on_connected_to_server() -> void:
	Global.players.get_or_add(multiplayer.get_unique_id())
	set_player_names()
	show_match()

func _on_refresh_games_pressed() -> void:
	refresh_lobbies()


func _on_session_established() -> void:
	Global.multiplayer_bridge.match_joined.connect(_on_connected_to_server)

	refresh_games.disabled = false
	create_game.disabled = false
	lobby_scroll_container.show()
	refresh_lobbies()


func _on_lobby_button_pressed(match_id: String) -> void:
	Global.multiplayer_bridge.join_match(match_id)


func _on_dragon_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Match_3/match_battle.tscn")


func _on_ready_button_toggled(toggled_on: bool) -> void:
	ready_button.disabled = true
	ready_up.rpc(toggled_on)


@rpc("any_peer", "call_local","reliable")
func ready_up(is_ready: bool) -> void:
	if is_ready:
		players_ready += 1

	if players_ready == 2:
		print("START GAME")
		Global.start_game.emit()
