extends Node

var ready_boards: int = 0
var boards_found: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not boards_found:
		var boards = get_child_count()
		if boards == 2:
			boards_found = true
			boards_ready.rpc()
			# start_boards()


@rpc("any_peer", "call_local", "reliable")
func boards_ready() -> void:
	ready_boards += 1
	if ready_boards == 2:
		start_boards()


func start_boards() -> void:
	print("[%s] Start Boards" % multiplayer.get_unique_id())
	var host_board: Match3Board = get_child(0)
	var client_board: Match3Board = get_child(1)
#
	if host_board.is_multiplayer_authority():
		host_board.drawed_pieces.emit(host_board.pieces())
		#await host_board.draw_cells()
	if client_board.is_multiplayer_authority():
		client_board.drawed_pieces.emit(client_board.pieces())
		#await client_board.draw_cells()
	# await host_board.draw_pieces()
	# await client_board.draw_pieces()

	#var host_peer: int = int(host_board.name)
	#for host_child: Node in host_board.get_children():
		#host_child.set_multiplayer_authority(host_peer, true)
##
	#var client_peer: int = int(client_board.name)
	#for client_child: Node in client_board.get_children():
		#client_child.set_multiplayer_authority(client_peer, true)
