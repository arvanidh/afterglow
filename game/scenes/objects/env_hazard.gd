class_name EnvHazard
extends Node2D
## Environmental hazards per biome — visual + damage zones.

enum Kind { TOXIC_PUDDLE, ELECTRIC_TRAP, FALLING_DEBRIS, CRYSTAL_SPIKE }

var kind := Kind.TOXIC_PUDDLE
var active := false
var damage := 1
var radius := 40.0
var _timer := 0.0
var _phase := 0.0
var _flash := 0.0
var arena: Node = null


func setup(p_kind: Kind, at: Vector2, p_arena: Node) -> void:
	kind = p_kind
	arena = p_arena
	global_position = at
	active = true
	match kind:
		Kind.TOXIC_PUDDLE:
		damage = 1; radius = 45.0
		Kind.ELECTRIC_TRAP:
		damage = 2; radius = 35.0
		Kind.FALLING_DEBRIS:
		damage = 3; radius = 50.0
		Kind.CRYSTAL_SPIKE:
		damage = 2; radius = 30.0
	show()
	queue_redraw()


func _process(delta: float) -> void:
	if not active:
		return
	_timer += delta
	_phase += delta * 3.0
	_flash = maxf(0.0, _flash - delta * 4.0)
	# Check player collision
	if arena != null and arena.player != null:
		var dist := global_position.distance_to(arena.player.global_position)
		if dist < radius + PlayerSpark.RADIUS:
			arena.player.try_take_damage(damage, global_position)
			_flash = 0.3
	match kind:
		Kind.FALLING_DEBRIS:
			# Debris falls periodically
			if fmod(_timer, 3.0) < delta:
				_flash = 0.5
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	match kind:
		Kind.TOXIC_PUDDLE:
			var pulse := 0.3 + 0.15 * sin(_phase)
			draw_circle(Vector2.ZERO, radius, Color(0.0, 0.8, 0.2, 0.15 * pulse))
			draw_circle(Vector2.ZERO, radius * 0.6, Color(0.0, 1.0, 0.3, 0.25 * pulse))
			draw_circle(Vector2.ZERO, radius * 0.3, Color(0.2, 1.0, 0.4, 0.35 * pulse))
			# Bubbles
			for i in range(3):
				var a := _phase + float(i) * 2.1
				var bp := Vector2(sin(a) * radius * 0.4, cos(a) * radius * 0.3)
				draw_circle(bp, 3.0, Color(0.0, 1.0, 0.4, 0.5))
		Kind.ELECTRIC_TRAP:
			var pulse := 0.4 + 0.3 * sin(_phase * 2.0)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, Color(0.3, 0.6, 1.0, 0.3 * pulse), 2.0)
			# Lightning bolts
			for i in range(4):
				var a := float(i) * TAU / 4.0 + _phase
				var end := Vector2.from_angle(a) * radius * 0.8
				draw_line(Vector2.ZERO, end, Color(0.5, 0.8, 1.0, 0.6 * pulse), 1.5)
		Kind.FALLING_DEBRIS:
			var shake := Vector2(randf_range(-2, 2), randf_range(-2, 2)) if _flash > 0.0 else Vector2.ZERO
			draw_circle(shake, radius * 0.8, Color(0.4, 0.35, 0.3, 0.2))
			# Warning markers
			var warn := 0.5 + 0.5 * sin(_phase * 3.0)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 16, Color(1.0, 0.3, 0.0, 0.3 * warn), 2.0)
		Kind.CRYSTAL_SPIKE:
			var pts := PackedVector2Array()
			for i in range(6):
				var a := float(i) * TAU / 6.0
				var r := radius * (0.6 + 0.4 * abs(sin(a * 3.0 + _phase)))
				points.append(Vector2.from_angle(a) * r)
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO] + pts), Color(0.6, 0.3, 1.0, 0.2))
			draw_polyline(PackedVector2Array(pts + PackedVector2Array([pts[0]])), Color(0.7, 0.4, 1.0, 0.5), 2.0)
	# Flash on hit
	if _flash > 0.0:
		draw_circle(Vector2.ZERO, radius * 1.2, Color(1.0, 1.0, 1.0, _flash * 0.3))
