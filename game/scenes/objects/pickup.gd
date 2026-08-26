class_name Pickup
extends Node2D
## Drops from shadows and level clears. Crates swap your gun; orbs grant a
## timed or instant powerup. Walk over to collect.

enum Kind { CRATE, OVERDRIVE, SHIELD, MAGNET }

const LIFE := 20.0
const COLLECT_RANGE := 26.0

const COLORS := {
	Kind.CRATE: Color(0.0, 0.94, 1.0),
	Kind.OVERDRIVE: Color(1.0, 0.18, 0.53),
	Kind.SHIELD: Color(0.75, 1.0, 1.0),
	Kind.MAGNET: Color(1.0, 0.72, 0.0),
}

var kind := Kind.CRATE
var arena: Node = null
var active := false
var _age := 0.0


func spawn(p_kind: Kind, at: Vector2) -> void:
	kind = p_kind
	global_position = at
	_age = 0.0
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
	if _age > LIFE:
		release()
		return
	queue_redraw()
	if _age > LIFE - 3.0:  # expiry blink
		visible = fposmod(_age * 6.0, 2.0) < 1.2
	if arena == null or arena._ending:
		return
	if global_position.distance_squared_to(arena.player.global_position) < pow(COLLECT_RANGE, 2.0):
		_collect()


func _collect() -> void:
	Audio.play("powerup", -3.0)
	match kind:
		Kind.CRATE:
			arena.swap_weapon_random()
		Kind.OVERDRIVE:
			arena.apply_overdrive(8.0)
		Kind.SHIELD:
			RunState.hp = mini(RunState.hp + 1, arena.player.effective_max_hp())
			arena.hud.refresh_hp(arena.player.effective_max_hp())
		Kind.MAGNET:
			arena.vacuum_all_motes()
	release()


func _draw() -> void:
	if not active:
		return
	var col: Color = COLORS[kind]
	var spin := Time.get_ticks_msec() * 0.002
	draw_circle(Vector2.ZERO, 20.0, Color(col.r, col.g, col.b, 0.10))
	if kind == Kind.CRATE:
		var pts := PackedVector2Array()
		for i in range(4):
			pts.append(Vector2.from_angle(spin + float(i) * TAU / 4.0) * 14.0)
		draw_polyline(pts + PackedVector2Array([pts[0]]), col, 2.5)
		draw_line(pts[0], pts[2], Color(col.r, col.g, col.b, 0.5), 1.5)
		draw_line(pts[1], pts[3], Color(col.r, col.g, col.b, 0.5), 1.5)
	else:
		draw_circle(Vector2.ZERO, 9.0, Color(col.r, col.g, col.b, 0.85))
		draw_circle(Vector2.ZERO, 4.0, Color.WHITE)
	# ground marker ring so drops read clearly against the grid
	draw_arc(Vector2.ZERO, 17.0, 0.0, TAU, 32, Color(col.r, col.g, col.b, 0.35), 1.5)
