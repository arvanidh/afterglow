class_name FunnyEnemy
extends Node2D
## Weird, funny enemies with comedic behaviors and death effects.
## JOKER: laughs and drops confetti
## RUBBER_DUCK: bounces erratically, squeaks when hit
## PIÑATA: explodes into gems + confetti on death

enum Kind { JOKER, RUBBER_DUCK, PIÑATA }

const STATS := {
	Kind.JOKER: {
		"hp": 2, "speed": 85.0, "radius": 14.0, "damage": 1,
		"body": Color("1a1a2e"), "rim": Color("3d1a6e"), "eye": Color(1.0, 0.18, 0.53),
		"gems": 3,
	},
	Kind.RUBBER_DUCK: {
		"hp": 1, "speed": 140.0, "radius": 12.0, "damage": 1,
		"body": Color("2e2a0d"), "rim": Color("5a4a10"), "eye": Color(1.0, 0.9, 0.0),
		"gems": 2,
	},
	Kind.PIÑATA: {
		"hp": 3, "speed": 60.0, "radius": 16.0, "damage": 1,
		"body": Color("0d2e1a"), "rim": Color("105a2a"), "eye": Color(0.0, 1.0, 0.5),
		"gems": 8,
	},
}

var kind := Kind.JOKER
var hp := 2
var speed := 85.0
var radius := 14.0
var damage := 1
var active := false
var elite := false
var melee_ready_ms := 0

var _player: Node2D
var _flash := 0.0
var _dir := Vector2.RIGHT
var _bounce_timer := 0.0
var _bounce_dir := Vector2.ZERO
var _laugh_timer := 0.0
var _squeak_cd := 0.0


func setup(p_kind: Kind, player: Node2D, _rng: RandomNumberGenerator, as_elite := false) -> void:
	kind = p_kind
	_player = player
	elite = as_elite
	var s: Dictionary = STATS[kind]
	hp = int(s["hp"])
	speed = float(s["speed"])
	radius = float(s["radius"])
	damage = int(s["damage"])
	active = true
	_bounce_timer = 0.0
	_laugh_timer = 0.0
	_squeak_cd = 0.0
	show()


func kind_name() -> String:
	return ["joker", "rubber_duck", "pinata"][kind]


func take_hit(dmg: int) -> bool:
	hp -= dmg
	_flash = 0.12
	queue_redraw()
	if kind == Kind.RUBBER_DUCK:
		Audio.play("squeak", -2.0)
		# Bounce away when hit
		_bounce_dir = (_player.global_position - global_position).normalized() * -1.0
		_bounce_timer = 0.3
	return hp <= 0


func shove(dir: Vector2, force: float) -> void:
	global_position += dir * force * 0.5


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	_flash = maxf(0.0, _flash - delta)
	_laugh_timer -= delta
	_squeak_cd -= delta
	
	match kind:
		Kind.JOKER:
			_process_joker(delta)
		Kind.RUBBER_DUCK:
			_process_duck(delta)
		Kind.PIÑATA:
			_process_pinata(delta)
	queue_redraw()


func _process_joker(delta: float) -> void:
	# Joker: walks toward player, laughs periodically
	global_position += (_player.global_position - global_position).normalized() * speed * delta
	_laugh_timer -= delta
	if _laugh_timer <= 0.0:
		_laugh_timer = randf_range(1.5, 3.0)
		Audio.play("honk", -3.0)  # Laugh sound
		# Confetti particles
		var p := CPUParticles2D.new()
		p.position = Vector2.ZERO
		p.one_shot = true; p.emitting = true; p.amount = 8
		p.lifetime = 0.5; p.explosiveness = 1.0; p.spread = 180.0
		p.gravity = Vector2(0, 100.0)
		p.initial_velocity_min = 40.0; p.initial_velocity_max = 80.0
		p.color = Color(randf(), randf(), randf(), 0.9)
		add_child(p)
		get_tree().create_timer(0.8).timeout.connect(p.queue_free)


func _process_duck(delta: float) -> void:
	# Rubber Duck: bounces erratically, changes direction frequently
	_bounce_timer -= delta
	if _bounce_timer <= 0.0:
		_bounce_timer = randf_range(0.2, 0.6)
		_bounce_dir = Vector2.from_angle(randf() * TAU) * speed
		# Occasional squeak
		if _squeak_cd <= 0.0 and randf() < 0.3:
			Audio.play("squeak", -4.0)
			_squeak_cd = 0.5
	# Move toward player but with random bouncing
	var to_player := (_player.global_position - global_position).normalized() * speed * 0.5
	global_position += (to_player + _bounce_dir * 0.5) * delta


func _process_pinata(delta: float) -> void:
	# Piñata: slow, takes lots of hits, drops gems when damaged
	global_position += (_player.global_position - global_position).normalized() * speed * delta


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var body: Color = s["body"]
	var rim: Color = s["rim"]
	var eye: Color = s["eye"]
	if _flash > 0.0:
		body = body.lerp(Color.WHITE, _flash / 0.12)
	
	match kind:
		Kind.JOKER:
			# Round body with a smile
			draw_circle(Vector2.ZERO, radius, body)
			draw_circle(Vector2.ZERO, radius + 3.0, Color(rim.r, rim.g, rim.b, 0.25))
			# Eyes
			var side := Vector2(-_dir.y, _dir.x)
			var eye_fwd := _dir * radius * 0.3
			for offset in [-1.0, 1.0]:
				var pos: Vector2 = eye_fwd + side * offset * radius * 0.3
				draw_circle(pos, radius * 0.18, Color(1.0, 0.18, 0.53, 0.6))
				draw_circle(pos, radius * 0.1, eye)
			# Smile
			var smile_pts := PackedVector2Array()
			for i in range(8):
				var a := -0.8 + float(i) * 1.6 / 7.0
				smile_pts.append(Vector2(sin(a) * radius * 0.4, radius * 0.15 + cos(a) * radius * 0.2))
			draw_polyline(smile_pts, Color(1.0, 0.3, 0.6), 1.5)
			# Hat
			draw_rect(Rect2(-5, -radius - 10, 10, 12), Color(0.6, 0.2, 0.8))
			draw_rect(Rect2(-8, -radius - 2, 16, 4), Color(0.7, 0.3, 0.9))
		
		Kind.RUBBER_DUCK:
			# Duck body
			draw_circle(Vector2.ZERO, radius, Color(1.0, 0.85, 0.0))
			draw_circle(Vector2.ZERO, radius + 2.0, Color(1.0, 0.9, 0.3, 0.2))
			# Beak
			var beak := _dir * (radius + 4.0)
			draw_circle(beak, 4.0, Color(1.0, 0.5, 0.0))
			# Eye
			var eye_pos := _dir * radius * 0.4 + Vector2(-_dir.y, _dir.x) * radius * 0.2
			draw_circle(eye_pos, 3.0, Color.WHITE)
			draw_circle(eye_pos + _dir * 1.0, 1.5, Color.BLACK)
			# Bounce indicator
			if _bounce_timer > 0.0:
				draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 20, Color(1.0, 0.9, 0.0, 0.4), 1.5)
		
		Kind.PIÑATA:
			# Colorful piñata body
			var t := Time.get_ticks_msec() * 0.003
			for i in range(5):
				var col := Color.from_hsv(fmod(float(i) * 0.2 + t * 0.1, 1.0), 0.7, 0.8)
				draw_circle(Vector2.from_angle(float(i) * TAU / 5.0) * radius * 0.4, radius * 0.35, Color(col.r, col.g, col.b, 0.4))
			draw_circle(Vector2.ZERO, radius, body)
			draw_circle(Vector2.ZERO, radius + 3.0, Color(0.0, 1.0, 0.5, 0.2))
			# Eyes (scared)
			var eye_pos_l := Vector2(-radius * 0.25, -radius * 0.15)
			var eye_pos_r := Vector2(radius * 0.25, -radius * 0.15)
			draw_circle(eye_pos_l, 3.0, Color.WHITE)
			draw_circle(eye_pos_l + Vector2(0, 1), 1.5, Color.BLACK)
			draw_circle(eye_pos_r, 3.0, Color.WHITE)
			draw_circle(eye_pos_r + Vector2(0, 1), 1.5, Color.BLACK)
			# Crack lines (shows damage)
			if hp <= 2:
				draw_line(Vector2(-3, -radius * 0.5), Vector2(5, radius * 0.3), Color(1, 1, 0, 0.5), 1.0)
			if hp <= 1:
				draw_line(Vector2(2, -radius * 0.4), Vector2(-4, radius * 0.5), Color(1, 0.5, 0, 0.5), 1.0)
