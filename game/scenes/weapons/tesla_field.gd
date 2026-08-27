class_name TeslaField
extends Node2D
## TESLA FIELD — Hybrid: Lightning + Orbit.
## Orbiting lightning bolts that orbit the player AND chain to nearby enemies.

const DISPLAY_NAME := "Tesla Field"
const ID := "tesla_field"

const LEVELS := [
	{"damage": 2, "orbit_speed": 2.5, "orbit_radius": 70.0, "chain_range": 120.0, "chain_damage": 1},
	{"damage": 3, "orbit_speed": 3.0, "orbit_radius": 80.0, "chain_range": 130.0, "chain_damage": 1},
	{"damage": 4, "orbit_speed": 3.5, "orbit_radius": 90.0, "chain_range": 140.0, "chain_damage": 2},
	{"damage": 5, "orbit_speed": 4.0, "orbit_radius": 100.0, "chain_range": 160.0, "chain_damage": 2},
	{"damage": 7, "orbit_speed": 5.0, "orbit_radius": 110.0, "chain_range": 180.0, "chain_damage": 3},
]

var level := 1
var _cd := 0.0
var arena: Node = null
var rate_scale := 1.0
var _angle := 0.0
var _hit_cd := {}  # enemy instance_id -> cooldown


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · chain %d" % [level, _stats()["damage"], _stats()["chain_damage"]]


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	if arena.player == null or not is_instance_valid(arena.player):
		return
	var stats := _stats()
	_angle += stats["orbit_speed"] * delta * rate_scale
	# Decrease hit cooldowns
	var to_remove: Array = []
	for key: int in _hit_cd:
		_hit_cd[key] -= delta
		if _hit_cd[key] <= 0.0:
			to_remove.append(key)
	for key: int in to_remove:
		_hit_cd.erase(key)
	# Check orbit bolt hits enemies
	var bolt_pos: Vector2 = arena.player.global_position + Vector2.from_angle(_angle) * stats["orbit_radius"]
	var bolt_pos2: Vector2 = arena.player.global_position + Vector2.from_angle(_angle + PI) * stats["orbit_radius"]
	_check_hit(bolt_pos, stats)
	_check_hit(bolt_pos2, stats)
	queue_redraw()


func _check_hit(bolt_pos: Vector2, stats: Dictionary) -> void:
	var snapshot: Array = arena.enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		var eid: int = e.get_instance_id()
		if _hit_cd.has(eid):
			continue
		if bolt_pos.distance_to(e.global_position) < 25.0:
			_hit_cd[eid] = 0.3
			if e.take_hit(stats["damage"]):
				arena.kill_enemy(e)
			if arena.hud != null and is_instance_valid(arena.hud):
				arena.hud.spawn_float(e.global_position, str(stats["damage"]), Color(0.4, 0.7, 1.0))
			# Chain lightning to nearby enemies
			_chain_from(e.global_position, stats)
			break


func _chain_from(from_pos: Vector2, stats: Dictionary) -> void:
	var chain_range: float = stats["chain_range"]
	var chain_dmg: int = stats["chain_damage"]
	var snapshot: Array = arena.enemies.duplicate()
	var best_dist := 999999.0
	var best_e = null
	for e in snapshot:
		if not e.active:
			continue
		var d: float = from_pos.distance_to(e.global_position)
		if d < chain_range and d < best_dist:
			best_dist = d
			best_e = e
	if best_e != null:
		if best_e.take_hit(chain_dmg):
			arena.kill_enemy(best_e)
		if arena.hud != null and is_instance_valid(arena.hud):
			arena.hud.spawn_float(best_e.global_position, "CHAIN", Color(0.4, 0.7, 1.0))
		# Visual chain line
		_draw_chain(from_pos, best_e.global_position)


func _draw_chain(from: Vector2, to: Vector2) -> void:
	# Simple chain visual — spawn a temporary line node
	if arena == null or not is_instance_valid(arena) or arena.world == null:
		return
	var line := Line2D.new()
	line.points = PackedVector2Array([arena.world.to_local(from), arena.world.to_local(to)])
	line.width = 2.0
	line.default_color = Color(0.4, 0.7, 1.0, 0.8)
	line.z_index = 25
	arena.world.add_child(line)
	if arena.get_tree():
		arena.get_tree().create_timer(0.2).timeout.connect(func():
			if is_instance_valid(line):
				line.queue_free()
		)


func _draw() -> void:
	if arena == null or not is_instance_valid(arena) or arena.player == null:
		return
	var stats := _stats()
	var center: Vector2 = arena.player.global_position - global_position
	# Draw orbit ring (faint)
	draw_arc(center, stats["orbit_radius"], 0.0, TAU, 48, Color(0.4, 0.7, 1.0, 0.1), 1.0)
	# Draw two orbiting bolt positions
	var bolt1: Vector2 = center + Vector2.from_angle(_angle) * stats["orbit_radius"]
	var bolt2: Vector2 = center + Vector2.from_angle(_angle + PI) * stats["orbit_radius"]
	draw_circle(bolt1, 8.0, Color(0.4, 0.7, 1.0, 0.9))
	draw_circle(bolt2, 8.0, Color(0.4, 0.7, 1.0, 0.9))
	draw_circle(bolt1, 4.0, Color(0.8, 0.95, 1.0, 1.0))
	draw_circle(bolt2, 4.0, Color(0.8, 0.95, 1.0, 1.0))
