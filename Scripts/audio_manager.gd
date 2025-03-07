extends Node

enum Pitch {UP, DOWN, NONE, RANDOM}

var num_players: int = 8
var bus: String = "SFX"

var available: Array = []  # The available players.
var queue: Array = []  # The queue of sounds to play.

var music: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	# Create the pool of AudioStreamPlayer nodes.
	for i: int in num_players:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus

	add_child(music)


func _on_stream_finished(stream: AudioStreamPlayer) -> void:
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path: String, scale: float = 0.0) -> void:
	queue.append([
		sound_path,
		scale
	])


func play_music(sound_path: String) -> void:
	music.bus = "Music"
	music.stream = load(sound_path)
	music.play()


func _process(_delta: float) -> void:
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		var sound: Array = queue.pop_front()
		available[0].stream = load(sound[0])
		available[0].pitch_scale = 1.0 + sound[1]
		available[0].play()
		available.pop_front()
