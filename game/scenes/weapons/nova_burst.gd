class_name NovaBurst
extends Node2D
## NOVA BURST — periodic radial shockwave (GDD §5.4 weapon #4). Rewards being
## surrounded: every close shadow eats the wave and gets shoved back.

const INTERVAL := 1.15
const RANGE := 135.0
const DAMAGE := 1
const SHOVE := 34.0
const DISPLAY_NAME := "Nova Burst"

var arena: Node = null
var rate_scale := 1.0
var _cd := 0.45


func _process(delta: float) -> void:
	queue_redraw()
	if arena == null or arena._ending:
		return
	_cd -= delta * rate_scale
	if _cd > 0.0:
		return
	_cd = INTERVAL
	Audio.play("hit", -2.0, 0.12)
	arena.spawn_ring(global_position, RANGE, Color(0.75, 1.0, 1.0, 0.8))
	for e in arena.enemies:
		if not e.active:
			continue
		var d := global_position.distance_to(e.global_position)
		if d < RANGE + e.radius:
			e.global_position += (e.global_position - global_position).normalized() * SHOVE
			if e.take_hit(DAMAGE):
				arena.kill_enemy(e)


func _draw() -> void:
	var pulse := 1.0 + 0.25 * sin(Time.get_ticks_msec() * 0.009)
	var frac := clampf(1.0 - _cd / INTERVAL, 0.0, 1.0)
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.75, 1.0, 1.0, 0.85))
	draw_arc(Vector2.ZERO, RANGE * (0.3 + 0.7 * frac), 0.0, TAU, 48, Color(0.0, 0.94, 1.0, 0.18), 2.0)
