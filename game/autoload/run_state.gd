extends Node
## Per-run transient stats. Reset at run start; persisted via SaveSystem on results.
## Balance numbers live in resources/*.tres — never hardcode tuning here.

signal shards_changed(total: int)

var shards := 0
var time_alive := 0.0
var kills := 0
var max_hp := 3
var hp := 3
var run_time := 0.0


func reset_run() -> void:
	shards = 0
	time_alive = 0.0
	kills = 0
	hp = max_hp
	run_time = 0.0
	shards_changed.emit(shards)


func add_shards(n: int) -> void:
	shards += n
	shards_changed.emit(shards)
