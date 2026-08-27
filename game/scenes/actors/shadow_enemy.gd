class_name ShadowEnemy
extends Node2D
## The shadow bestiary — silhouette bodies, glowing tracking eyes (§7.1).
## SHADE: steady chaser · SWARMLET: fast pack runner · SPITTER: ranged lobber
## with telegraphed glob · BRUTE: slow tank that shrugs off shoves.
## ELITE modifier: bigger aura, triple HP, guaranteed loot. Pool-managed.

signal spit_requested(from_pos: Vector2, target_pos: Vector2)

enum Kind { SHADE, SWARMLET, SPITTER, BRUTE, PHANTOM, BOMBER }

const STATS := {
	Kind.SHADE: {
		"hp": 3, "speed": 92.0, "speed_jitter": 34.0, "radius": 15.0, "damage": 1,
		"body": Color("1c2340"), "rim": Color("2a3358"), "eye": Color(1.0, 0.18, 0.53), "gems": 2,
		"mass": 0.15,
	},
	Kind.SWARMLET: {
		"hp": 1, "speed": 158.0, "speed_jitter": 44.0, "radius": 9.5, "damage": 1,
		"body": Color("161b36"), "rim": Color("232a52"), "eye": Color(0.62, 0.4, 1.0), "gems": 1,
		"mass": 0.05,
	},
	Kind.SPITTER: {
		"hp": 2, "speed": 74.0, "speed_jitter": 14.0, "radius": 13.0, "damage": 1,
		"body": Color("241a38"), "rim": Color("372a55"), "eye": Color(1.0, 0.72, 0.0), "gems": 2,
		"mass": 0.20,
	},
	Kind.BRUTE: {
		"hp": 14, "speed": 46.0, "speed_jitter": 8.0, "radius": 24.0, "damage": 2,
		"body": Color("131629"), "rim": Color("20263f"), "eye": Color(1.0, 0.30, 0.10), "gems": 5,
		"mass": 0.75,
	},
	Kind.PHANTOM: {
		"hp": 2, "speed": 110.0, "speed_jitter": 30.0, "radius": 12.0, "damage": 1,
		"body": Color("0d1a2e"), "rim": Color("1a2d55"), "eye": Color(0.4, 0.9, 1.0), "gems": 3,
		"mass": 0.08,
	},
	Kind.BOMBER: {
		"hp": 5, "speed": 55.0, "speed_jitter": 10.0, "radius": 18.0, "damage": 1,
		"body": Color("2e1a0d"), "rim": Color("4a2a10"), "eye": Color(1.0, 0.55, 0.0), "gems": 4,
		"mass": 0.30,
	},
}

const KIND_NAMES := {
	Kind.SHADE: "shade", Kind.SWARMLET: "swarmlet", Kind.SPITTER: "spitter", Kind.BRUTE: "brute",
	Kind.PHANTOM: "phantom", Kind.BOMBER: "bomber",
}

var kind := Kind.SHADE
var elite := false
var hp := 1
var speed := 90.0
var radius := 14.0
var damage := 1
var mass := 0.15
var active := false
var melee_ready_ms := 0  # shared per-enemy hit cooldown for blades/nova ticks

var _player: Node2D
var _flash := 0.0
var _dir := Vector2.RIGHT
var _strafe_phase := 0.0
# spitter state
var _fire_cd := 2.0
var _windup := -1.0
var _teleport_cd := 3.0
var _bomb_warning := 0.0


func setup(new_kind: Kind, player: Node2D, rng: RandomNumberGenerator, as_elite := false) -> void:
	kind = new_kind
	elite = as_elite
	var s: Dictionary = STATS[kind]
	var mult := 3.0 if elite else 1.0
	hp = int(ceilf(s["hp"] * mult))
	speed = (s["speed"] + rng.randf_range(-s["speed_jitter"], s["speed_jitter"])) * (0.9 if elite else 1.0)
	radius = s["radius"] * (1.22 if elite else 1.0)
	damage = s["damage"] + (1 if elite else 0)
	mass = s["mass"]
	_player = player
	_strafe_phase = rng.randf() * TAU
	_fire_cd = rng.randf_range(1.2, 2.4)
	_windup = -1.0
	active = true
	scale = Vector2.ONE * (1.22 if elite else 1.0)
	show()


func kind_name() -> String:
	return ("elite " if elite else "") + String(KIND_NAMES[kind])


func take_hit(dmg: int) -> bool:
	hp -= dmg
	_flash = 0.12
	queue_redraw()
	return hp <= 0


func shove(dir: Vector2, force: float) -> void:
	global_position += dir * force * (1.0 - mass)


func release() -> void:
	active = false
	hide()
	scale = Vector2.ONE


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	_flash = maxf(0.0, _flash - delta)
	var to_player := _player.global_position - global_position
	_dir = to_player.normalized()
	var dist := to_player.length()
	match kind:
		Kind.SPITTER:
			_process_spitter(delta, dist)
		Kind.PHANTOM:
			_process_phantom(delta, dist)
		Kind.BOMBER:
			_process_bomber(delta, dist)
		_:
			global_position += _dir * speed * delta
	queue_redraw()


func _process_spitter(delta: float, dist: float) -> void:
	if _windup >= 0.0:
		_windup -= delta
		if _windup < 0.0:
			var lead: Vector2 = _player.global_position
			if _player is PlayerSpark:
				lead += _player.move_dir * 90.0
			spit_requested.emit(global_position, lead)
			_fire_cd = randf_range(2.3, 2.9)
		return
	_fire_cd -= delta
	if _fire_cd <= 0.0 and dist < 430.0:
		_windup = 0.36
		return
	if dist > 330.0:
		global_position += _dir * speed * delta
	elif dist < 190.0:
		global_position -= _dir * speed * 0.7 * delta
	else:
		_strafe_phase += delta * 1.7
		var side := Vector2(-_dir.y, _dir.x)
		global_position += side * sin(_strafe_phase) * speed * 0.65 * delta


func _process_phantom(delta: float, dist: float) -> void:
	# Phantom moves toward player, then teleports close every 3s
	_teleport_cd -= delta
	if _teleport_cd <= 0.0 and dist > 80.0:
		# Teleport near the player at a random angle
		var angle := randf() * TAU
		var offset := Vector2.from_angle(angle) * randf_range(60.0, 120.0)
		global_position = _player.global_position + offset
		_teleport_cd = randf_range(2.5, 4.0)
		# Visual flash on teleport
		_flash = 0.3
	else:
		global_position += _dir * speed * delta


func _process_bomber(delta: float, dist: float) -> void:
	# Bomber walks toward player and explodes when close
	global_position += _dir * speed * delta
	if dist < 120.0:
		_bomb_warning += delta
	else:
		_bomb_warning = maxf(0.0, _bomb_warning - delta * 0.5)
	# Return true when about to explode so arena can handle it


func should_explode() -> bool:
	return kind == Kind.BOMBER and _bomb_warning >= 0.8


func shove_multiplier_mass() -> float:
	return mass


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var body: Color = s["body"]
	var rim: Color = s["rim"]
	var eye: Color = s["eye"]
	if _flash > 0.0:
		body = body.lerp(Color.WHITE, _flash / 0.12)
	if elite:
		var pulse := 0.30 + 0.18 * sin(Time.get_ticks_msec() * 0.006)
		draw_arc(Vector2.ZERO, radius + 9.0, 0.0, TAU, 40, Color(1.0, 0.35, 0.75, pulse), 2.5)
		draw_arc(Vector2.ZERO, radius + 13.0, 0.0, TAU, 40, Color(1.0, 0.35, 0.75, pulse * 0.4), 1.2)
	draw_circle(Vector2.ZERO, radius + 5.0, Color(rim.r, rim.g, rim.b, 0.25))
	draw_circle(Vector2.ZERO, radius, body)
	# Bomber warning pulse
	if kind == Kind.BOMBER and _bomb_warning > 0.0:
		var pulse := _bomb_warning / 0.8
		var col := Color(1.0, 0.3, 0.0, pulse * 0.5)
		draw_arc(Vector2.ZERO, radius + 8.0 * pulse, 0.0, TAU, 30, col, 2.5 * pulse)
	# Phantom shimmer
	if kind == Kind.PHANTOM:
		var shimmer := 0.15 + 0.1 * sin(Time.get_ticks_msec() * 0.008)
		draw_circle(Vector2.ZERO, radius + 3.0, Color(0.4, 0.9, 1.0, shimmer))
	# windup telegraph — the spitter swells before it lobs
	if _windup >= 0.0:
		var swell := 1.0 + 0.22 * (1.0 - _windup / 0.36)
		draw_circle(Vector2.ZERO, radius * swell, Color(rim.r, rim.g, rim.b, 0.5))
		draw_circle(Vector2.ZERO, radius * 0.5 * swell, Color(eye.r, eye.g, eye.b, 0.55))
	# Eyes track the player.
	var side := Vector2(-_dir.y, _dir.x)
	if kind == Kind.BRUTE:
		draw_circle(_dir * radius * 0.34, radius * 0.22, Color(eye.r, eye.g, eye.b, 0.45))
		draw_circle(_dir * radius * 0.34, radius * 0.13, eye)
	else:
		var eye_fwd := _dir * radius * 0.38
		for offset in [-1.0, 1.0]:
			var pos: Vector2 = eye_fwd + side * offset * radius * 0.3
			draw_circle(pos, radius * 0.16, Color(eye.r, eye.g, eye.b, 0.4))
			draw_circle(pos, radius * 0.09, eye)
