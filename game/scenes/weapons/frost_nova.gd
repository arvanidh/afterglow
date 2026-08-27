class_name FrostNova
extends Node2D
## FROST NOVA — area damage + slow around the player.
## Unique mechanic: creates a frost aura that damages and slows enemies
## periodically. Higher levels = bigger radius + more damage + longer slow.

const RANGE := 200.0
const DISPLAY_NAME := "Frost Nova"
const ID := "frost"

const LEVELS := [
	{"interval": 2.0, "damage": 3, "radius": 120.0, "slow": 0.4, "slow_dur": 2.0},
	{"interval": 1.8, "damage": 4, "radius": 140.0, "slow": 0.45, "slow_dur": 2.5},
	{"interval": 1.6, "damage": 5, "radius": 160.0, "slow": 0.5, "slow_dur": 3.0},
	{"interval": 1.4, "damage": 6, "radius": 180.0, "slow": 0.55, "slow_dur": 3.5},
	{"interval": 1.2, "damage": 8, "radius": 210.0, "slow": 0.6, "slow_dur": 4.0},
]

var level := 1
var _cd := 2.0
var arena: Node = null
var rate_scale := 1.0
var _frost_ring: float = 0.0  # Visual ring animation


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · r%d · slow %d%%" % [level, _stats()["damage"], int(_stats()["radius"]), int(_stats()["slow"] * 100)]


func _player_mods() -> Dictionary:
	return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}


func _process(delta: float) -> void:
	if arena == null:
		return
	# Animate frost ring
	if _frost_ring > 0.0:
		_frost_ring = maxf(0.0, _frost_ring - delta * 2.0)
		queue_redraw()
	# Cooldown
	var mods := _player_mods()
	var rate_total: float = rate_scale * float(mods.get("rate_mult", 1.0))
	_cd -= delta * rate_total
	if _cd > 0.0:
		return
	_cd = float(_stats()["interval"])
	# Nova burst
	_frost_ring = 1.0
	queue_redraw()
	var stats := _stats()
	var dmg := int(ceilf(float(stats["damage"]) * float(mods.get("dmg_mult", 1.0))))
	var radius: float = stats["radius"]
	var slow: float = stats["slow"]
	var slow_dur: float = stats["slow_dur"]
	Audio.play("hit", -4.0)
	# Visual ring effect
	if arena:
		arena.spawn_ring(arena.player.global_position, radius, Color(0.5, 0.85, 1.0, 0.6))
	# Damage all enemies in radius
	for e in arena.enemies:
		if not e.active:
			continue
		var dist: float = arena.player.global_position.distance_to(e.global_position)
		if dist < radius:
			hud_spawn_float(e.global_position, str(dmg), Color(0.5, 0.85, 1.0))
			if e.take_hit(dmg):
				arena.kill_enemy(e)
			# Apply slow
			e.speed *= (1.0 - slow)
			# Slow wears off after duration
			var orig_speed: float = float(ShadowEnemy.STATS[e.kind]["speed"])
			arena.get_tree().create_timer(slow_dur).timeout.connect(func():
				if e.active:
					e.speed = orig_speed
			)
	# Damage boss too
	if arena._boss != null and arena._boss.active:
		var dist: float = arena.player.global_position.distance_to(arena._boss.global_position)
		if dist < radius:
			hud_spawn_float(arena._boss.global_position, str(dmg), Color(0.5, 0.85, 1.0))
			if arena._boss.take_hit(dmg):
				arena._on_boss_died(arena._boss)


func _draw() -> void:
	if _frost_ring > 0.0:
		var radius: float = _stats()["radius"]
		var alpha := _frost_ring * 0.4
		draw_arc(Vector2.ZERO, radius * (1.0 - _frost_ring * 0.3), 0.0, TAU, 40, Color(0.5, 0.85, 1.0, alpha), 3.0)
		draw_arc(Vector2.ZERO, radius * (1.0 - _frost_ring * 0.5), 0.0, TAU, 40, Color(0.75, 1.0, 1.0, alpha * 0.5), 2.0)


func hud_spawn_float(at: Vector2, text: String, col: Color) -> void:
	if arena and arena.hud:
		arena.hud.spawn_float(at, text, col)
