class_name ShadowEnemy
extends Node2D
## Base shadow — silhouette body, glowing eyes (§7.1 art law). Pool-managed by
## the arena: never freed mid-run, only released and recycled.

signal died(enemy: ShadowEnemy)

enum Kind { SHADE, SWARMLET }

const STATS := {
	Kind.SHADE: {
		"hp": 3, "speed": 92.0, "speed_jitter": 34.0, "radius": 15.0, "damage": 1,
		"body": Color("1c2340"), "rim": Color("2a3358"), "eye": Color(1.0, 0.18, 0.53), "gems": 1,
	},
	Kind.SWARMLET: {
		"hp": 1, "speed": 158.0, "speed_jitter": 44.0, "radius": 9.5, "damage": 1,
		"body": Color("161b36"), "rim": Color("232a52"), "eye": Color(0.62, 0.4, 1.0), "gems": 1,
	},
}

var kind := Kind.SHADE
var hp := 1
var speed := 90.0
var radius := 14.0
var damage := 1
var active := false
var melee_ready_ms := 0  # Orbit Blades per-enemy hit cooldown
var _player: Node2D
var _flash := 0.0
var _dir := Vector2.RIGHT


func setup(new_kind: Kind, player: Node2D, rng: RandomNumberGenerator) -> void:
	kind = new_kind
	var s: Dictionary = STATS[kind]
	hp = s["hp"]
	speed = s["speed"] + rng.randf_range(-s["speed_jitter"], s["speed_jitter"])
	radius = s["radius"]
	damage = s["damage"]
	_player = player
	active = true
	show()


func take_hit(dmg: int) -> bool:
	hp -= dmg
	_flash = 0.12
	queue_redraw()
	return hp <= 0


func die() -> void:
	active = false
	hide()
	died.emit(self)


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	_flash = maxf(0.0, _flash - delta)
	_dir = (_player.global_position - global_position).normalized()
	global_position += _dir * speed * delta
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var body: Color = s["body"]
	var rim: Color = s["rim"]
	var eye: Color = s["eye"]
	if _flash > 0.0:
		body = body.lerp(Color.WHITE, _flash / 0.12)
	draw_circle(Vector2.ZERO, radius + 5.0, Color(rim.r, rim.g, rim.b, 0.25))
	draw_circle(Vector2.ZERO, radius, body)
	# Eyes track the player — the shadow is looking at its prey.
	var side := Vector2(-_dir.y, _dir.x)
	var eye_fwd := _dir * radius * 0.38
	for offset in [-1.0, 1.0]:
		var pos: Vector2 = eye_fwd + side * offset * radius * 0.3
		draw_circle(pos, radius * 0.16, Color(eye.r, eye.g, eye.b, 0.4))
		draw_circle(pos, radius * 0.09, eye)
