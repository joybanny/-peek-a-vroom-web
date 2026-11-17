extends Node

const RaceRecordsData = preload("res://scripts/race_records.gd")

const SAVE_PATH := "user://save_data.json"
const DEFAULT_SOUND_VOLUME := 0.6
const DEFAULT_LANGUAGE := "zh"

var data: Dictionary = {}
var save_path := SAVE_PATH
var last_save_succeeded := false


func _ready() -> void:
	load_data()
	if OS.has_feature("web"):
		var explicit: Variant = JavaScriptBridge.eval("window.peekVroomLanguageExplicit ? window.peekVroomLanguage : null")
		if explicit is String and explicit in ["zh", "en"]:
			data.settings.language = explicit
		save()


static func initial_language() -> String:
	if OS.has_feature("web"):
		var language: Variant = JavaScriptBridge.eval("window.peekVroomLanguage || 'en'")
		return "zh" if language == "zh" else "en"
	return DEFAULT_LANGUAGE


func defaults() -> Dictionary:
	return {
		"version": 2,
		"race_data": RaceRecordsData.defaults(),
		"collected_cars": CarData.starter_ids(),
		"known_cars": CarData.starter_ids(),
		"unviewed_car_ids": [],
		"recent_level_results": [],
		"zero_discovery_streak": 0,
		"total_plays": 0,
		"best_streak": 0,
		"advanced_mode_unlocked": false,
		"starter_unlock_streak": 0,
		"recent_history_results": [],
		"trial_history": [],
		"settings": {
			"sound": true,
			"sound_volume": DEFAULT_SOUND_VOLUME,
			"sfx_enabled": true,
			"language": initial_language(),
			"tutorial_seen": false,
			"tutorial_completed": false,
			"tutorial_pending": false,
			"fast_mode": false,
			"daily_time_limit_minutes": 20,
			"hidden_car_categories": [],
		},
	}


func load_data() -> void:
	data = defaults()
	if not FileAccess.file_exists(save_path):
		save()
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()
	if parse_result == OK and json.data is Dictionary:
		merge_loaded_data(json.data)
		# Persist the generated local identity when upgrading an older save.
		if json.data.get("race_data", {}) != data.race_data:
			save()
		return
	# A partially written or manually damaged save should never prevent a child
	# from starting the game. Replace it with a known-good default document.
	save()


func merge_loaded_data(parsed: Dictionary) -> void:
	# Unknown v1 keys, including current_difficulty, remain readable but inactive.
	var normalized := defaults()
	for key in parsed:
		if key != "settings":
			normalized[key] = parsed[key]
	var settings: Dictionary = normalized.settings.duplicate(true)
	var loaded_settings = parsed.get("settings", {})
	if loaded_settings is Dictionary:
		settings.merge(loaded_settings, true)
	normalized.settings = normalize_settings(settings)
	normalized.collected_cars = _valid_car_ids(normalized.get("collected_cars", []))
	var loaded_known = parsed.get("known_cars", normalized.collected_cars)
	normalized.known_cars = _valid_car_ids(loaded_known)
	for collected_id in normalized.collected_cars:
		if not normalized.known_cars.has(collected_id):
			normalized.known_cars.append(collected_id)
	var unviewed: Array[String] = []
	for car_id in _valid_car_ids(parsed.get("unviewed_car_ids", [])):
		if normalized.collected_cars.has(car_id):
			unviewed.append(car_id)
	normalized.unviewed_car_ids = unviewed
	var recent: Array[int] = []
	var loaded_recent = parsed.get("recent_level_results", [])
	if loaded_recent is Array:
		var start := maxi(0, loaded_recent.size() - 3)
		for index in range(start, loaded_recent.size()):
			recent.append(clampi(int(loaded_recent[index]), 0, 8))
	normalized.recent_level_results = recent
	normalized.zero_discovery_streak = maxi(0, int(parsed.get("zero_discovery_streak", 0)))
	# Existing players do not get forced onboarding after an update.
	if loaded_settings is Dictionary and not loaded_settings.has("tutorial_seen"):
		if has_play_progress(normalized):
			normalized.settings.tutorial_seen = true
	normalized.race_data = RaceRecordsData.normalize(parsed.get("race_data", {}))
	normalized.version = 2
	data = normalized


static func normalize_settings(values: Variant) -> Dictionary:
	# Only normalize the settings owned here. Keep authored/forward-compatible
	# settings and all progression data intact when upgrading an older save.
	var settings: Dictionary = values.duplicate(true) if values is Dictionary else {}
	settings["sound"] = settings.get("sound", true) if settings.get("sound", true) is bool else true
	settings["sfx_enabled"] = settings.get("sfx_enabled", true) if settings.get("sfx_enabled", true) is bool else true
	for key in ["tutorial_seen", "tutorial_completed", "tutorial_pending"]:
		settings[key] = settings.get(key, false) if settings.get(key, false) is bool else false
	if settings["tutorial_completed"]:
		settings["tutorial_seen"] = true
		settings["tutorial_pending"] = false
	settings["sound_volume"] = normalize_sound_volume(settings.get("sound_volume", DEFAULT_SOUND_VOLUME))
	var language: Variant = settings.get("language", DEFAULT_LANGUAGE)
	if language is String:
		language = language.strip_edges().to_lower()
	settings["language"] = language if language is String and language in ["zh", "en"] else DEFAULT_LANGUAGE
	return settings


static func normalize_sound_volume(value: Variant) -> float:
	# Do not coerce strings, booleans, objects or nonfinite numbers into a gain.
	if not (value is float or value is int):
		return DEFAULT_SOUND_VOLUME
	var volume := float(value)
	return clampf(volume, 0.0, 1.0) if is_finite(volume) else DEFAULT_SOUND_VOLUME


func add_car(car_id: String) -> bool:
	if CarData.find(car_id).is_empty():
		return false
	var collected: Array = data.collected_cars
	if collected.has(car_id):
		return false
	collected.append(car_id)
	var known: Array = data.known_cars
	if not known.has(car_id):
		known.append(car_id)
	var unviewed: Array = data.get("unviewed_car_ids", [])
	if not unviewed.has(car_id):
		unviewed.append(car_id)
	data.unviewed_car_ids = unviewed
	save()
	var event_bus := get_node_or_null("/root/EventBus") if is_inside_tree() else null
	if event_bus != null:
		event_bus.car_collected.emit(car_id)
	return true


func mark_car_viewed(car_id: String) -> bool:
	var unviewed: Array = data.get("unviewed_car_ids", [])
	if not unviewed.has(car_id):
		return false
	unviewed.erase(car_id)
	data.unviewed_car_ids = unviewed
	save()
	return true


func reset_progress() -> void:
	var current_settings: Dictionary = data.get("settings", {}).duplicate(true)
	var reset_data := defaults()
	var settings: Dictionary = reset_data.settings.duplicate(true)
	settings.merge(current_settings, true)
	reset_data.settings = settings
	reset_data.race_data = RaceRecordsData.normalize(data.get("race_data", {}))
	data = reset_data
	save()


func record_completed_level(correct_count: int, discovery_count: int, remaining_count: int) -> void:
	var recent: Array = data.get("recent_level_results", [])
	recent.append(clampi(correct_count, 0, 8))
	while recent.size() > 3:
		recent.pop_front()
	data.recent_level_results = recent
	if remaining_count > 0:
		if discovery_count > 0:
			data.zero_discovery_streak = 0
		else:
			data.zero_discovery_streak = maxi(0, int(data.get("zero_discovery_streak", 0))) + 1
	save()


func _valid_car_ids(values: Variant) -> Array[String]:
	var valid: Array[String] = []
	if not values is Array:
		return valid
	for value in values:
		var car_id := str(value)
		if not CarData.find(car_id).is_empty() and not valid.has(car_id):
			valid.append(car_id)
	return valid


func save() -> bool:
	if OS.has_feature("web"):
		var language := str(data.get("settings", {}).get("language", initial_language()))
		JavaScriptBridge.eval("window.peekVroomSyncLanguage && window.peekVroomSyncLanguage(%s)" % JSON.stringify(language))
	# Write beside the target, then rename, so a failed write cannot truncate
	# the user's previous collection and race records.
	last_save_succeeded = false
	var temporary := save_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return false
	last_save_succeeded = DirAccess.rename_absolute(temporary, save_path) == OK
	return last_save_succeeded


func ensure_race_data() -> Dictionary:
	if not data.has("race_data") or not data.race_data is Dictionary:
		data.race_data = RaceRecordsData.defaults()
		save()
	return data.race_data


func set_race_display_id(value: String) -> bool:
	var race := ensure_race_data()
	race.display_id = RaceRecordsData.sanitize_display_id(value)
	return save()


func append_race_record(value: Dictionary) -> Dictionary:
	var race := ensure_race_data()
	var row := RaceRecordsData.normalize_record(value)
	if row.is_empty() or row.local_player_id != race.local_player_id:
		return {"accepted": false, "saved": false, "duplicate": false, "record": {}}
	for existing in race.records:
		if existing.run_id == row.run_id:
			return {"accepted": false, "saved": last_save_succeeded and not OS.has_feature("web"), "duplicate": true, "record": existing.duplicate(true)}
	race.records.append(row)
	var persisted := save()
	# Godot's Web filesystem writes are not proof that asynchronous browser
	# storage has durably flushed. Do not claim permanent saving from this API.
	return {"accepted": true, "saved": persisted and not OS.has_feature("web"), "duplicate": false, "record": row.duplicate(true), "storage_status": "browser_sync_unverified" if OS.has_feature("web") and persisted else ("saved" if persisted else "failed")}


func race_board(mode: String, current_run_id: String = "", rules_version: int = RaceRecordsData.RULES_VERSION) -> Dictionary:
	return RaceRecordsData.board(ensure_race_data(), mode, current_run_id, rules_version)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		save()


static func has_play_progress(values: Dictionary) -> bool:
	# Cover every historical progress marker, including partial/older saves.
	for key in ["total_plays", "best_streak", "starter_unlock_streak", "zero_discovery_streak"]:
		var value: Variant = values.get(key, 0)
		if (value is int or value is float) and float(value) > 0.0: return true
	if values.get("advanced_mode_unlocked", false) is bool and values.get("advanced_mode_unlocked", false): return true
	for key in ["recent_level_results", "recent_history_results", "trial_history", "unviewed_car_ids"]:
		var value: Variant = values.get(key, [])
		if value is Array and not value.is_empty(): return true
	var starter_ids := CarData.starter_ids()
	for key in ["collected_cars", "known_cars"]:
		var value: Variant = values.get(key, [])
		if value is Array:
			for car_id in value:
				if car_id is String and not starter_ids.has(car_id) and not CarData.find(car_id).is_empty(): return true
	return false
