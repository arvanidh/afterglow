class_name OrbitBlades
extends Node2D
## ORBIT BLADES — rotating satellites + periodic bolt fire.
## Blades deal melee damage on contact AND fire bolts at nearest enemy.

const HIT_COOLDOWN_MS := 280
const DISPLAY_NAME := "Orbit Blades"
const ID := "orbit"
const BOLT_INTERVAL := 1.2  # seconds between bolt shots

const LEVELS := [
	{"count": 2, "radius": 56.0, "omega": 3.6, "damage": 1, "bolt_damage": 1},
	{"count": 3, "radius": 62.0, "omega": 3.9, "damage": 1, "bolt_damage": 1},
	{"count": 3, "radius": 70.0, "omega": 4.4, "damage": 2, "bolt_damage": 2},
	{"count": 4, "radius": 78.0, "omega": 4.8, "damage": 2, "bolt_damage": 2},
	{"count": 5, "radius": 88.0, "omega": 5.4, "damage": 3, "bolt_damage": 3},
]

var level := 1
var arena: Node = null
var rate_scale := 1.0
var angle := 0.0
var _bolt_cd := 0.0


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "%d blades · %d dmg · bolts" % [_stats()["count"], _stats()["damage"]]


func _process(delta: float) -> void:
	var mods_speed: float = 1.0
	if get_parent() is PlayerSpark:
		mods_speed = float((get_parent() as PlayerSpark).mods.get("rate_mult", 1.0))
	angle = fposmod(angle + float(_stats()["omega"]) * rate_scale * mods_speed * delta, TAU)
	queue_redraw()
	if arena == null or arena._ending:
		return

	# Melee blade damage
	var now := Time.get_ticks_msec()
	var count := int(_stats()["count"])
	var orb_r := float(_stats()["radius"])
	var dmg := int(ceilf(float(_stats()["damage"]) * float((get_parent() as PlayerSpark).mods.get("dmg_mult", 1.0)))) if get_parent() is PlayerSpark else int(_stats()["damage"])
	for i in range(count):
		var blade_pos := global_position + Vector2.from_angle(angle + float(i) * TAU / count) * orb_r
		for e in arena.enemies:
			if not e.active:
				continue
			if now < e.melee_ready_ms:
				continue
			if blade_pos.distance_squared_to(e.global_position) < pow(e.radius + 8.0, 2.0):
				e.melee_ready_ms = now + HIT_COOLDOWN_MS
				Audio.play("hit", -7.0)
				if e.take_hit(dmg):
					arena.kill_enemy(e)

	# Ranged bolt fire — shoots from nearest blade toward nearest enemy
	_bolt_cd -= delta * rate_scale
	if _bolt_cd <= 0.0:
		_bolt_cd = BOLT_INTERVAL
		var mods := (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}
		var target: ShadowEnemy = arena.nearest_enemy(global_position, 500.0)
		if target != null:
			# Fire from the blade closest to the target
			var best_blade_pos := global_position
			var best_dist := INF
			for i in range(count):
				var bp := global_position + Vector2.from_angle(angle + float(i) * TAU / count) * orb_r
				var d: float = bp.distance_to(target.global_position)
				if d < best_dist:
					best_dist = d
					best_blade_pos = bp
			var dir := (target.global_position - best_blade_pos).normalized()
			var bolt: PulseBolt = arena.acquire_bolt()
			var bolt_dmg := int(ceilf(float(_stats()["bolt_damage"]) * float(mods.get("dmg_mult", 1.0))))
			bolt.launch(best_blade_pos, dir, bolt_dmg)
			Audio.play("shoot", -10.0)


func _draw() -> void:
	var count := int(_stats()["count"])
	var orb_r := float(_stats()["radius"])
	for i in range(count):
		var pos := Vector2.from_angle(angle + float(i) * TAU / count) * orb_r
		draw_circle(pos, 13.0, Color(0.0, 0.94, 1.0, 0.14))
		var pts := PackedVector2Array([
			pos + Vector2(0, -9), pos + Vector2(7, 0), pos + Vector2(0, 9), pos + Vector2(-7, 0),
		])
		draw_colored_polygon(pts, Color(0.75, 1.0, 1.0, 0.95))
	draw_arc(Vector2.ZERO, orb_r, 0.0, TAU, 64, Color(0.0, 0.94, 1.0, 0.10), 1.5)
