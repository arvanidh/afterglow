class_name ImpulseWave
extends Node2D
## IMPULSE WAVE — Hybrid: Pulse + Nova.
## Fires a wide piercing energy wave that hits ALL enemies in a line.

const DISPLAY_NAME := "Impulse Wave"
const ID := "impulse_wave"

const LEVELS := [
	{"interval": 1.8, "damage": 3, "wave_width": 50.0, "wave_range": 350.0, "wave_speed": 500.0},
	{"interval": 1.6, "damage": 4, "wave_width": 60.0, "wave_range": 380.0, "wave_speed": 550.0},
	{"interval": 1.4, "damage": 5, "wave_width": 70.0, "wave_range": 400.0, "wave_speed": 600.0},
	{"interval": 1.2, "damage": 7, "wave_width": 80.0, "wave_range": 430.0, "wave_speed": 650.0},
	{"interval": 1.0, "damage": 10, "wave_width": 100.0, "wave_range": 460.0, "wave_speed": 700.0},
]

var level := 1
var _cd := 0.0
var arena: Node = null
var rate_scale := 1.0
var _active_waves: Array = []


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	var s := _stats()
	return "Lv%d → %d dmg · %.1fs" % [level, s["damage"], s["interval"]]


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	if arena.player == null or not is_instance_valid(arena.player):
		return
	_cd -= delta * rate_scale
	if _cd > 0.0:
		return
	# Fire wave toward nearest enemy
	_cd = _stats()["interval"]
	var target := _find_target()
	if target == null:
		return
	_fire_wave(target)


func _find_target():
	var player = arena.player
	var best_dist := 999999.0
	var best_e = null
	var snapshot: Array = arena.enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		var d: float = player.global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best_e = e
	# Also check boss
	if arena._boss != null and arena._boss.active:
		var d: float = player.global_position.distance_to(arena._boss.global_position)
		if d < best_dist:
			return arena._boss
	return best_e


func _fire_wave(target) -> void:
	var player = arena.player
	var dir: Vector2 = (target.global_position - player.global_position).normalized()
	var wave := _WaveNode.new()
	wave.stats = _stats()
	wave.arena = arena
	wave.dir = dir
	wave.position = arena.world.to_local(player.global_position)
	arena.world.add_child(wave)
	_active_waves.append(wave)


class _WaveNode extends Node2D:
	var stats := {}
	var arena: Node = null
	var dir := Vector2.RIGHT
	var _pos := Vector2.ZERO
	var _speed := 500.0
	var _range := 350.0
	var _traveled := 0.0
	var _width := 50.0
	var _dmg := 3
	var _hit_enemies: Array = []


	func _ready() -> void:
		_speed = stats.get("wave_speed", 500.0)
		_range = stats.get("wave_range", 350.0)
		_width = stats.get("wave_width", 50.0)
		_dmg = stats.get("damage", 3)
		_pos = position
		z_index = 15


	func _process(delta: float) -> void:
		var move: Vector2 = dir * _speed * delta
		_pos += move
		_traveled += move.length()
		position = _pos
		# Check hits
		if arena == null or not is_instance_valid(arena):
			queue_free()
			return
		var snapshot: Array = arena.enemies.duplicate()
		for e in snapshot:
			if not e.active:
				continue
			if _hit_enemies.has(e):
				continue
			if _pos.distance_to(arena.world.to_local(e.global_position)) < _width:
				_hit_enemies.append(e)
				if e.take_hit(_dmg):
					arena.kill_enemy(e)
				if arena.hud != null and is_instance_valid(arena.hud):
					arena.hud.spawn_float(e.global_position, str(_dmg), Color(1.0, 0.8, 0.2))
		# Check boss hit
		if arena._boss != null and arena._boss.active:
			if _pos.distance_to(arena.world.to_local(arena._boss.global_position)) < _width:
				if arena._boss.take_hit(_dmg):
					arena._on_boss_died(arena._boss)
		# Travel limit
		if _traveled >= _range:
			queue_free()
			return
		queue_redraw()


	func _draw() -> void:
		# Wave visual: expanding front + trail
		var progress: float = _traveled / _range
		var alpha: float = 1.0 - progress * 0.5
		# Front arc
		var front_pos: Vector2 = dir * 20.0
		draw_circle(front_pos, _width * 0.5, Color(1.0, 0.8, 0.2, alpha * 0.7))
		draw_circle(front_pos, _width * 0.3, Color(1.0, 0.95, 0.6, alpha * 0.9))
		# Trail
		for i in range(5):
			var trail_alpha: float = alpha * (1.0 - float(i) / 5.0) * 0.3
			var trail_pos: Vector2 = -dir * float(i) * 12.0
			draw_circle(trail_pos, _width * 0.4 * (1.0 - float(i) / 5.0), Color(1.0, 0.7, 0.0, trail_alpha))
