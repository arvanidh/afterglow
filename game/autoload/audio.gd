extends Node
## SFX engine v2 — synthesizes EVERY sound at startup into memory (16-bit PCM).
## Zero asset dependency: no imports, no packing, no remaps — silence is now
## impossible from the packaging side. Louder mixes tuned for phone speakers.
## A diagnostic line prints at boot so `adb logcat` always shows ground truth.

const RATE := 22050
const POOL_SIZE := 20

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _idx := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Master bus hardening — never muted, never scaled down by accident.
	AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, 0.0)
	_build_all()
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	print("AUDIO_OK streams=%d pool=%d" % [_streams.size(), POOL_SIZE])


func play(sfx_name: String, volume_db := 0.0, pitch_jitter := 0.05) -> void:
	if not _streams.has(sfx_name):
		push_warning("AUDIO missing '%s'" % sfx_name)
		return
	var p := _players[_idx]
	_idx = (_idx + 1) % _players.size()
	p.stream = _streams[sfx_name]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


func debug_info() -> String:
	return "%d/%d" % [_streams.size(), POOL_SIZE]


# ---------------------------------------------------------------- synthesis core

func _bake(duration: float, generator: Callable, gain := 0.85) -> AudioStreamWAV:
	var n := maxi(int(duration * RATE), 1)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in range(n):
		var t := float(i) / float(RATE)
		var u := float(i) / float(n)
		var v: float = clampf(generator.call(t, u), -1.0, 1.0) * gain
		bytes.encode_s16(i * 2, int(v * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	return wav


static func _env(u: float, attack := 0.01, curve := 3.0) -> float:
	if u < attack:
		return u / attack
	return pow(1.0 - (u - attack) / (1.0 - attack), curve)


static func _square(ph: float) -> float:
	return 1.0 if fposmod(ph, 1.0) < 0.5 else -1.0


static func _saw(ph: float) -> float:
	return fposmod(ph, 1.0) * 2.0 - 1.0


static func _noise() -> float:
	return randf() * 2.0 - 1.0


# ---------------------------------------------------------------- the bank

func _build_all() -> void:
	_streams["shoot"] = _bake(0.10, func(t: float, u: float) -> float:
		var f := lerpf(880.0, 230.0, pow(u, 0.6))
		return (_square(t * f) * 0.7 + _noise() * 0.12) * _env(u, 0.02, 2.6))

	_streams["hit"] = _bake(0.06, func(t: float, u: float) -> float:
		return (_noise() * 0.65 + sin(t * 3400.0 * TAU) * 0.5) * _env(u, 0.005, 5.0))

	_streams["die"] = _bake(0.24, func(t: float, u: float) -> float:
		var f := lerpf(420.0, 55.0, pow(u, 0.5))
		return (_saw(t * f) * 0.55 + _noise() * 0.3 * (1.0 - u)) * _env(u, 0.008, 2.4))

	_streams["hurt"] = _bake(0.20, func(t: float, u: float) -> float:
		var wob := 1.0 + 0.18 * sin(t * 46.0 * TAU)
		return _square(t * 128.0 * TAU * wob) * 0.62 * _env(u, 0.01, 2.0))

	_streams["pickup"] = _bake(0.09, func(t: float, u: float) -> float:
		var f: float = lerpf(660.0, 1420.0, u * u)
		return sin(t * f * TAU) * _env(u, 0.02, 2.2))

	_streams["powerup"] = _bake(0.30, func(t: float, u: float) -> float:
		var step := floorf(u * 3.0)
		var f: float = [523.0, 659.0, 880.0][int(step)]
		return (sin(t * f * TAU) * 0.7 + sin(t * f * 2.0 * TAU) * 0.2) * _env(u, 0.02, 1.8))

	_streams["levelup"] = _bake(0.5, func(t: float, u: float) -> float:
		var step := floorf(u * 5.0)
		var f: float = [523.0, 659.0, 784.0, 1046.0, 1318.0][int(step)]
		return sin(t * f * TAU) * 0.72 * _env(fposmod(u * 5.0, 1.0) * 0.999 + 0.001, 0.03, 1.6))

	_streams["select"] = _bake(0.07, func(t: float, u: float) -> float:
		return sin(t * 990.0 * TAU) * _env(u, 0.01, 3.0))

	_streams["level_start"] = _bake(0.34, func(t: float, u: float) -> float:
		var half := 1.0 if u < 0.5 else 2.0
		var f: float = 392.0 * half
		return sin(t * f * TAU) * 0.6 * _env(u, 0.02, 2.0))

	_streams["level_clear"] = _bake(0.62, func(t: float, u: float) -> float:
		var step := floorf(u * 4.0)
		var f: float = [523.0, 659.0, 784.0, 1046.0][int(step)]
		return (sin(t * f * TAU) * 0.6 + _square(t * f * TAU) * 0.12) * _env(fposmod(u * 4.0, 1.0) + 0.001, 0.04, 1.5))

	_streams["game_over"] = _bake(0.95, func(t: float, u: float) -> float:
		var f: float = lerpf(330.0, 82.0, pow(u, 0.7))
		return (sin(t * f * TAU) * 0.55 + sin(t * f * 0.5 * TAU) * 0.3) * _env(u, 0.02, 1.4))

	_streams["dash"] = _bake(0.18, func(t: float, u: float) -> float:
		var f: float = lerpf(2400.0, 500.0, u)
		return (_noise() * 0.5 + sin(t * f * TAU) * 0.25) * _env(u, 0.01, 2.0))

	_streams["spit"] = _bake(0.09, func(t: float, u: float) -> float:
		var f: float = lerpf(520.0, 180.0, u)
		return _square(t * f * TAU) * 0.42 * _env(u, 0.02, 2.5))

	_streams["thud"] = _bake(0.22, func(t: float, u: float) -> float:
		var f: float = lerpf(95.0, 40.0, u)
		return (sin(t * f * TAU) * 0.9 + _noise() * 0.2 * (1.0 - u)) * _env(u, 0.005, 2.8))

	_streams["elite"] = _bake(0.42, func(t: float, u: float) -> float:
		var f := 110.0
		return (sin(t * f * TAU) * 0.5 + sin(t * f * 1.5 * TAU) * 0.4) * _env(u, 0.03, 1.6))
	# --- FUNNY KILL SOUNDS ---
	# Pop: silly high-pitched pop for Swarmlets (small, fast)
	_streams["pop"] = _bake(0.14, func(t: float, u: float) -> float:
		var f: float = lerpf(1200.0, 400.0, pow(u, 0.3))
		return sin(t * f * TAU) * 0.8 * _env(u, 0.005, 4.0))

	# Splat: wet cartoon splat for Shades
	_streams["splat"] = _bake(0.18, func(t: float, u: float) -> float:
		var f: float = lerpf(300.0, 80.0, pow(u, 0.4))
		return (_noise() * 0.6 + sin(t * f * TAU) * 0.4) * _env(u, 0.003, 3.5))

	# Crunch: meaty satisfying crunch for Brutes
	_streams["crunch"] = _bake(0.25, func(t: float, u: float) -> float:
		var f: float = lerpf(180.0, 50.0, pow(u, 0.6))
		return (_noise() * 0.7 + _square(t * f) * 0.5 + sin(t * 90.0 * TAU) * 0.3) * _env(u, 0.002, 2.5))

	# Squeak: funny high squeak for Spitters
	_streams["squeak"] = _bake(0.16, func(t: float, u: float) -> float:
		var f: float = lerpf(1800.0, 600.0, pow(u, 0.2))
		var vibrato := 1.0 + 0.3 * sin(t * 30.0 * TAU)
		return sin(t * f * TAU * vibrato) * 0.7 * _env(u, 0.005, 4.5))

	# Splat2: deeper variant for variety
	_streams["splat2"] = _bake(0.20, func(t: float, u: float) -> float:
		var f: float = lerpf(220.0, 60.0, pow(u, 0.5))
		return (_noise() * 0.5 + _saw(t * f) * 0.4) * _env(u, 0.004, 3.0))

	# Mini fanfare: tiny trumpety victory for elite kills
	_streams["fanfare"] = _bake(0.45, func(t: float, u: float) -> float:
		var step := floorf(u * 4.0)
		var f: float = [784.0, 988.0, 1175.0, 1568.0][int(step)]
		return (sin(t * f * TAU) * 0.65 + _square(t * f * TAU) * 0.15) * _env(fposmod(u * 4.0, 1.0) * 0.999 + 0.001, 0.02, 1.8))

	# Combo: escalating pitch ping for streak kills
	_streams["combo3"] = _bake(0.12, func(t: float, u: float) -> float:
		return sin(t * 1047.0 * TAU) * 0.7 * _env(u, 0.005, 5.0))

	_streams["combo5"] = _bake(0.15, func(t: float, u: float) -> float:
		return sin(t * 1319.0 * TAU) * 0.75 * _env(u, 0.005, 5.0))

	_streams["combo10"] = _bake(0.22, func(t: float, u: float) -> float:
		var step := floorf(u * 3.0)
		var f: float = [1319.0, 1568.0, 2093.0][int(step)]
		return sin(t * f * TAU) * 0.8 * _env(fposmod(u * 3.0, 1.0) * 0.999 + 0.001, 0.01, 3.0))

	# Extra funny kill sounds
	_streams["boing"] = _bake(0.18, func(t: float, u: float) -> float:
		var f: float = lerpf(600.0, 180.0, u)
		return sin(t * f * TAU) * 0.7 * _env(u, 0.003, 4.0))

	_streams["squelch"] = _bake(0.15, func(t: float, u: float) -> float:
		return (_noise() * 0.6 + sin(t * lerpf(350.0, 100.0, u) * TAU) * 0.4) * _env(u, 0.003, 5.0))

	_streams["honk"] = _bake(0.22, func(t: float, u: float) -> float:
		return (_square(t * 330.0 * TAU) * 0.5 + _saw(t * 440.0 * TAU) * 0.3) * _env(u, 0.01, 2.5))

	_streams["whomp"] = _bake(0.30, func(t: float, u: float) -> float:
		var f: float = lerpf(120.0, 40.0, u)
		return sin(t * f * TAU) * 0.8 * _env(u, 0.005, 2.0))

	_streams["doh"] = _bake(0.25, func(t: float, u: float) -> float:
		var f: float = lerpf(800.0, 250.0, pow(u, 0.7))
		return sin(t * f * TAU) * 0.7 * _env(u, 0.004, 3.0))

	_streams["oops"] = _bake(0.14, func(t: float, u: float) -> float:
		return sin(t * lerpf(1200.0, 400.0, u) * TAU) * 0.6 * _env(u, 0.002, 6.0))

