extends Node
## Music player — ambient synth tracks per biome. Loops seamlessly.

var _player: AudioStreamPlayer
var _current_biome := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.volume_db = -4.0
	add_child(_player)
	# Re-import music files with loop enabled
	_reimport_music()


func _reimport_music() -> void:
	# Set loop mode on the WAV resources
	for biome in ["promenade", "sewers", "sky", "boss"]:
		var path := "res://assets/audio/music_%s.wav" % biome
		var stream: AudioStream = load(path)
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = stream.get_length() * 44100


func play_biome(biome_id: String) -> void:
	if biome_id == _current_biome and _player.playing:
		return
	_current_biome = biome_id
	var path := "res://assets/audio/music_%s.wav" % biome_id
	var stream: AudioStream = load(path)
	if stream == null:
		push_warning("Music: cannot load %s" % path)
		return
	# Enable looping
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.get_length() * 44100
	_player.stream = stream
	_player.play()


func play_boss() -> void:
	_current_biome = "boss"
	var stream: AudioStream = load("res://assets/audio/music_boss.wav")
	if stream == null:
		return
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.get_length() * 44100
	_player.stream = stream
	_player.play()


func stop() -> void:
	_player.stop()
	_current_biome = ""


func set_volume(db: float) -> void:
	_player.volume_db = db


func is_playing() -> bool:
	return _player.playing
