extends Node
## Music player — ambient synth tracks per biome. Loops seamlessly.

var _player: AudioStreamPlayer
var _current_biome := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	_player.volume_db = -8.0
	add_child(_player)


func play_biome(biome_id: String) -> void:
	if biome_id == _current_biome and _player.playing:
		return
	_current_biome = biome_id
	var path := "res://assets/audio/music_%s.wav" % biome_id
	var stream: AudioStream = load(path)
	if stream == null:
		push_warning("Music: cannot load %s" % path)
		return
	_player.stream = stream
	_player.play()


func play_boss() -> void:
	_current_biome = "boss"
	var stream: AudioStream = load("res://assets/audio/music_boss.wav")
	if stream == null:
		return
	_player.stream = stream
	_player.play()


func stop() -> void:
	_player.stop()
	_current_biome = ""


func set_volume(db: float) -> void:
	_player.volume_db = db
