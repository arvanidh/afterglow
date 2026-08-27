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

var WEAPON_CLASSES := {"pulse": PulseWeapon, "orbit": OrbitBlades, "nova": NovaBurst, "lightning": LightningChain, "frost": FrostNova, "flame": FlameTrail, "plasma_storm": PlasmaStorm, "thunder_cannon": ThunderCannon, "solar_flare": SolarFlare}

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
var funny_enemies: Array[FunnyEnemy] = []
var rings: Array[FxRing] = []
var _boss: Boss = null
var _boss_active := false

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
var _powerup_timer := 8.0
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
var _last_tap_time := 0.0
const DOUBLE_TAP_CD := 0.35
var _joy_node: Node2D
var _shake := 0.0
var _ending := false
var _results_ready := false


func _ready() -> void:
	if RunState.is_daily:
		run_seed = DailyChallenge.get_today_seed()
	else:
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
	# Apply character stats
	var char_id := SaveSystem.get_selected_character()
	CharacterDb.apply_to_player(player, char_id)
	# Apply permanent upgrades from SaveSystem
	_apply_permanent_upgrades()
	# Set biome based on starting level
	_set_biome(RunState.start_level)

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
	hud.layout_pause_button(get_viewport_rect().size)
	hud.dash_requested.connect(_on_dash_pressed)

	# Equip character's starting weapon
	var char_data := CharacterDb.get_by_id(char_id)
	var start_wep: String = String(char_data["start_weapon"])
	_equip_weapon(start_wep, true)
	owned_guns = [start_wep]
	_build_level(RunState.start_level)
	Audio.play("level_start")
	hud.show_banner("LEVEL %d" % RunState.start_level, Color(0.0, 0.94, 1.0))
	hud.refresh_hp(player.effective_max_hp())
	hud.set_xp(0.0, plevel)
	hud.set_gems(RunState.gems_earned)
	Analytics.design_event("run_start", {"seed": seed_hex(), "biome": "promenade"})


func _set_biome(level_num: int) -> void:
	var biome_id := "promenade"
	if level_num > 10 and level_num <= 20:
		biome_id = "sewers"
	elif level_num > 20:
		biome_id = "sky"
	grid.set_biome(biome_id)
	Music.play_biome(biome_id)
	# Apply biome background tint
	var bg_colors := {
		"promenade": Color(0.02, 0.02, 0.04),
		"sewers": Color(0.01, 0.03, 0.01),
		"sky": Color(0.02, 0.01, 0.04),
	}
	var new_bg: Color = bg_colors.get(biome_id, Color(0.02, 0.02, 0.04))
	# Create or update background
	var bg := get_node_or_null("BG")
	if bg == null:
		bg = ColorRect.new()
		bg.name = "BG"
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.z_index = -10
		add_child(bg)
	# Animate background color transition
	var tween := create_tween()
	tween.tween_property(bg, "color", new_bg, 1.0)


func _apply_permanent_upgrades() -> void:
	var hp_bonus := SaveSystem.get_upgrade_level("max_hp")
	RunState.max_hp = 3 + hp_bonus
	# Shield Start: +1 HP
	if SaveSystem.get_upgrade_level("start_shield") > 0:
		RunState.max_hp += 1
	# Glass Cannon: -1 HP but +40% damage
	if SaveSystem.get_upgrade_level("glass_cannon") > 0:
		RunState.max_hp = maxi(RunState.max_hp - 1, 1)
		player.mods["dmg_mult"] = float(player.mods["dmg_mult"]) + 0.4
	RunState.hp = RunState.max_hp
	# Apply start weapon upgrades
	if SaveSystem.get_upgrade_level("start_weapon") > 0:
		owned_guns.append("orbit")
		gun_lv["orbit"] = 1
	if SaveSystem.get_upgrade_level("start_weapon_nova") > 0:
		owned_guns.append("nova")
		gun_lv["nova"] = 1

func seed_hex() -> String:
	return "%05X" % (absi(run_seed) % 1048576)


func kill_all_tweens() -> void:

	for tw in get_tree().get_processed_tweens():

		if tw.is_valid():

			tw.kill()



func _exit_tree() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	kill_all_tweens()


# ---------------------------------------------------------------- levels (fixed enemy counts)

func _build_level(n: int) -> void:
	_spawn_queue.clear()
	# Infinite mode: caps grow after level 30
	var inf := maxi(n - 30, 0)
	var shades := mini(3 + n * 2, 30 + inf)
	for i in range(shades):
		_spawn_queue.append(ShadowEnemy.Kind.SHADE)
	if n >= 2:
		var swarmlets := mini((n - 1) * 3, 26 + inf)
		for i in range(swarmlets):
			_spawn_queue.append(ShadowEnemy.Kind.SWARMLET)
	if n >= 2:
		var spitters := mini(1 + (n - 2) * 2, 10 + inf / 2)
		for i in range(spitters):
			_spawn_queue.append(ShadowEnemy.Kind.SPITTER)
	if n >= 3:
		var brutes := mini(n - 2, 6 + inf / 3)
		for i in range(brutes):
			_spawn_queue.append(ShadowEnemy.Kind.BRUTE)
	if n >= 4:
		var phantoms := mini((n - 3) * 2, 8 + inf / 2)
		for i in range(phantoms):
			_spawn_queue.append(ShadowEnemy.Kind.PHANTOM)
	if n >= 5:
		var bombers := mini((n - 4) * 2, 6 + inf / 3)
		for i in range(bombers):
			_spawn_queue.append(ShadowEnemy.Kind.BOMBER)
	# Funny enemies: appear from level 3+
	if n >= 3:
		var jokers := mini((n - 2) / 3, 3 + inf / 5)
		for i in range(jokers):
			_spawn_queue.append("joker")
	if n >= 4:
		var ducks := mini((n - 3) / 4, 2 + inf / 6)
		for i in range(ducks):
			_spawn_queue.append("rubber_duck")
	if n >= 6:
		var pinatas := mini((n - 5) / 5, 2 + inf / 8)
		for i in range(pinatas):
			_spawn_queue.append("pinata")
	# Boss every 10 levels: 10, 20, 30, 40, 50...
	if n > 0 and n % 10 == 0:
		_spawn_queue.clear()
	else:
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
	# Change biome when crossing level boundaries
	_set_biome(n)
	# Spawn boss every 10 levels
	if n > 0 and n % 10 == 0:
		_spawn_boss(n)


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
	# Periodic random powerup spawn on screen — faster as levels increase
	_powerup_timer -= delta
	if _powerup_timer <= 0.0 and not _ending:
		_powerup_timer = randf_range(3.0, 7.0)
		var angle := rng.randf() * TAU
		var dist := randf_range(200.0, 350.0)
		var drop_pos := player.global_position + Vector2.from_angle(angle) * dist
		_acquire_pickup().spawn(_random_orb_kind(), drop_pos)
		# Small sparkle effect
		var p := CPUParticles2D.new()
		p.position = world.to_local(drop_pos)
		p.one_shot = true
		p.emitting = true
		p.amount = 12
		p.lifetime = 0.4
		p.explosiveness = 1.0
		p.spread = 180.0
		p.gravity = Vector2.ZERO
		p.initial_velocity_min = 30.0
		p.initial_velocity_max = 80.0
		p.scale_amount_min = 1.0
		p.scale_amount_max = 3.0
		p.color = Color(1.0, 0.72, 0.0, 0.7)
		world.add_child(p)
		get_tree().create_timer(0.6).timeout.connect(p.queue_free)
	if _spawn_queue.is_empty() and _alive_enemies() == 0 and _alive_funny() == 0 and not _boss_active and not get_tree().paused:
		_level_cleared()


func _alive_enemies() -> int:
	var n := 0
	for e in enemies:
		if e.active:
			n += 1
	return n


func _level_cleared() -> void:
	# Guard: don't double-fire (boss timer + director can both trigger)
	if _in_between or _ending:
		return
	if player == null or hud == null or not is_instance_valid(player) or not is_instance_valid(hud):
		return
	_in_between = true
	_between_timer = BETWEEN_LEVELS
	RunState.hp = mini(RunState.hp + 1, player.effective_max_hp())
	hud.refresh_hp(player.effective_max_hp())
	Audio.play("level_clear", -2.0)
	shake(4.0)
	hud.flash_level_up()
	# Biome transition: fade effect when crossing boundaries
	if level == 10 or level == 20:
		var fade := ColorRect.new()
		fade.color = Color(0, 0, 0, 0)
		fade.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fade_layer := CanvasLayer.new()
		fade_layer.layer = 50
		fade_layer.add_child(fade)
		add_child(fade_layer)
		var tw := create_tween()
		tw.tween_property(fade, "color:a", 1.0, 0.5)
		tw.tween_interval(0.3)
		tw.tween_property(fade, "color:a", 0.0, 0.5)
		tw.tween_callback(fade_layer.queue_free)
		hud.show_banner("ENTERING %s" % ("NEON SEWERS" if level == 10 else "SKY RUINS"), Color(0.8, 0.4, 1.0), 2.0)
	else:
		hud.show_announcer("LEVEL CLEAR", Color(1.0, 0.72, 0.0))
	hud.show_banner("LEVEL %d CLEAR  ·  +1 HP" % level, Color(1.0, 0.72, 0.0), 1.5)
	Missions.track_level(level)
	# Bonus gem drop on level clear
	Analytics.design_event("level_clear", {"level": level})
	_clear_drop_flip = not _clear_drop_flip
	# Level clear: drop 2 powerups for variety
	_acquire_pickup().spawn(Pickup.Kind.CRATE, player.global_position + Vector2.from_angle(rng.randf() * TAU) * 50.0)
	_acquire_pickup().spawn(_random_orb_kind(), player.global_position + Vector2.from_angle(rng.randf() * TAU) * 70.0)
	RunState.add_gems(2)
	hud.spawn_float(player.global_position, "+2 GEMS", Color(1.0, 0.72, 0.0))
	# Give overdrive boost so shooting stays fast after level clear
	apply_overdrive(4.0)
	# Reset weapon cooldown so first shot fires instantly in new level
	if weapon != null:
		weapon._cd = 0.0


func remaining_count() -> int:
	return _spawn_queue.size() + _alive_enemies() + _alive_funny()


# ---------------------------------------------------------------- spawning

func _speed_scale() -> float:
	# Infinite mode: speed scales higher after level 30
	var base := 1.0 + RunState.run_time / 600.0
	var inf_bonus := 0.0 if level <= 30 else float(level - 30) * 0.02
	return minf(base + inf_bonus, 2.0)


func _ring_point() -> Vector2:
	var ang := rng.randf() * TAU
	return player.global_position + Vector2.from_angle(ang) * rng.randf_range(SPAWN_RING_MIN, SPAWN_RING_MAX)


func _spawn_boss(level_num: int) -> void:
	# Cycle bosses: Watcher(10) -> Devourer(20) -> Void(30) -> Watcher(40)...
	var boss_cycle := [Boss.Kind.WATCHER, Boss.Kind.DEVOURER, Boss.Kind.VOID]
	var boss_kind: Boss.Kind = boss_cycle[(level_num / 10 - 1) % 3]
	_boss = Boss.new()
	_boss.setup(boss_kind, player)
	_boss.died.connect(_on_boss_died)
	world.add_child(_boss)
	_boss.global_position = _ring_point()
	_boss_active = true
	# Boss intro
	Audio.play("level_start", -1.0)
	hud.show_announcer(Boss.STATS[boss_kind]["name"], Color(1.0, 0.2, 0.1))
	hud.show_banner("BOSS: %s" % Boss.STATS[boss_kind]["name"], Color(1.0, 0.2, 0.1), 2.0)
	hud.show_boss_bar(Boss.STATS[boss_kind]["name"])
	Music.play_boss()
	# Boss intro: dramatic zoom + shake
	shake(8.0)
	var orig_zoom := camera.zoom
	var tween := create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.3, 1.3), 0.3)
	tween.tween_interval(0.8)
	tween.tween_property(camera, "zoom", orig_zoom, 0.5)


func _on_boss_died(boss: Boss) -> void:
	_boss_active = false
	if hud == null or not is_instance_valid(hud):
		return
	hud.hide_boss_bar()
	# Boss death effects
	shake(12.0)
	Audio.play("elite_die", -1.0)
	hud.show_announcer("BOSS DEFEATED", Color(0.0, 1.0, 0.5))
	Missions.track_boss(Boss.STATS[boss.kind]["name"])
	# Drop lots of loot
	for i in range(5):
		_acquire_mote().drop(boss.global_position + Vector2.from_angle(randf() * TAU) * 40.0, 2)
	_acquire_pickup().spawn(Pickup.Kind.CRATE, boss.global_position + Vector2.from_angle(randf() * TAU) * 30.0)
	_acquire_pickup().spawn(_random_orb_kind(), boss.global_position + Vector2.from_angle(randf() * TAU) * 50.0)
	_acquire_pickup().spawn(_random_orb_kind(), boss.global_position + Vector2.from_angle(randf() * TAU) * 60.0)
	RunState.add_gems(10)
	hud.spawn_float(boss.global_position, "+10 GEMS", Color(1.0, 0.72, 0.0))
	# Big shockwave
	_spawn_death_shockwave(boss.global_position, Color(0.0, 1.0, 0.5, 0.8), 150.0)
	# Boss loot explosion particles
	for i in range(24):
		var p := CPUParticles2D.new()
		p.position = world.to_local(boss.global_position)
		p.one_shot = true
		p.emitting = true
		p.amount = 8
		p.lifetime = 1.2
		p.explosiveness = 1.0
		p.spread = 180.0
		p.gravity = Vector2.ZERO
		p.initial_velocity_min = 100.0
		p.initial_velocity_max = 300.0
		p.scale_amount_min = 3.0
		p.scale_amount_max = 8.0
		p.color = Color(randf(), randf(), 0.3, 0.9)
		world.add_child(p)
		get_tree().create_timer(2.0).timeout.connect(p.queue_free)
	_boss.release()
	_boss = null
	# Mark level cleared after boss death
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(self) and not _ending:
			_level_cleared()
	)


func _spawn_one(kind) -> void:
	# Handle funny enemies (string kind)
	if kind is String:
		_spawn_funny(kind)
		return
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


func _spawn_funny(id: String) -> void:
	if funny_enemies.size() >= 10 or _ending:
		return
	var f: FunnyEnemy = FunnyEnemy.new()
	var kind_map := {"joker": FunnyEnemy.Kind.JOKER, "rubber_duck": FunnyEnemy.Kind.RUBBER_DUCK, "pinata": FunnyEnemy.Kind.PINATA}
	if not kind_map.has(id):
		return
	f.setup(kind_map[id], player, rng)
	f.global_position = _ring_point()
	world.add_child(f)
	funny_enemies.append(f)


func kill_funny_enemy(f: FunnyEnemy) -> void:
	RunState.kills += 1
	streak += 1
	_streak_t = COMBO_WINDOW
	Missions.track_kill()
	if streak >= 3 and hud != null:
		hud.combo_pop(streak)
		if streak == 3:
			Audio.play("combo3", -5.0)
			hud.show_announcer("TRIPLE KILL", Color(1.0, 0.94, 0.0))
		elif streak == 5:
			Audio.play("combo5", -4.0)
			if hud != null:
				hud.show_announcer("MEGA KILL", Color(1.0, 0.45, 0.2))
		elif streak == 10:
			Audio.play("combo10", -3.0)
			hud.show_announcer("ULTRA KILL", Color(1.0, 0.2, 0.2))
			shake(5.0)
		elif streak == 20:
			Audio.play("combo10", -2.0)
			hud.show_announcer("HYPER KILL", Color(1.0, 0.0, 0.6))
			shake(8.0)
	Missions.track_combo(streak)
	var s: Dictionary = FunnyEnemy.STATS[f.kind]
	match f.kind:
		FunnyEnemy.Kind.JOKER:
			Audio.play("honk", -1.0)
			shake(3.0)
			hud.show_announcer("JOKER DOWN", Color(1.0, 0.18, 0.53))
			for i in range(16):
				var p := CPUParticles2D.new()
				p.position = world.to_local(f.global_position)
				p.one_shot = true; p.emitting = true; p.amount = 6
				p.lifetime = 1.0; p.explosiveness = 1.0; p.spread = 180.0
				p.gravity = Vector2(0, 80.0)
				p.initial_velocity_min = 60.0; p.initial_velocity_max = 200.0
				p.scale_amount_min = 2.0; p.scale_amount_max = 5.0
				p.color = Color.from_hsv(randf(), 0.8, 0.9)
				world.add_child(p)
				get_tree().create_timer(1.2).timeout.connect(p.queue_free)
			_spawn_death_shockwave(f.global_position, Color(1.0, 0.18, 0.53, 0.7), 60.0)
			RunState.add_gems(5)
			hud.spawn_float(f.global_position, "+5 GEMS", Color(1.0, 0.72, 0.0))
		FunnyEnemy.Kind.RUBBER_DUCK:
			Audio.play("squeak", -1.0)
			Audio.play("squeak", -2.0)
			shake(2.0)
			hud.show_announcer("QUACK!", Color(1.0, 0.9, 0.0))
			for i in range(12):
				var p := CPUParticles2D.new()
				p.position = world.to_local(f.global_position)
				p.one_shot = true; p.emitting = true; p.amount = 4
				p.lifetime = 0.8; p.explosiveness = 1.0; p.spread = 180.0
				p.initial_velocity_min = 40.0; p.initial_velocity_max = 150.0
				p.scale_amount_min = 1.5; p.scale_amount_max = 3.5
				p.color = Color(1.0, 0.85, 0.0, 0.9)
				world.add_child(p)
				get_tree().create_timer(1.0).timeout.connect(p.queue_free)
			_spawn_death_shockwave(f.global_position, Color(1.0, 0.9, 0.0, 0.6), 50.0)
			RunState.add_gems(3)
			hud.spawn_float(f.global_position, "+3 GEMS", Color(1.0, 0.72, 0.0))
		FunnyEnemy.Kind.PINATA:
			Audio.play("combo5", -1.0)
			shake(6.0)
			hud.show_announcer("PINATA SMASHED!", Color(0.0, 1.0, 0.5))
			for i in range(20):
				var p := CPUParticles2D.new()
				p.position = world.to_local(f.global_position)
				p.one_shot = true; p.emitting = true; p.amount = 8
				p.lifetime = 1.2; p.explosiveness = 1.0; p.spread = 180.0
				p.gravity = Vector2(0, 120.0)
				p.initial_velocity_min = 80.0; p.initial_velocity_max = 280.0
				p.scale_amount_min = 2.0; p.scale_amount_max = 6.0
				p.color = Color.from_hsv(randf(), 0.9, 1.0)
				world.add_child(p)
				get_tree().create_timer(1.5).timeout.connect(p.queue_free)
			for i in range(s["gems"]):
				_acquire_mote().drop(f.global_position + Vector2.from_angle(randf() * TAU) * (20.0 + i * 8.0), 1)
			RunState.add_gems(10)
			hud.spawn_float(f.global_position, "+10 GEMS", Color(1.0, 0.72, 0.0))
			_acquire_pickup().spawn(Pickup.Kind.CRATE, f.global_position + Vector2.from_angle(randf() * TAU) * 30.0)
			_spawn_death_shockwave(f.global_position, Color(0.0, 1.0, 0.5, 0.8), 80.0)
	f.active = false
	_burst(f.global_position, s["eye"])
	spawn_ring(f.global_position, 44.0, Color(s["eye"].r, s["eye"].g, s["eye"].b, 0.85))
	if Settings.kill_flash and hud != null:
		hud.flash_kill()
	var _funny_pool: Array[String] = ["pop", "splat", "squeak", "crunch", "splat2", "boing", "squelch", "honk", "whomp", "doh", "oops"]
	Audio.play(_funny_pool[rng.randi_range(0, _funny_pool.size() - 1)], -3.0)
	if streak > 0 and streak % 5 == 0:
		_acquire_mote().drop(f.global_position, 1)
		_acquire_pickup().spawn(_random_orb_kind(), f.global_position)
		hud.spawn_float(f.global_position, "STREAK BONUS", Color(1.0, 0.72, 0.0))
	if rng.randf() < 0.20:
		_acquire_pickup().spawn(_random_orb_kind(), f.global_position)
	funny_enemies.erase(f)
	f.release()
	if not _in_between and not _ending:
		hud.set_level(level, remaining_count())


func _alive_funny() -> int:
	var n := 0
	for f in funny_enemies:
		if f.active:
			n += 1
	return n

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


func nearest_enemy_excluding(pos: Vector2, max_dist: float, excluded: Array[ShadowEnemy]) -> ShadowEnemy:
	var best: ShadowEnemy = null
	var best_d := max_dist
	for e in enemies:
		if not e.active or excluded.has(e):
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
	if "_cd" in weapon:
		weapon._cd = 0.0
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
	hud.flash_level_up()
	spawn_ring(player.global_position, 120.0, Color(1.0, 0.72, 0.0, 0.9))
	hud.refresh_hp(player.effective_max_hp())
	# Check for weapon evolution first
	var evolutions := EvolutionDb.check_available(owned_guns, gun_lv)
	if not evolutions.is_empty():
		var evo_id: String = evolutions[0]
		_equip_weapon(evo_id)
		owned_guns.append(evo_id)
		gun_lv[evo_id] = 5
		var recipe: Dictionary = EvolutionDb.get_recipe(evo_id)
		hud.show_banner(String(recipe["title"]), recipe["color"], 2.0)
		shake(6.0)
		spawn_ring(player.global_position, 140.0, recipe["color"], 0.5)
		Audio.play("elite_die", -2.0)
		return
	# Normal draft
	var choices := CardDb.draw_three(owned_guns, gun_lv, passives, rng)
	var best: Dictionary = choices[0]
	for card: Dictionary in choices:
		if card["kind"] == "weapon_up" and current_gun_id() == card["target"]:
			best = card
			break
		elif card["kind"] == "weapon_new" and not owned_guns.has(card["target"]):
			best = card
	_apply_card(best)


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
			# Only equip if it's a different weapon than current — don't disrupt active shooting
			if current_gun_id() != target:
				_equip_weapon(target)
			elif weapon != null:
				weapon.level_up()
				hud.set_gun(String(WEAPON_CLASSES[target].DISPLAY_NAME), weapon.level)
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
	if hud == null or player == null or world == null:
		return
	if not is_instance_valid(hud) or not is_instance_valid(player) or not is_instance_valid(world):
		return
	if get_tree().paused:
		return
	# Safety: if weapon is null or freed, re-equip pulse
	if weapon == null or not is_instance_valid(weapon):
		weapon = null
		if player != null and is_instance_valid(player):
			_equip_weapon("pulse")
	RunState.run_time += delta if not _ending else 0.0
	_overdrive_left = maxf(0.0, _overdrive_left - delta)
	var od := 1.85 if _overdrive_left > 0.0 else 1.0
	# Combo fire rate bonus: +10% per 5 kills, up to +50% at 25 streak
	var combo_bonus := 1.0 + clampf(float(streak) / 50.0, 0.0, 0.5)
	var total_rate := od * combo_bonus
	if weapon != null:
		weapon.rate_scale = total_rate
		# Weapon watchdog: if _cd is stuck above interval for 2+ seconds, force-reset
		if weapon._cd > 1.0:
			weapon._cd = 0.0
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
	_bomber_check()
	_shake = maxf(0.0, _shake - delta * 22.0)
	world.position = Vector2(rng.randf_range(-_shake, _shake), rng.randf_range(-_shake, _shake))
	camera.position = player.global_position
	grid.track(player.global_position, get_viewport_rect().size * 0.5 + Vector2(80, 80))
	hud.tick(RunState.run_time)
	hud.update_radar(enemies, player.global_position)
	hud.set_xp(float(xp) / float(xp_need()), plevel)
	hud.set_gems(RunState.gems_earned)
	# Boss health bar
	if _boss != null and _boss.active:
		hud.update_boss_bar(_boss.hp, _boss.max_hp)
	# Tick funny enemies
	for f in funny_enemies:
		if f.active and is_instance_valid(f):
			f._dir = (player.global_position - f.global_position).normalized()
	hud.fade_vignette(delta)
	var dfrac := -1.0 if player.dash_cd <= 0.0 else player.dash_cd / (PlayerSpark.DASH_BASE_CD * float(player.mods["dash_cd_mult"]))
	hud.tick_dash(dfrac)


# ---------------------------------------------------------------- input / joystick (§6)

func _unhandled_input(event: InputEvent) -> void:
	# Double-tap pause (right side of screen only, avoids joystick)
	if event is InputEventScreenTouch and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if event.position.x > get_viewport_rect().size.x * 0.5 and now - _last_tap_time < DOUBLE_TAP_CD:
			hud.toggle_pause()
			_joy_index = -1
			return
		_last_tap_time = now
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
		Music.stop()
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
	if world == null or player == null:
		return
	for b in bolts:
		if not b.active:
			continue
		# Check boss first
		if _boss != null and _boss.active:
			if b.global_position.distance_squared_to(_boss.global_position) < pow(_boss.radius + 6.0, 2.0):
				b.deactivate()
				Audio.play("hit", -6.0)
				hud.spawn_float(_boss.global_position, str(b.damage), Color(1.0, 0.8, 0.2))
				if _boss.take_hit(b.damage):
					_on_boss_died(_boss)
				continue
		var snapshot_e: Array = enemies.duplicate()
		for e in snapshot_e:
			if not e.active:
				continue
			if b.global_position.distance_squared_to(e.global_position) < pow(e.radius + 6.0, 2.0):
				b.deactivate()
				Audio.play("hit", -8.0)
				if hud != null:
					hud.spawn_float(e.global_position, str(b.damage), Color(0.85, 0.95, 1.0))
				if e.take_hit(b.damage):
					kill_enemy(e)
				break
		# Check funny enemies
		for f in funny_enemies:
			if not f.active:
				continue
			if b.global_position.distance_squared_to(f.global_position) < pow(f.radius + 6.0, 2.0):
				b.deactivate()
				Audio.play("hit", -8.0)
				hud.spawn_float(f.global_position, str(b.damage), Color(1.0, 0.9, 0.0))
				if f.take_hit(b.damage):
					kill_funny_enemy(f)
				break


func _orbs_tick(delta: float) -> void:
	if _ending:
		return
	for o in orbs:
		if o.active and o.global_position.distance_squared_to(player.global_position) < pow(player.RADIUS + 8.0, 2.0):
			o.splash()


func _enemies_vs_player() -> void:
	if _ending or player == null or not is_instance_valid(player):
		return
	var snapshot_enemies: Array = enemies.duplicate()
	# Boss contact damage
	if _boss != null and _boss.active and not _boss._invulnerable:
		var contact := _boss.radius + PlayerSpark.RADIUS - 3.0
		if _boss.global_position.distance_squared_to(player.global_position) < contact * contact:
			player.try_take_damage(_boss.damage, _boss.global_position)
	for e in snapshot_enemies:
		if not e.active:
			continue
		var contact: float = e.radius + PlayerSpark.RADIUS - 3.0
		if e.global_position.distance_squared_to(player.global_position) < contact * contact:
			if player.try_take_damage(e.damage, e.global_position):
				e.shove((e.global_position - player.global_position).normalized(), 14.0)
	for f in funny_enemies:
		if not f.active:
			continue
		var contact_f: float = f.radius + PlayerSpark.RADIUS - 3.0
		if f.global_position.distance_squared_to(player.global_position) < contact_f * contact_f:
			if player.try_take_damage(f.damage, f.global_position):
				f.shove((f.global_position - player.global_position).normalized(), 14.0)


func _bomber_check() -> void:
	if player == null or not is_instance_valid(player):
		return
	var snapshot: Array = enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		if e.should_explode():
			# Bomb explosion — area damage to player
			var dist: float = e.global_position.distance_to(player.global_position)
			if dist < 160.0:
				var dir: Vector2 = (player.global_position - e.global_position).normalized()
				player.try_take_damage(2, e.global_position)
				player._knockback = dir * 300.0
			# Explosion visual
			_spawn_death_shockwave(e.global_position, Color(1.0, 0.5, 0.0, 0.8), 120.0)
			Audio.play("elite_die", -3.0)
			kill_enemy(e)


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
	if not is_instance_valid(e) or not e.active:
		return
	# Safety: ensure arena state is valid
	if world == null or not is_instance_valid(world):
		return
	if player == null or not is_instance_valid(player):
		return
	RunState.kills += 1
	streak += 1
	_streak_t = COMBO_WINDOW
	Missions.track_kill()
	if streak >= 3:
		hud.combo_pop(streak)
		# Funny combo sounds + announcer
		if streak == 3:
			Audio.play("combo3", -5.0)
			hud.show_announcer("TRIPLE KILL", Color(1.0, 0.94, 0.0))
		elif streak == 5:
			Audio.play("combo5", -4.0)
			hud.show_announcer("MEGA KILL", Color(1.0, 0.45, 0.2))
		elif streak == 10:
			Audio.play("combo10", -3.0)
			hud.show_announcer("ULTRA KILL", Color(1.0, 0.2, 0.2))
			shake(5.0)
		elif streak == 20:
			Audio.play("combo10", -2.0)
			hud.show_announcer("HYPER KILL", Color(1.0, 0.0, 0.6))
			shake(8.0)
		elif streak == 30:
			Audio.play("combo10", -1.0)
			hud.show_announcer("UNSTOPPABLE", Color(0.0, 1.0, 1.0))
			shake(10.0)
		elif streak % 10 == 0:
			Audio.play("combo10", -2.0)
			hud.show_announcer("GODLIKE", Color(1.0, 0.84, 0.0))
	Missions.track_combo(streak)
	if streak > 0 and streak % 5 == 0:
		for i in range(mini(1 + streak / 10, 3)):
			_acquire_mote().drop(e.global_position, 1)
		# Streak milestone: guaranteed powerup drop!
		_acquire_pickup().spawn(_random_orb_kind(), e.global_position)
		hud.spawn_float(e.global_position, "STREAK BONUS", Color(1.0, 0.72, 0.0))
		shake(2.0)
	var eye: Color = ShadowEnemy.STATS[e.kind]["eye"]
	e.active = false
	_burst(e.global_position, eye)
	spawn_ring(e.global_position, 44.0, Color(eye.r, eye.g, eye.b, 0.85))
	if Settings.kill_flash:
		hud.flash_kill()
	# Funny kill sound — random from a big pool so it never gets repetitive
	var _funny_pool: Array[String] = ["pop", "splat", "squeak", "crunch", "splat2", "boing", "squelch", "honk", "whomp", "doh", "oops"]
	Audio.play(_funny_pool[rng.randi_range(0, _funny_pool.size() - 1)], -3.0)
	if e.kind == ShadowEnemy.Kind.BRUTE:
		Audio.play("thud", -2.0)
		shake(8.0)
		hud.spawn_float(e.global_position, "BRUTE DOWN", Color(1.0, 0.45, 0.2))
		_spawn_death_shockwave(e.global_position, Color(1.0, 0.3, 0.1), 90.0)
	elif e.elite:
		shake(6.0)
		_spawn_death_shockwave(e.global_position, eye, 70.0)
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
	# drops: elites always pay out; normal shadows drop more often
	if e.elite:
		_acquire_pickup().spawn(Pickup.Kind.CRATE if rng.randf() < 0.4 else _random_orb_kind(), e.global_position)
	else:
		var r := rng.randf()
		if r < 0.06:
			_acquire_pickup().spawn(Pickup.Kind.CRATE, e.global_position)
		elif r < 0.18:
			_acquire_pickup().spawn(_random_orb_kind(), e.global_position)
	enemies.erase(e)
	e.release()
	_enemy_pool.append(e)
	if not _in_between and not _ending:
		hud.set_level(level, remaining_count())


func _random_orb_kind() -> Pickup.Kind:
	var roll := rng.randf()
	if roll < 0.30:
		return Pickup.Kind.OVERDRIVE
	elif roll < 0.55:
		return Pickup.Kind.SHIELD
	elif roll < 0.80:
		return Pickup.Kind.MAGNET
	else:
		return Pickup.Kind.SPEED


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
	p.amount = 32
	p.lifetime = 0.65
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


func _spawn_death_shockwave(at: Vector2, col: Color, radius: float) -> void:
	# Expanding ring + particles for juicy kills
	spawn_ring(at, radius, col, 0.35)
	var p := CPUParticles2D.new()
	p.position = world.to_local(at)
	p.one_shot = true
	p.emitting = true
	p.amount = 48
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 350.0
	p.damping_min = 200.0
	p.damping_max = 350.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 6.0
	var ramp := Gradient.new()
	ramp.set_color(0, col)
	ramp.set_color(1, Color(col.r, col.g, col.b, 0.0))
	p.color_ramp = ramp
	world.add_child(p)
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)


# ---------------------------------------------------------------- damage & death

func _on_player_took_damage(current_hp: int) -> void:
	if hud == null or not is_instance_valid(hud):
		return
	# Damage flash: red pulse
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
	# Kill pending boss timers to prevent post-free crashes
	_boss_active = false
	RunState.deaths += 1
	get_tree().paused = false
	Engine.time_scale = 0.25
	Audio.play("game_over")
	Analytics.design_event("run_end", {"time": snappedf(RunState.run_time, 0.1), "kills": RunState.kills, "level": level, "plevel": plevel})
	await get_tree().create_timer(0.9, true, false, true).timeout
	Engine.time_scale = 1.0
	GameState.change_state(GameState.State.RESULTS)
	SaveSystem.mark_run_finished(level, RunState.gems_earned, RunState.run_time)
	SaveSystem.unlock_next_level(level)
	Missions.track_run()
	Missions.track_gems(RunState.gems_earned)
	Missions.track_weapons_collected(owned_guns.size())
	if RunState.deaths == 0:
		Missions.track_no_death_level(level)
	if RunState.is_daily:
		DailyChallenge.save_daily_result(level, RunState.kills, RunState.gems_earned, RunState.run_time)
	var is_victory := level >= 30
	hud.build_results(RunState.run_time, seed_hex(), level, is_victory)
	await get_tree().create_timer(0.6, true, false, true).timeout
	_results_ready = true
