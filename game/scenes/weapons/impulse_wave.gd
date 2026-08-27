class_name ImpulseWave
extends Node2D
## IMPULSE WAVE — Hybrid: Pulse + Nova.
## Fires a wide piercing energy wave that hits ALL enemies in a line.
## No inner classes — uses basic CPUParticles2D + stored data.

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
var _waves: Array = []  # Active wave data dicts


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	var s := _stats()
	return "Lv%d -> %d dmg %.1fs" % [level, s["damage"], s["interval"]]


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	# Tick active waves
	var remove: Array = []
	for w in _waves:
		w["fx"].position += w["dir"] * w["speed"] * delta
		w["traveled"] += w["speed"] * delta
		if w["traveled"] >= w["range"]:
			if w["fx"] != null and is_instance_valid(w["fx"]):
				w["fx"].queue_free()
			remove.append(w)
			continue
		# Check hits
		_check_wave_hits(w)
	for w in remove:
		_waves.erase(w)
	# Fire new wave on cooldown
	_cd -= delta * rate_scale
	if _cd > 0.0:
		return
	_cd = _stats()["interval"]
	if arena.player == null or not is_instance_valid(arena.player):
		return
	var target = _find_target()
	if target == null:
		return
	_fire_wave(target)


func _find_target():
	if arena.player == null or not is_instance_valid(arena.player):
		return null
	var best_dist := 999999.0
	var best_e = null
	var snapshot: Array = arena.enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		var d: float = arena.player.global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best_e = e
	if arena._boss != null and arena._boss.active:
		var d: float = arena.player.global_position.distance_to(arena._boss.global_position)
		if d < best_dist:
			return arena._boss
	return best_e


func _fire_wave(target) -> void:
	var player = arena.player
	var dir: Vector2 = (target.global_position - player.global_position).normalized()
	var stats := _stats()
	# Visual: expanding circle + trail particles
	var fx := CPUParticles2D.new()
	fx.position = arena.world.to_local(player.global_position)
	fx.one_shot = false
	fx.emitting = true
	fx.amount = 12
	fx.lifetime = stats["wave_range"] / stats["wave_speed"]
	fx.explosiveness = 0.8
	fx.spread = 15.0
	fx.gravity = Vector2.ZERO
	fx.initial_velocity_min = stats["wave_speed"] * 0.5
	fx.initial_velocity_max = stats["wave_speed"]
	fx.scale_amount_min = 3.0
	fx.scale_amount_max = 6.0
	fx.color = Color(1.0, 0.8, 0.2, 0.9)
	fx.z_index = 15
	arena.world.add_child(fx)
	_waves.append({
		"fx": fx,
		"dir": dir,
		"speed": stats["wave_speed"],
		"range": stats["wave_range"],
		"width": stats["wave_width"],
		"dmg": stats["damage"],
		"traveled": 0.0,
		"hit_enemies": [],
	})


func _check_wave_hits(w: Dictionary) -> void:
	var wave_pos: Vector2 = w["fx"].position
	var width: float = w["width"]
	var dmg: int = w["dmg"]
	var snapshot: Array = arena.enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		if w["hit_enemies"].has(e):
			continue
		if wave_pos.distance_to(arena.world.to_local(e.global_position)) < width:
			w["hit_enemies"].append(e)
			if e.take_hit(dmg):
				arena.kill_enemy(e)
			if arena.hud != null and is_instance_valid(arena.hud):
				arena.hud.spawn_float(e.global_position, str(dmg), Color(1.0, 0.8, 0.2))
	# Also check boss
	if arena._boss != null and arena._boss.active:
		if wave_pos.distance_to(arena.world.to_local(arena._boss.global_position)) < width:
			if arena._boss.take_hit(dmg):
				arena._on_boss_died(arena._boss)
