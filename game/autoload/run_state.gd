extends Node
## Per-run transient stats. Reset at run start; persisted via SaveSystem on results.

signal shards_changed(total: int)
signal gems_changed(total: int)

var shards := 0
var gems_earned := 0
var time_alive := 0.0
var kills := 0
var deaths := 0
var max_hp := 3
var hp := 3
var run_time := 0.0
var start_level := 1
var is_daily := false
var is_boss_rush := false
var boss_rush_wave := 0
var boss_rush_time := 0.0
var boss_rush_kills := 0


func reset_run(lv: int = 1) -> void:
	start_level = lv
	is_daily = false
	is_boss_rush = false
	boss_rush_wave = 0
	boss_rush_time = 0.0
	boss_rush_kills = 0
	shards = 0
	gems_earned = 0
	time_alive = 0.0
	kills = 0
	deaths = 0
	hp = max_hp
	run_time = 0.0
	shards_changed.emit(shards)
	gems_changed.emit(gems_earned)


func reset_boss_rush() -> void:
	reset_run(1)
	is_boss_rush = true
	boss_rush_wave = 0
	boss_rush_time = 0.0
	boss_rush_kills = 0

func add_shards(n: int) -> void:
	shards += n
	shards_changed.emit(shards)


func add_gems(n: int) -> void:
	gems_earned += n
	gems_changed.emit(gems_earned)
