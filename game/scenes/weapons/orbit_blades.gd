class_name OrbitBlades
extends Node2D
## ORBIT BLADES — rotating satellites (GDD §5.4 weapon #2). Positioning your
## body IS the aim. Levels add blades, widen the arc, sharpen damage.

const HIT_COOLDOWN_MS := 280
const DISPLAY_NAME := "Orbit Blades"
const ID := "orbit"

const LEVELS := [
	{"count": 2, "radius": 56.0, "omega": 3.6, "damage": 1},
	{"count": 3, "radius": 62.0, "omega": 3.9, "damage": 1},
	{"count": 3, "radius": 70.0, "omega": 4.4, "damage": 2},
	{"count": 4, "radius": 78.0, "omega": 4.8, "damage": 2},
	{"count": 5, "radius": 88.0, "omega": 5.4, "damage": 3},
]

var level := 1
var arena: Node = null
var rate_scale := 1.0
var angle := 0.0


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "%d blades · %d dmg" % [_stats()["count"], _stats()["damage"]]


func _process(delta: float) -> void:
	var mods_speed: float = 1.0
	if get_parent() is PlayerSpark:
		mods_speed = float((get_parent() as PlayerSpark).mods.get("rate_mult", 1.0))
	angle = fposmod(angle + float(_stats()["omega"]) * rate_scale * mods_speed * delta, TAU)
	queue_redraw()
	if arena == null or arena._ending:
		return
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
