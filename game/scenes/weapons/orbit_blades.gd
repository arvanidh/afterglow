class_name OrbitBlades
extends Node2D
## ORBIT BLADES — rotating melee satellites (GDD §5.4 weapon #2).
## No aiming: positioning your body IS the aim.

const COUNT := 2
const RADIUS := 56.0
const BASE_OMEGA := 3.6
const DAMAGE := 1
const HIT_COOLDOWN_MS := 280
const DISPLAY_NAME := "Orbit Blades"

var arena: Node = null
var rate_scale := 1.0
var angle := 0.0


func _process(delta: float) -> void:
	angle = fposmod(angle + BASE_OMEGA * rate_scale * delta, TAU)
	queue_redraw()
	if arena == null or arena._ending:
		return
	var now := Time.get_ticks_msec()
	for i in range(COUNT):
		var blade_pos := global_position + Vector2.from_angle(angle + float(i) * TAU / COUNT) * RADIUS
		for e in arena.enemies:
			if not e.active:
				continue
			if now < e.melee_ready_ms:
				continue
			if blade_pos.distance_squared_to(e.global_position) < pow(e.radius + 8.0, 2.0):
				e.melee_ready_ms = now + HIT_COOLDOWN_MS
				Audio.play("hit", -6.0)
				if e.take_hit(DAMAGE):
					arena.kill_enemy(e)


func _draw() -> void:
	for i in range(COUNT):
		var pos := Vector2.from_angle(angle + float(i) * TAU / COUNT) * RADIUS
		draw_circle(pos, 13.0, Color(0.0, 0.94, 1.0, 0.14))
		var pts := PackedVector2Array([
			pos + Vector2(0, -9), pos + Vector2(7, 0), pos + Vector2(0, 9), pos + Vector2(-7, 0),
		])
		draw_colored_polygon(pts, Color(0.75, 1.0, 1.0, 0.95))
	# faint orbit path
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 64, Color(0.0, 0.94, 1.0, 0.10), 1.5)
