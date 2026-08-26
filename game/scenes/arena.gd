extends Node2D
## THE PROMENADE v2 — run director. Fixed-count levels (clear → harder),
## XP motes → mid-run LEVEL-UP drafts (build-crafting §5.5), elites, spitters,
## brutes, combo meter, floating joystick anywhere on screen (§6), full juice.
## Env AG_AUTOPICK=1 auto-resolves drafts for headless smoke tests.

const MAX_ACTIVE_ENEMIES := 90
const SPAWN_RING_MIN := 320.0
const SPAWN_RING_MAX := 420.0
const JOY_RADIUS := 70.0
const BETWEEN_LEVELS := 2.4
const COMBO_WINDOW := 3.2

var WEAPON_CLASSES := {"pulse": PulseWeapon, "orbit": OrbitBlades, "nova": NovaBurst}

var world: Node2D
var grid: GridLayer
var camera: Camera2D
var player: PlayerSpark
var hud: RunHud
var weapon: Node = null

var rng := RandomNumberGenerator.new()
var run_seed := 0
var enemies: Array[ShadowEnemy] = []
var _enemy_pool: Array[ShadowEnemy] = []
var bolts: Array[PulseBolt] = []
var orbs: Array[SpitOrb] = []
var motes: Array[LightMote] = []
var pickups: Array[Pickup] = []
var rings: Array[FxRing] = []

# progression
var level := 1
var plevel := 1
var xp := 0
var owned_guns: Array[String] = ["pulse"]
var gun_lv := {"pulse": 1}
var passives := {}
var _shard_bank := 0.0

# director
var _spawn_queue: Array[int] = []
var _spawn_timer := 1.0
var _between_timer := 0.0
var _in_between := false
var _clear_drop_flip := false
var _overdrive_left := 0.0

# combo
var streak := 0
var _streak_t := 0.0

# input
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
	player.dashed.connect(_on_player_dashed)
	world.add_child(player)
	# Apply permanent upgrades from SaveSystem
	_apply_permanent_upgrades()

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
	hud.set_camera(camera)
	hud.layout_dash_button(get_viewport_rect().size)
	hud.dash_requested.connect(_on_dash_pressed)

	_equip_weapon("pulse", true)
	_build_level(1)
	Audio.play("level_start")
	hud.show_banner("LEVEL 1", Color(0.0, 0.94, 1.0))
	hud.refresh_hp(player.effective_max_hp())
	hud.set_xp(0.0, plevel)
	hud.set_gems(RunState.gems_earned)
	Analytics.design_event("run_start", {"seed": seed_hex(), "biome": "promenade"})


func _apply_permanent_upgrades() -> void:
	var hp_bonus := SaveSystem.get_upgrade_level("max_hp")
	RunState.max_hp = 3 + hp_bonus
	RunState.hp = RunState.max_hp

func seed_hex() -> String:
	return "%05X" % (absi(run_seed) % 1048576)


func _exit_tree() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


# ---------------------------------------------------------------- levels (fixed enemy counts)

func _build_level(n: int) -> void:
	_spawn_queue.clear()
	var shades := mini(3 + n * 2, 30)
	for i in range(shades):
		_spawn_queue.append(ShadowEnemy.Kind.SHADE)
	if n >= 2:
		var swarmlets := mini((n - 1) * 3, 26)
		for i in range(swarmlets):
			_spawn_queue.append(ShadowEnemy.Kind.SWARMLET)
	if n >= 2:
		var spitters := mini(1 + (n - 2) * 2, 10)
		for i in range(spitters):
			_spawn_queue.append(ShadowEnemy.Kind.SPITTER)
	if n >= 3:
		var brutes := mini(n - 2, 6)
		for i in range(brutes):
			_spawn_queue.append(ShadowEnemy.Kind.BRUTE)
	# Fisher-Yates with the run's seeded rng — same layout every replay of a seed.
	for i in range(_spawn_queue.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := _spawn_queue[i]
		_spawn_queue[i] = _spawn_queue[j]
		_spawn_queue[j] = tmp
	level = n
	_in_between = false
	_spawn_timer = 0.3
	hud.set_level(n, _spawn_queue.size())


func _director(delta: float) -> void:
	if _ending or get_tree().paused:
		return
	if _in_between:
		_between_timer -= delta
		if _between_timer <= 0.0:
			_build_level(level + 1)
			Audio.play("level_start")
			hud.show_banner("LEVEL %d" % level, Color(0.0, 0.94, 1.0))
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0 and not _spawn_queue.is_empty():
		_spawn_timer = clampf(0.55 - level * 0.03, 0.15, 0.55)
		_spawn_one(_spawn_queue.pop_back())
	if _spawn_queue.is_empty() and _alive_enemies() == 0 and not get_tree().paused:
		_level_cleared()


func _alive_enemies() -> int:
	var n := 0
	for e in enemies:
		if e.active:
			n += 1
	return n


func _level_cleared() -> void:
	_in_between = true
	_between_timer = BETWEEN_LEVELS
	RunState.hp = mini(RunState.hp + 1, player.effective_max_hp())
	hud.refresh_hp(player.effective_max_hp())
	Audio.play("level_clear", -2.0)
	hud.show_banner("LEVEL %d CLEAR  ·  +1 HP" % level, Color(1.0, 0.72, 0.0), 1.5)
	# Bonus gem drop on level clear
	Analytics.design_event("level_clear", {"level": level})
	_clear_drop_flip = not _clear_drop_flip
	# Level clear: drop 2 powerups for variety
	_acquire_pickup().spawn(Pickup.Kind.CRATE, player.global_position + Vector2.from_angle(rng.randf() * TAU) * 50.0)
	_acquire_pickup().spawn(_random_orb_kind(), player.global_position + Vector2.from_angle(rng.randf() * TAU) * 70.0)
	RunState.add_gems(2)
	hud.spawn_float(player.global_position, "+2 GEMS", Color(1.0, 0.72, 0.0))


func remaining_count() -> int:
	return _spawn_queue.size() + _alive_enemies()


# ---------------------------------------------------------------- spawning

func _speed_scale() -> float:
	return minf(1.0 + RunState.run_time / 600.0, 1.35)


func _ring_point() -> Vector2:
	var ang := rng.randf() * TAU
	return player.global_position + Vector2.from_angle(ang) * rng.randf_range(SPAWN_RING_MIN, SPAWN_RING_MAX)


func _spawn_one(kind: ShadowEnemy.Kind) -> void:
	if enemies.size() >= MAX_ACTIVE_ENEMIES or _ending:
		return
	var e: ShadowEnemy = _enemy_pool.pop_back() if not _enemy_pool.is_empty() else ShadowEnemy.new()
	if e.get_parent() == null:
		e.spit_requested.connect(_on_spit_requested)
		world.add_child(e)
	var elite := level >= 3 and rng.randf() < minf(0.02 * (level - 2), 0.20)
	if elite:
		Audio.play("fanfare", -4.0)
	e.setup(kind, player, rng, elite)
	e.speed *= _speed_scale()
	e.global_position = _ring_point()
	enemies.append(e)


func nearest_enemy(pos: Vector2, max_dist: float) -> ShadowEnemy:
	var best: ShadowEnemy = null
	var best_d := max_dist
	for e in enemies:
		if not e.active:
			continue
		var d: float = pos.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


# ---------------------------------------------------------------- guns

func _equip_weapon(id: String, first := false) -> void:
	if weapon != null:
		weapon.queue_free()
		weapon = null
	var cls = WEAPON_CLASSES[id]
	weapon = cls.new()
	weapon.arena = self
	if gun_lv.has(id):
		weapon.level = gun_lv[id]
	player.add_child(weapon)
	# Reset cooldown so shooting resumes instantly
	# Reset cooldown - use set() which handles missing properties gracefully
	weapon.set("_cd", 0.0)
	hud.set_gun(weapon.DISPLAY_NAME, weapon.level)


func swap_weapon_random() -> void:
	var options: Array = []
	for id: String in WEAPON_CLASSES:
		if id != current_gun_id():
			options.append(id)
	var pick: String = options[rng.randi_range(0, options.size() - 1)]
	if not owned_guns.has(pick):
		owned_guns.append(pick)
	gun_lv[pick] = maxi(int(gun_lv.get(pick, 1)), 1)
	# Always equip the new weapon but shooting resumes instantly (cooldown = 0)
	_equip_weapon(pick)
	# Overdrive boost: weapon crate also gives 4s of overdrive
	apply_overdrive(4.0)
	spawn_ring(player.global_position, 90.0, Color(0.0, 0.94, 1.0, 0.9))
	hud.show_banner(String(WEAPON_CLASSES[pick].DISPLAY_NAME).to_upper() + " + OVERDRIVE", Color(1.0, 0.72, 0.0), 0.9)


func current_gun_id() -> String:
	return "pulse" if weapon == null else String(weapon.ID)


func apply_overdrive(duration: float) -> void:
	_overdrive_left = duration


func vacuum_all_motes() -> void:
	for m in motes:
		m.force_pull = true


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


# ---------------------------------------------------------------- XP & drafts

func collect_mote(value: int) -> void:
	_shard_bank += float(mods_shard_mult())
	while _shard_bank >= 1.0:
		_shard_bank -= 1.0
		RunState.add_shards(1)
	xp += value
	var need := xp_need()
	if xp >= need:
		xp -= need
		plevel += 1
		_open_draft()


func mods_shard_mult() -> float:
	return float(player.mods.get("shard_mult", 1.0))


func xp_need() -> int:
	return 3 + plevel * 2


func _open_draft() -> void:
	if _ending:
		return
	Audio.play("levelup")
	spawn_ring(player.global_position, 120.0, Color(1.0, 0.72, 0.0, 0.9))
	hud.refresh_hp(player.effective_max_hp())
	var choices := CardDb.draw_three(owned_guns, gun_lv, passives, rng)
	if OS.get_environment("AG_AUTOPICK") == "1":
		_apply_card(choices[0])
		return
	get_tree().paused = true
	hud.show_draft(choices, _apply_card)


func _apply_card(card: Dictionary) -> void:
	var kind := String(card["kind"])
	var target := String(card["target"])
	match kind:
		"weapon_up":
			gun_lv[target] = mini(int(gun_lv.get(target, 1)) + 1, CardDb.WEAPON_MAX_LV)
			if current_gun_id() == target and weapon != null:
				weapon.level_up()
				hud.set_gun(String(WEAPON_CLASSES[target].DISPLAY_NAME), weapon.level)
		"weapon_new":
			if not owned_guns.has(target):
				owned_guns.append(target)
			gun_lv[target] = maxi(int(gun_lv.get(target, 1)), 1)
			_equip_weapon(target)
		"passive":
			passives[target] = int(passives.get(target, 0)) + 1
			player.apply_passive(target)
			hud.refresh_hp(player.effective_max_hp())
	get_tree().paused = false
	hud.show_banner("+ %s" % String(card["title"]), CardDb.RARITY_COLORS[card["rarity"]], 0.9)
	hud.set_xp(float(xp) / float(xp_need()), plevel)
	hud.set_gems(RunState.gems_earned)
	Analytics.design_event("card_pick", {"card": target, "kind": kind, "plevel": plevel})
	spawn_ring(player.global_position, 70.0, Color(CardDb.RARITY_COLORS[card["rarity"]].r, CardDb.RARITY_COLORS[card["rarity"]].g, CardDb.RARITY_COLORS[card["rarity"]].b, 0.9))


# ---------------------------------------------------------------- main loop

func _process(delta: float) -> void:
	if hud == null:
		return
	if get_tree().paused:
		return
	RunState.run_time += delta if not _ending else 0.0
	_overdrive_left = maxf(0.0, _overdrive_left - delta)
	var od := 1.85 if _overdrive_left > 0.0 else 1.0
	# Always reset rate_scale — prevents drift from overdrive expiry
	if weapon != null:
		weapon.rate_scale = od
	if _overdrive_left > 0.0:
		hud.set_powerup("OVERDRIVE %ds" % ceili(_overdrive_left))
	elif hud.powerup_label.text != "":
		hud.set_powerup("")
	_streak_t -= delta
	if _streak_t <= 0.0 and streak > 0:
		streak = 0
		hud.clear_combo()
	_director(delta)
	_bolts_vs_enemies()
	_orbs_tick(delta)
	_enemies_vs_player()
	_shake = maxf(0.0, _shake - delta * 22.0)
	world.position = Vector2(rng.randf_range(-_shake, _shake), rng.randf_range(-_shake, _shake))
	camera.position = player.global_position
	grid.track(player.global_position, get_viewport_rect().size * 0.5 + Vector2(80, 80))
	hud.tick(RunState.run_time)
	hud.update_radar(enemies, player.global_position)
	hud.set_xp(float(xp) / float(xp_need()), plevel)
	hud.set_gems(RunState.gems_earned)
	hud.fade_vignette(delta)
	var dfrac := -1.0 if player.dash_cd <= 0.0 else player.dash_cd / (PlayerSpark.DASH_BASE_CD * float(player.mods["dash_cd_mult"]))
	hud.tick_dash(dfrac)


# ---------------------------------------------------------------- input / joystick (§6)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _joy_index == -1 and not _ending and not get_tree().paused:
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
		if v.length() > JOY_RADIUS:
			# sliding anchor — the base follows a long drag so your thumb never
			# runs out of stick
			_joy_base += (v - v.limit_length(JOY_RADIUS)) * 0.85
			v = v.limit_length(JOY_RADIUS)
		_joy_vec = v
		if _joy_vec.length() > 7.0:
			player.move_dir = _joy_vec / JOY_RADIUS
		else:
			player.move_dir = Vector2.ZERO
		_joy_node.queue_redraw()
	elif _ending and _results_ready and event is InputEventScreenTouch and event.pressed:
		get_tree().change_scene_to_file("res://scenes/boot.tscn")


func _on_dash_pressed() -> void:
	if _ending or get_tree().paused:
		return
	var dir := player.move_dir if player.move_dir.length_squared() > 0.01 else player.facing
	if player.try_dash(dir):
		shake(3.0)


func _draw_joystick() -> void:
	if _joy_index == -1:
		return
	_joy_node.draw_circle(_joy_base, JOY_RADIUS, Color(1, 1, 1, 0.05))
	_joy_node.draw_arc(_joy_base, JOY_RADIUS, 0.0, TAU, 48, Color(0.0, 0.94, 1.0, 0.25), 2.0)
	_joy_node.draw_circle(_joy_base + _joy_vec, 26.0, Color(0.0, 0.94, 1.0, 0.30))
	_joy_node.draw_circle(_joy_base + _joy_vec, 14.0, Color(0.75, 1.0, 1.0, 0.85))


# ---------------------------------------------------------------- collisions

func _bolts_vs_enemies() -> void:
	for b in bolts:
		if not b.active:
			continue
		for e in enemies:
			if not e.active:
				continue
			if b.global_position.distance_squared_to(e.global_position) < pow(e.radius + 6.0, 2.0):
				b.deactivate()
				Audio.play("hit", -8.0)
				hud.spawn_float(e.global_position, str(b.damage), Color(0.85, 0.95, 1.0))
				if e.take_hit(b.damage):
					kill_enemy(e)
				break


func _orbs_tick(delta: float) -> void:
	if _ending:
		return
	for o in orbs:
		if o.active and o.global_position.distance_squared_to(player.global_position) < pow(player.RADIUS + 8.0, 2.0):
			o.splash()


func _enemies_vs_player() -> void:
	if _ending:
		return
	for e in enemies:
		if not e.active:
			continue
		var contact := e.radius + PlayerSpark.RADIUS - 3.0
		if e.global_position.distance_squared_to(player.global_position) < contact * contact:
			if player.try_take_damage(e.damage, e.global_position):
				e.shove((e.global_position - player.global_position).normalized(), 14.0)


func _on_spit_requested(from_pos: Vector2, target_pos: Vector2) -> void:
	if _ending:
		return
	Audio.play("spit", -5.0)
	_acquire_orb().launch(from_pos, target_pos)


func _acquire_orb() -> SpitOrb:
	for o in orbs:
		if not o.active:
			return o
	var o := SpitOrb.new()
	world.add_child(o)
	orbs.append(o)
	return o


# ---------------------------------------------------------------- kills, FX, drops

func kill_enemy(e: ShadowEnemy) -> void:
	RunState.kills += 1
	streak += 1
	_streak_t = COMBO_WINDOW
	if streak >= 3:
		hud.combo_pop(streak)
		# Funny combo sounds
		if streak == 3:
			Audio.play("combo3", -5.0)
		elif streak == 5:
			Audio.play("combo5", -4.0)
		elif streak == 10:
			Audio.play("combo10", -3.0)
		elif streak % 10 == 0:
			Audio.play("combo10", -2.0)
	if streak > 0 and streak % 5 == 0:
		for i in range(mini(1 + streak / 10, 3)):
			_acquire_mote().drop(e.global_position, 1)
		# Streak milestone: guaranteed powerup drop!
		_acquire_pickup().spawn(_random_orb_kind(), e.global_position)
		hud.spawn_float(e.global_position, "STREAK BONUS", Color(1.0, 0.72, 0.0))
		shake(2.0)
	var eye: Color = ShadowEnemy.STATS[e.kind]["eye"]
	_burst(e.global_position, eye)
	spawn_ring(e.global_position, 44.0, Color(eye.r, eye.g, eye.b, 0.85))
	# Funny kill sound per enemy type
	match e.kind:
		ShadowEnemy.Kind.SWARMLET:
			Audio.play("pop", -3.0)
		ShadowEnemy.Kind.SHADE:
			Audio.play("splat", -4.0)
		ShadowEnemy.Kind.SPITTER:
			Audio.play("squeak", -3.0)
		ShadowEnemy.Kind.BRUTE:
			Audio.play("crunch", -2.0)
		_:
			Audio.play("splat2", -4.0)
	if e.kind == ShadowEnemy.Kind.BRUTE:
		Audio.play("thud", -2.0)
		shake(5.0)
		hud.spawn_float(e.global_position, "BRUTE DOWN", Color(1.0, 0.45, 0.2))
	var gems := int(ShadowEnemy.STATS[e.kind]["gems"]) * (3 if e.elite else 1)
	for i in range(gems):
		_acquire_mote().drop(e.global_position, 1)
		# Gem drops: every 5 kills = 1 gem, elites always = 2 gems
	if RunState.kills % 5 == 0:
		RunState.add_gems(1)
		hud.spawn_float(e.global_position, "+1 GEM", Color(1.0, 0.72, 0.0))
	elif e.elite:
		RunState.add_gems(2)
		hud.spawn_float(e.global_position, "+2 GEMS", Color(1.0, 0.72, 0.0))
	# drops: elites always pay out; normal shadows rarely
	if e.elite:
		_acquire_pickup().spawn(Pickup.Kind.CRATE if rng.randf() < 0.35 else _random_orb_kind(), e.global_position)
	else:
		var r := rng.randf()
		if r < 0.03:
			_acquire_pickup().spawn(Pickup.Kind.CRATE, e.global_position)
		elif r < 0.08:
			_acquire_pickup().spawn(_random_orb_kind(), e.global_position)
	enemies.erase(e)
	e.release()
	_enemy_pool.append(e)
	if not _in_between and not _ending:
		hud.set_level(level, remaining_count())


func _random_orb_kind() -> Pickup.Kind:
	return [Pickup.Kind.OVERDRIVE, Pickup.Kind.SHIELD, Pickup.Kind.MAGNET][rng.randi_range(0, 2)] as Pickup.Kind


func acquire_bolt() -> PulseBolt:
	for b in bolts:
		if not b.active:
			return b
	var b := PulseBolt.new()
	world.add_child(b)
	bolts.append(b)
	return b


func _acquire_mote() -> LightMote:
	for m in motes:
		if not m.active:
			return m
	var m := LightMote.new()
	m.arena = self
	world.add_child(m)
	motes.append(m)
	return m


func _acquire_pickup() -> Pickup:
	for p in pickups:
		if not p.active:
			return p
	var p := Pickup.new()
	p.arena = self
	p.z_index = 10
	world.add_child(p)
	pickups.append(p)
	return p


func spawn_ring(at: Vector2, max_radius: float, col: Color, duration := 0.28) -> void:
	var r := FxRing.new() if _free_ring() == null else _free_ring()
	if r.get_parent() == null:
		world.add_child(r)
	r.fire(world.to_local(at), max_radius, col, duration)


func _free_ring() -> FxRing:
	for r in rings:
		if not r.active:
			return r
	var r := FxRing.new()
	rings.append(r)
	return r


func _burst(at: Vector2, col: Color) -> void:
	var p := CPUParticles2D.new()
	p.position = world.to_local(at)
	p.one_shot = true
	p.emitting = true
	p.amount = 24
	p.lifetime = 0.55
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 290.0
	p.damping_min = 160.0
	p.damping_max = 260.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.8
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, col)
	p.color_ramp = ramp
	world.add_child(p)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)


# ---------------------------------------------------------------- damage & death

func _on_player_took_damage(current_hp: int) -> void:
	hud.flash_damage()
	hud.refresh_hp(player.effective_max_hp())
	shake(7.0)
	Audio.play("hurt", -3.0, 0.02)
	if current_hp <= 0:
		_begin_death()


func _on_player_dashed() -> void:
	spawn_ring(player.global_position, 40.0, Color(0.75, 1.0, 1.0, 0.7), 0.2)


func _begin_death() -> void:
	if _ending:
		return
	_ending = true
	RunState.deaths += 1
	get_tree().paused = false
	Engine.time_scale = 0.25
	Audio.play("game_over")
	Analytics.design_event("run_end", {"time": snappedf(RunState.run_time, 0.1), "kills": RunState.kills, "level": level, "plevel": plevel})
	await get_tree().create_timer(0.9, true, false, true).timeout
	Engine.time_scale = 1.0
	GameState.change_state(GameState.State.RESULTS)
	SaveSystem.mark_run_finished(level, RunState.gems_earned, RunState.run_time)
	hud.build_results(RunState.run_time, seed_hex(), level)
	await get_tree().create_timer(0.6, true, false, true).timeout
	_results_ready = true
