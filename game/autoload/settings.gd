extends Node
## Settings — persists user preferences between sessions.

const SAVE_PATH := "user://settings.json"

var music_volume: float = 0.8  # 0.0 to 1.0
var sfx_volume: float = 1.0    # 0.0 to 1.0
var quality: int = 2           # 0=low, 1=mid, 2=high
var show_damage_numbers: bool = true
var screen_shake: bool = true
var auto_level_up: bool = true


func _ready() -> void:
	_load()
	_apply()


func _apply() -> void:
	# Apply music volume
	if has_node("/root/Music"):
		get_node("/root/Music").set_volume(linear_to_db(music_volume) if music_volume > 0.0 else -80.0)
	# Apply SFX volume via Audio bus
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


func toggle_damage_numbers() -> void:
	show_damage_numbers = not show_damage_numbers
	_save()


func toggle_screen_shake() -> void:
	screen_shake = not screen_shake
	_save()


func toggle_auto_level_up() -> void:
	auto_level_up = not auto_level_up
	_save()


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


func _save() -> void:
	var data := {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"quality": quality,
		"show_damage_numbers": show_damage_numbers,
		"screen_shake": screen_shake,
		"auto_level_up": auto_level_up,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
