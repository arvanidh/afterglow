extends Node
## Pooled SFX playback — round-robin players, slight pitch jitter so repeated
## hits feel organic. Streams are procedurally baked wavs (tools/make_sfx.gd).

const NAMES := ["shoot", "hit", "die", "hurt", "pickup", "powerup", "level_start", "level_clear", "game_over"]
const POOL_SIZE := 10

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _idx := 0


func _ready() -> void:
	for n in NAMES:
		var path := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(path):
			_streams[n] = load(path)
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func play(sfx_name: String, volume_db := 0.0, pitch_jitter := 0.06) -> void:
	if not _streams.has(sfx_name):
		return
	var p := _players[_idx]
	_idx = (_idx + 1) % _players.size()
	p.stream = _streams[sfx_name]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()
