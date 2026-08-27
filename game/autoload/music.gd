extends Node
## Music player — ambient synth tracks per biome. Loops seamlessly.

var _player: AudioStreamPlayer
var _current_biome := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.volume_db = 0.0
	add_child(_player)


func play_biome(biome_id: String) -> void:
	if biome_id == _current_biome and _player.playing:
		return
	_current_biome = biome_id
	_play_track("music_%s" % biome_id)


func play_boss() -> void:
	_current_biome = "boss"
	_play_track("music_boss")


func _play_track(track_name: String) -> void:
	# Try loading with .wav extension
	var path := "res://assets/audio/%s.wav" % track_name
	var stream = load(path)
	if stream == null:
		push_warning("Music: cannot load %s" % path)
		return
	# Enable looping on WAV streams
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.get_length() * 44100
	_player.stream = stream
	_player.play()
	print("Music: playing %s (length: %.1fs)" % [track_name, stream.get_length()])


func stop() -> void:
	_player.stop()
	_current_biome = ""


func set_volume(db: float) -> void:
	_player.volume_db = db


func is_playing() -> bool:
	return _player.playing
