extends Node

const uuid_util = preload('res://addons/uuid/uuid.gd')

signal start_game

var client: NakamaClient
var socket: NakamaSocket
var session: NakamaSession
var device_id: String = OS.get_unique_id()
var match_id: String = ""
var multiplayer_bridge: NakamaMultiplayerBridge

var players = {}

var _instance_socket: TCPServer = TCPServer.new()
var _instance_num: int = -1

func _init() -> void:
	if OS.is_debug_build():
		for n in range(0,4):
			if _instance_socket.listen(5000 + n) == OK:
				_instance_num = n
				device_id = device_id + "_" + str(_instance_num)
				break


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().title = "AutoBattler Session: %s" % _instance_num

	if OS.has_feature("web"):
		device_id = uuid_util.v4()

	print("Device ID: %s" % device_id)
	client = Nakama.create_client("m4rkS0cketK3y",
		"nakama.prod.arneman.me",
		443,
		"https",
		10,
		NakamaLogger.LOG_LEVEL.WARNING # NakamaLogger.LOG_LEVEL.DEBUG
	)

	session = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred: %s" % session)
		return

	# print("Successfully authenticated: %s" % session)

	socket = Nakama.create_socket_from(client)
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	# print("Socket connected.")

	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	# multiplayer_bridge.match_joined.connect(_on_connected_to_server)
	# multiplayer.connected_to_server.connect(_on_connected_to_server)
	# multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.multiplayer_peer = multiplayer_bridge.multiplayer_peer
	Events.session_established.emit()


#func _on_connected_to_server() -> void:
	#print("Conected to server")
#
#
#func _on_peer_connected(peer_id: int) -> void:
	#print("Peer %s connected" % peer_id)
