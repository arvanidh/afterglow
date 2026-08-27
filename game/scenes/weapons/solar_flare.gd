class_name SolarFlare
extends Node2D
## SOLAR FLARE — evolved from Orbit + Nova.
## Orbiting blades that periodically create shockwaves.

const RANGE := 500.0
const DISPLAY_NAME := "Solar Flare"
const ID := "solar_flare"
const EVOLVED := true

const LEVELS := [
	{"interval": 0.35, "damage": 4, "shockwave_radius": 90.0},
	{"interval": 0.30, "damage": 5, "shockwave_radius": 100.0},
	{"interval": 0.26, "damage": 6, "shockwave_radius": 110.0},
	{"interval": 0.22, "damage": 8, "shockwave_radius": 125.0},
	{"interval": 0.18, "damage": 10, "shockwave_radius": 140.0},
]

var level := 1
var _cd := 0.35
var _shockwave_cd := 2.0
var arena: Node = null
var rate_scale := 1.0
var _angle := 0.0

func _stats() -> Dictionary: return LEVELS[mini(level - 1, LEVELS.size() - 1)]
func level_up() -> void: level = mini(level + 1, 5)
func upgrade_note() -> String: return "EVOLVED Lv%d → %d dmg · shockwave r%d" % [level, _stats()["damage"], int(_stats()["shockwave_radius"])]
func _player_mods() -> Dictionary: return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}

func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena): return
	var mods := _player_mods()
	var rate_total: float = rate_scale * float(mods.get("rate_mult", 1.0))
	# Orbit blades
	_angle += delta * 4.0
	queue_redraw()
	# Fire bolts at nearest enemy
	_cd -= delta * rate_total
	if _cd <= 0.0:
		var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
		if target != null:
			_cd = float(_stats()["interval"])
			var dmg := int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0))))
			var bolt: PulseBolt = arena.acquire_bolt()
			var dir := global_position.direction_to(target.global_position)
			bolt.launch(global_position + dir * 18.0, dir, dmg)
			Audio.play("shoot", -7.0)
	# Periodic shockwave
	_shockwave_cd -= delta * rate_total
	if _shockwave_cd <= 0.0:
		_shockwave_cd = 2.5
		_do_shockwave()

func _do_shockwave() -> void:
	if arena == null: return
	var stats := _stats()
	var r: float = float(stats["shockwave_radius"])
	var dmg := int(stats["damage"])
	arena.spawn_ring(global_position, r, Color(1.0, 0.45, 0.1, 0.8), 0.3)
	Audio.play("hit", -4.0)
	for e in arena.enemies:
		if not e.active: continue
		var dist: float = global_position.distance_to(e.global_position)
		if dist < r:
			arena.hud.spawn_float(e.global_position, str(dmg), Color(1.0, 0.45, 0.1))
			if e.take_hit(dmg): arena.kill_enemy(e)
	if arena._boss != null and arena._boss.active:
		var dist: float = global_position.distance_to(arena._boss.global_position)
		if dist < r:
			arena.hud.spawn_float(arena._boss.global_position, str(dmg), Color(1.0, 0.45, 0.1))
			if arena._boss.take_hit(dmg): arena._on_boss_died(arena._boss)

func _draw() -> void:
	# Draw orbiting blades
	for i in range(3):
		var a := _angle + float(i) * TAU / 3.0
		var pos := Vector2.from_angle(a) * 22.0
		draw_circle(pos, 6.0, Color(1.0, 0.45, 0.1, 0.3))
		draw_circle(pos, 3.0, Color(1.0, 0.8, 0.2, 0.9))
	# Center glow
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.5, 0.1, 0.15))
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.9, 0.4, 0.5))
