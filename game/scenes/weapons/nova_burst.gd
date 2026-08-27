class_name NovaBurst
extends Node2D
## NOVA BURST — radial shockwave + periodic bolt fire.
## Waves hit all nearby enemies AND bolts shoot at nearest target.

const DISPLAY_NAME := "Nova Burst"
const ID := "nova"
const BOLT_INTERVAL := 1.5

const LEVELS := [
	{"interval": 3.2, "range": 120.0, "damage": 2, "shove": 40.0, "bolt_damage": 1},
	{"interval": 2.9, "range": 135.0, "damage": 2, "shove": 44.0, "bolt_damage": 1},
	{"interval": 2.6, "range": 150.0, "damage": 3, "shove": 48.0, "bolt_damage": 2},
	{"interval": 2.3, "range": 168.0, "damage": 3, "shove": 54.0, "bolt_damage": 2},
	{"interval": 2.0, "range": 190.0, "damage": 4, "shove": 60.0, "bolt_damage": 3},
]

var level := 1
var arena: Node = null
var rate_scale := 1.0
var _cd := 0.6
var _bolt_cd := 0.0


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "%d dmg · r%d · bolts" % [_stats()["damage"], int(_stats()["range"])]


func _process(delta: float) -> void:
	queue_redraw()
	if arena == null or not is_instance_valid(arena) or arena._ending:
		return
	_cd -= delta * rate_scale
	if _cd <= 0.0:
		_cd = float(_stats()["interval"])
		var dmg := int(_stats()["damage"])
		var reach := float(_stats()["range"])
		var shove_f := float(_stats()["shove"])
		if get_parent() is PlayerSpark:
			dmg = int(ceilf(float(dmg) * float((get_parent() as PlayerSpark).mods.get("dmg_mult", 1.0))))
		Audio.play("hit", -2.0, 0.12)
		arena.spawn_ring(global_position, reach, Color(0.75, 1.0, 1.0, 0.8))
		arena.shake(3.0)
		for e in arena.enemies:
			if not e.active:
				continue
			var d := global_position.distance_to(e.global_position)
			if d < reach + e.radius:
				e.shove((e.global_position - global_position).normalized(), shove_f)
				if e.take_hit(dmg):
					arena.kill_enemy(e)
	# Bolt fire between shockwaves
	_bolt_cd -= delta * rate_scale
	if _bolt_cd <= 0.0:
		_bolt_cd = BOLT_INTERVAL
		var mods := (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}
		var target: ShadowEnemy = arena.nearest_enemy(global_position, 500.0)
		if target != null:
			var dir := (target.global_position - global_position).normalized()
			var bolt: PulseBolt = arena.acquire_bolt()
			var bolt_dmg := int(ceilf(float(_stats()["bolt_damage"]) * float(mods.get("dmg_mult", 1.0))))
			bolt.launch(global_position + dir * 14.0, dir, bolt_dmg)
			Audio.play("shoot", -10.0)


func _draw() -> void:
	var pulse := 1.0 + 0.25 * sin(Time.get_ticks_msec() * 0.009)
	var frac := clampf(1.0 - _cd / float(_stats()["interval"]), 0.0, 1.0)
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.75, 1.0, 1.0, 0.85))
	draw_arc(Vector2.ZERO, float(_stats()["range"]) * (0.3 + 0.7 * frac), 0.0, TAU, 48, Color(0.0, 0.94, 1.0, 0.18), 2.0)
