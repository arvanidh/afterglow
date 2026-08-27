class_name EnvHazard
extends Node2D
## Environmental hazards that damage the player on contact.
## Spawns per biome: toxic puddles in sewers, falling debris in sky ruins.

enum Kind { TOXIC_PUDDLE, FALLING_DEBRIS, ELECTRIC_FENCE }

const COLORS := {
	Kind.TOXIC_PUDDLE: Color(0.2, 0.9, 0.3, 0.6),
	Kind.FALLING_DEBRIS: Color(0.9, 0.3, 0.1, 0.6),
	Kind.ELECTRIC_FENCE: Color(0.4, 0.6, 1.0, 0.7),
}

const STATS := {
	Kind.TOXIC_PUDDLE: {"damage": 1, "radius": 35.0, "lifetime": 8.0, "tick_rate": 0.8},
	Kind.FALLING_DEBRIS: {"damage": 2, "radius": 25.0, "lifetime": 1.5, "tick_rate": 99.0},
	Kind.ELECTRIC_FENCE: {"damage": 1, "radius": 30.0, "lifetime": 6.0, "tick_rate": 0.5},
}

var kind := Kind.TOXIC_PUDDLE
var active := false
var _age := 0.0
var _tick_cd := 0.0
var _warning := true  # Shows warning ring before damage starts


func activate(p_kind: Kind, at: Vector2) -> void:
	kind = p_kind
	global_position = at
	_age = 0.0
	_tick_cd = 0.0
	_warning = true
	active = true
	show()
	queue_redraw()


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active:
		return
	_age += delta
	var stats: Dictionary = STATS[kind]
	# Warning phase: show ring but no damage
	if _warning and _age < 0.5:
		queue_redraw()
		return
	_warning = false
	# Lifetime check
	if _age > stats["lifetime"]:
		release()
		return
	# Tick damage
	_tick_cd -= delta
	if _tick_cd <= 0.0:
		_tick_cd = stats["tick_rate"]
		_check_damage()
	queue_redraw()


func _check_damage() -> void:
	var arena = get_parent()
	if arena == null or not is_instance_valid(arena):
		return
	if not "player" in arena:
		return
	var player = arena.player
	if player == null or not is_instance_valid(player):
		return
	var r: float = STATS[kind]["radius"]
	var dist: float = global_position.distance_to(player.global_position)
	if dist < r + player.RADIUS:
		var dmg: int = STATS[kind]["damage"]
		player.take_damage(dmg)


func _draw() -> void:
	if not active:
		return
	var col: Color = COLORS[kind]
	var stats: Dictionary = STATS[kind]
	var r: float = stats["radius"]
	if _warning:
		# Warning ring — pulsing red
		var pulse := 0.5 + 0.5 * sin(_age * 20.0)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 0.2, 0.1, 0.3 + 0.3 * pulse), 2.0)
		return
	match kind:
		Kind.TOXIC_PUDDLE:
			# Green glowing puddle
			var alpha := 0.4 + 0.15 * sin(_age * 3.0)
			draw_circle(Vector2.ZERO, r, Color(col.r, col.g, col.b, 0.15))
			draw_circle(Vector2.ZERO, r * 0.6, Color(col.r, col.g, col.b, 0.25))
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, Color(col.r, col.g, col.b, alpha), 1.5)
		Kind.FALLING_DEBRIS:
			# Red impact circle
			var progress := clampf(_age / stats["lifetime"], 0.0, 1.0)
			var alpha := 1.0 - progress
			draw_circle(Vector2.ZERO, r, Color(col.r, col.g, col.b, 0.2 * alpha))
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 16, Color(col.r, col.g, col.b, 0.6 * alpha), 2.0)
			# Debris chunks
			for i in range(3):
				var a := float(i) * TAU / 3.0 + _age * 2.0
				var d := r * 0.5 * progress
				var pos := Vector2.from_angle(a) * d
				draw_circle(pos, 3.0, Color(col.r, col.g, col.b, 0.7 * alpha))
		Kind.ELECTRIC_FENCE:
			# Blue electric arcs
			var t := _age * 8.0
			var pts := PackedVector2Array()
			for i in range(6):
				var a := float(i) * TAU / 6.0
				var offset := Vector2.from_angle(a + t) * r * 0.3
				pts.append(offset + Vector2(randf_range(-4, 4), randf_range(-4, 4)))
			for i in range(pts.size() - 1):
				draw_line(pts[i], pts[i + 1], Color(col.r, col.g, col.b, 0.6), 1.5)
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, Color(col.r, col.g, col.b, 0.3), 1.0)
