class_name SpitOrb
extends Node2D
## A Spitter's lobbed shadow-glob. Flies straight at where the player WAS,
## telegraphed by a landing decal that swells as the orb arrives (§7.1 rule:
## every hit is preceded by a readable telegraph).

const SPEED := 310.0
const SPLASH_RADIUS := 34.0

var active := false
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _t := 0.0
var _dur := 1.0


func launch(from: Vector2, to: Vector2) -> void:
	global_position = from
	_from = from
	_to = to
	_dur = maxf(from.distance_to(to) / SPEED, 0.18)
	_t = 0.0
	active = true
	show()


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active:
		return
	_t += delta / _dur
	if _t >= 1.0:
		active = false
		splash()
		return
	global_position = _from.lerp(_to, _t)
	queue_redraw()


func splash() -> void:
	hide()
	queue_redraw()
	if arena_has_player():
		var arena: Node = get_parent()
		arena.spawn_ring(_to, 30.0, Color(1.0, 0.72, 0.0, 0.7), 0.22)
		Audio.play("hit", -6.0, 0.1)
		if arena.player.global_position.distance_to(_to) < SPLASH_RADIUS:
			arena.player.try_take_damage(1, _to)


func arena_has_player() -> bool:
	var arena: Node = get_parent()
	return arena != null and arena.player != null


func _draw() -> void:
	if not active:
		return
	# Landing telegraph — grows brighter as impact approaches.
	var warn := clampf(_t * 1.4, 0.0, 1.0)
	draw_arc(Vector2.ZERO, 0.0, 0.0, TAU, 3, Color.TRANSPARENT, 0.0)  # keep origin
	var target_local := to_local(_to)
	draw_circle(target_local, SPLASH_RADIUS, Color(1.0, 0.72, 0.0, 0.07 + 0.10 * warn))
	draw_arc(target_local, SPLASH_RADIUS, 0.0, TAU, 28, Color(1.0, 0.72, 0.0, 0.25 + 0.45 * warn), 2.0)
	# The glob itself arcs visually via scale bobbing.
	var bob := 1.0 + 0.35 * sin(_t * PI)
	draw_circle(Vector2.ZERO, 6.5 * bob, Color(0.1, 0.08, 0.2, 0.95))
	draw_circle(Vector2.ZERO, 2.6 * bob, Color(1.0, 0.72, 0.0, 0.95))
