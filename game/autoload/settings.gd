extends Node
## Settings — persists user preferences between sessions.

const SAVE_PATH := "user://settings.json"

var music_volume: float = 0.8
var sfx_volume: float = 1.0
var quality: int = 2           # 0=low, 1=mid, 2=high
var show_damage_numbers: bool = true
var screen_shake: bool = true
var auto_level_up: bool = true
var vibration: bool = true
var show_radar: bool = true
var show_kill_counter: bool = true
var show_combo_counter: bool = true
var text_size: int = 1         # 0=small, 1=medium, 2=large
var colorblind_mode: bool = false
var high_contrast: bool = false
var kill_flash: bool = true


func _ready() -> void:
	_load()
	_apply()


func _apply() -> void:
	# Apply music volume
	if has_node("/root/Music"):
		get_node("/root/Music").set_volume(linear_to_db(music_volume) if music_volume > 0.0 else -80.0)
	# Apply SFX volume
	AudioServer.set_bus_volume_db(0, linear_to_db(sfx_volume) if sfx_volume > 0.0 else -80.0)


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_apply()
	_save()


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_apply()
	_save()


func set_quality(level: int) -> void:
	quality = clampi(level, 0, 2)
	_save()


func set_text_size(level: int) -> void:
	text_size = clampi(level, 0, 2)
	_save()


func toggle_damage_numbers() -> void:
	show_damage_numbers = not show_damage_numbers
	_save()


func toggle_screen_shake() -> void:
	screen_shake = not screen_shake
	_save()


func toggle_auto_level_up() -> void:
	auto_level_up = not auto_level_up
	_save()


func toggle_vibration() -> void:
	vibration = not vibration
	_save()


func toggle_radar() -> void:
	show_radar = not show_radar
	_save()


func toggle_kill_counter() -> void:
	show_kill_counter = not show_kill_counter
	_save()


func toggle_combo_counter() -> void:
	show_combo_counter = not show_combo_counter
	_save()


func toggle_colorblind_mode() -> void:
	colorblind_mode = not colorblind_mode
	_save()


func toggle_high_contrast() -> void:
	high_contrast = not high_contrast
	_save()


# Stats tracking
func get_stats() -> Dictionary:
	var save := SaveSystem.load_save()
	var run_count := int(save.get("runs", 0))
	var best_time := float(save.get("best_time", 0.0))
	var best_level := int(save.get("best_level", 1))
	var total_gems := int(save.get("gems", 0))
	# Load missions data for total kills
	var missions_data := {}
	if FileAccess.file_exists("user://missions.json"):
		var f := FileAccess.open("user://missions.json", FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				missions_data = parsed
	var total_kills := int(missions_data.get("total_kills", 0))
	return {
		"total_runs": run_count,
		"total_kills": total_kills,
		"total_gems": total_gems,
		"best_level": best_level,
		"best_time": best_time,
	}


func reset_progress() -> void:
	# Delete all save files
	var files := ["user://save.json", "user://missions.json", "user://daily.json"]
	for path in files:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		music_volume = float(parsed.get("music_volume", 0.8))
		sfx_volume = float(parsed.get("sfx_volume", 1.0))
		quality = int(parsed.get("quality", 2))
		show_damage_numbers = bool(parsed.get("show_damage_numbers", true))
		screen_shake = bool(parsed.get("screen_shake", true))
		auto_level_up = bool(parsed.get("auto_level_up", true))
		vibration = bool(parsed.get("vibration", true))
		show_radar = bool(parsed.get("show_radar", true))
		show_kill_counter = bool(parsed.get("show_kill_counter", true))
		show_combo_counter = bool(parsed.get("show_combo_counter", true))
		text_size = int(parsed.get("text_size", 1))
		colorblind_mode = bool(parsed.get("colorblind_mode", false))
		high_contrast = bool(parsed.get("high_contrast", false))
		kill_flash = bool(parsed.get("kill_flash", true))


func _save() -> void:
	var data := {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"quality": quality,
		"show_damage_numbers": show_damage_numbers,
		"screen_shake": screen_shake,
		"auto_level_up": auto_level_up,
		"vibration": vibration,
		"show_radar": show_radar,
		"show_kill_counter": show_kill_counter,
		"show_combo_counter": show_combo_counter,
		"text_size": text_size,
		"colorblind_mode": colorblind_mode,
		"high_contrast": high_contrast,
		"kill_flash": kill_flash,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
