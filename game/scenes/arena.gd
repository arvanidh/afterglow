extends Node2D
## THE PROMENADE — sector 0 (GDD §9 biome 1). Run director: floating joystick
## (§6), seeded spawn director (§12.3 determinism-lite), pooled entities,
## collision passes, juice (§7.3 basics), and the results flow.

const MAX_ACTIVE_ENEMIES := 90
const SPAWN_RING_MIN := 800.0
const SPAWN_RING_MAX := 920.0
const JOY_RADIUS := 70.0

var world: Node2D
var grid: GridLayer
var camera: Camera2D
var player: PlayerSpark
var hud: RunHud

var rng := RandomNumberGenerator.new()
var run_seed := 0
var enemies: Array[ShadowEnemy] = []      # active only
var _enemy_pool: Array[ShadowEnemy] = []
var bolts: Array[PulseBolt] = []
var motes: Array[LightMote] = []

var _weapon: PulseWeapon
var _spawn_timer := 1.2
var _pack_timer := 18.0
var _joy_base := Vector2.ZERO
var _joy_vec := Vector2.ZERO
var _joy_index := -1
var _joy_node: Node2D
var _shake := 0.0
var _ending := false
var _results_ready := false


func _ready() -> void:
	run_seed = randi()
	rng.seed = run_seed
	GameState.change_state(GameState.State.RUN)

	world = Node2D.new()
	add_child(world)
	grid = GridLayer.new()
	world.add_child(grid)

	player = PlayerSpark.new()
	player.took_damage.connect(_on_player_took_damage)
	world.add_child(player)
	_weapon = PulseWeapon.new()
	_weapon.arena = self
	player.add_child(_weapon)

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	add_child(camera)
	camera.make_current()

	_joy_node = Node2D.new()
	var joy_layer := CanvasLayer.new()
	joy_layer.layer = 8
	joy_layer.add_child(_joy_node)
	_joy_node.draw.connect(_draw_joystick)
	add_child(joy_layer)

	hud = RunHud.new()
	add_child(hud)

	Analytics.design_event("run_start", {"seed": seed_hex(), "biome": "promenade"})


func seed_hex() -> String:
	return "%05X" % (absi(run_seed) % 1048576)


func _exit_tree() -> void:
	Engine.time_scale = 1.0  # safety — never leak slow-mo across scenes


# ---------------------------------------------------------------- input / joystick (§6)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _joy_index == -1 and not _ending \
				and event.position.x < get_viewport_rect().size.x * 0.5:
			_joy_index = event.index
			_joy_base = event.position
			_joy_vec = Vector2.ZERO
			_joy_node.queue_redraw()
		elif not event.pressed and event.index == _joy_index:
			_joy_index = -1
			_joy_vec = Vector2.ZERO
			if player != null:
				player.move_dir = Vector2.ZERO
			_joy_node.queue_redraw()
	elif event is InputEventScreenDrag and event.index == _joy_index:
		var v: Vector2 = event.position - _joy_base
		_joy_vec = v.limit_length(JOY_RADIUS)
		if _joy_vec.length() > 6.0:
			player.move_dir = _joy_vec / JOY_RADIUS
		else:
			player.move_dir = Vector2.ZERO
		_joy_node.queue_redraw()
	elif _ending and _results_ready and event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/boot.tscn")


func _draw_joystick() -> void:
	if _joy_index == -1:
		return
	_joy_node.draw_circle(_joy_base, JOY_RADIUS, Color(1, 1, 1, 0.05))
	_joy_node.draw_arc(_joy_base, JOY_RADIUS, 0.0, TAU, 48, Color(0.0, 0.94, 1.0, 0.25), 2.0)
	_joy_node.draw_circle(_joy_base + _joy_vec, 26.0, Color(0.0, 0.94, 1.0, 0.30))
	_joy_node.draw_circle(_joy_base + _joy_vec, 14.0, Color(0.75, 1.0, 1.0, 0.85))


# ---------------------------------------------------------------- main loop

func _process(delta: float) -> void:
	RunState.run_time += delta if not _ending else 0.0
	_director(delta)
	_bolts_vs_enemies()
	_enemies_vs_player()
	_shake = maxf(0.0, _shake - delta * 22.0)
	world.position = Vector2(rng.randf_range(-_shake, _shake), rng.randf_range(-_shake, _shake))
	camera.position = player.global_position
	grid.track(player.global_position, get_viewport_rect().size * 0.5 + Vector2(80, 80))
	hud.tick(RunState.run_time)
	hud.fade_vignette(delta)


func _director(delta: float) -> void:
	if _ending:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = lerpf(1.35, 0.33, clampf(RunState.run_time / 300.0, 0.0, 1.0))
		var batch := 1 + int(RunState.run_time / 75.0)
		for i in range(batch):
			_spawn_one(ShadowEnemy.Kind.SHADE)
	_pack_timer -= delta
	if _pack_timer <= 0.0:
		_pack_timer = rng.randf_range(13.0, 21.0)
		var pack_center: Vector2 = _ring_point()
		for i in range(rng.randi_range(4, 6)):
			_spawn_one(ShadowEnemy.Kind.SWARMLET, pack_center + Vector2(rng.randf_range(-46, 46), rng.randf_range(-46, 46)))


func _speed_scale() -> float:
	return minf(1.0 + RunState.run_time / 600.0, 1.35)


func _ring_point() -> Vector2:
	var ang := rng.randf() * TAU
	return player.global_position + Vector2.from_angle(ang) * rng.randf_range(SPAWN_RING_MIN, SPAWN_RING_MAX)


func _spawn_one(kind: ShadowEnemy.Kind, at: Vector2 = Vector2.INF) -> void:
	if enemies.size() >= MAX_ACTIVE_ENEMIES or _ending:
		return
	var e: ShadowEnemy = _enemy_pool.pop_back() if not _enemy_pool.is_empty() else ShadowEnemy.new()
	if e.get_parent() == null:
		world.add_child(e)
	e.setup(kind, player, rng)
	e.speed *= _speed_scale()
	e.global_position = at if at != Vector2.INF else _ring_point()
	enemies.append(e)


func nearest_enemy(pos: Vector2, max_dist: float) -> ShadowEnemy:
	var best: ShadowEnemy = null
	var best_d := max_dist
	for e in enemies:
		var d: float = pos.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func acquire_bolt() -> PulseBolt:
	for b in bolts:
		if not b.active:
			return b
	var b := PulseBolt.new()
	world.add_child(b)
	bolts.append(b)
	return b


# ---------------------------------------------------------------- collisions & juice

func _bolts_vs_enemies() -> void:
	for b in bolts:
		if not b.active:
			continue
		for e in enemies:
			if not e.active:
				continue
			if b.global_position.distance_squared_to(e.global_position) < pow(e.radius + 6.0, 2.0):
				b.deactivate()
				if e.take_hit(b.damage):
					_kill_enemy(e)
				break


func _enemies_vs_player() -> void:
	if _ending:
		return
	for e in enemies:
		if not e.active:
			continue
		var contact := e.radius + PlayerSpark.RADIUS - 3.0
		if e.global_position.distance_squared_to(player.global_position) < contact * contact:
			if player.try_take_damage(e.damage, e.global_position):
				e.global_position += (e.global_position - player.global_position).normalized() * 14.0


func _kill_enemy(e: ShadowEnemy) -> void:
	RunState.kills += 1
	var eye: Color = ShadowEnemy.STATS[e.kind]["eye"]
	_burst(e.global_position, eye)
	var mote_count: int = ShadowEnemy.STATS[e.kind]["gems"]
	for i in range(mote_count):
		_acquire_mote().drop(e.global_position)
	enemies.erase(e)
	e.release()
	_enemy_pool.append(e)


func _acquire_mote() -> LightMote:
	for m in motes:
		if not m.active:
			return m
	var m := LightMote.new()
	m.arena = self
	world.add_child(m)
	motes.append(m)
	return m


func _burst(at: Vector2, col: Color) -> void:
	var p := CPUParticles2D.new()
	p.position = world.to_local(at)
	p.one_shot = true
	p.emitting = true
	p.amount = 14
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 210.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.5
	p.color = col
	world.add_child(p)
	get_tree().create_timer(0.9).timeout.connect(p.queue_free)


func _on_player_took_damage(current_hp: int) -> void:
	hud.flash_damage()
	hud.refresh_hp()
	_shake = 7.0
	if current_hp <= 0:
		_begin_death()


func _begin_death() -> void:
	_ending = true
	Engine.time_scale = 0.25
	Analytics.design_event("run_end", {"time": snappedf(RunState.run_time, 0.1), "kills": RunState.kills})
	await get_tree().create_timer(0.9, true, false, true).timeout
	Engine.time_scale = 1.0
	GameState.change_state(GameState.State.RESULTS)
	SaveSystem.mark_run_finished()
	hud.build_results(RunState.run_time, seed_hex())
	await get_tree().create_timer(0.6, true, false, true).timeout
	_results_ready = true
