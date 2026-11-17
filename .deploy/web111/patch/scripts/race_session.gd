class_name RaceSession
extends RefCounted
## Transient super-session state. Nothing here resumes an unfinished game.

const RULES_VERSION := preload("res://scripts/race_records.gd").RULES_VERSION
const TRIAL_COUNT := 8
const WRONG_PENALTY_MS := 5000
const CLOCK_TOLERANCE_MS := 2000

var state := "abandoned"
var mode := "starter"
var run_id := ""
var local_player_id := ""
var display_id := ""
var start_eligibility: Dictionary = {}
var answer_count := 0
var wrong_count := 0
var record: Dictionary = {}
var clock_anomaly := false
var background_compensated := false
var _elapsed_ms := 0
var _last_mono := 0
var _last_wall := 0
var _background := false
var monotonic_clock: Callable
var wall_clock: Callable


func _init(mono: Callable = Callable(), wall: Callable = Callable()) -> void:
	monotonic_clock = mono
	wall_clock = wall


static func unique_id() -> String:
	return Crypto.new().generate_random_bytes(16).hex_encode()


func prepare(game_mode: String, player_id: String = "", player_name: String = "", eligibility: Dictionary = {}) -> void:
	mode = game_mode if game_mode in ["starter", "history"] else "starter"
	run_id = unique_id()
	local_player_id = player_id
	display_id = player_name
	start_eligibility = eligibility.duplicate(true)
	answer_count = 0
	wrong_count = 0
	record = {}
	clock_anomaly = false
	background_compensated = false
	_elapsed_ms = 0
	_background = false
	state = "preparing"


func start() -> bool:
	if state != "preparing":
		return false
	_last_mono = _mono()
	_last_wall = _wall()
	state = "running"
	return true


func submit(correct: bool, trial_index: int = -1) -> bool:
	# The caller supplies the trial token, not merely a tap. Stale callbacks
	# cannot commit the next trial even when a visual transition has completed.
	if state != "running" or trial_index != answer_count:
		return false
	_checkpoint()
	answer_count += 1
	if not correct:
		wrong_count += 1
	if answer_count == TRIAL_COUNT:
		state = "finished"
		var penalty := wrong_count * WRONG_PENALTY_MS
		record = {
			"run_id": run_id, "local_player_id": local_player_id,
			"display_id_snapshot": display_id, "mode": mode,
			"rules_version": RULES_VERSION, "elapsed_ms": _elapsed_ms,
			"wrong_count": wrong_count, "penalty_ms": penalty,
			"total_ms": _elapsed_ms + penalty, "completed_at": _last_wall,
			"platform_id": str(start_eligibility.get("platform_id", "local")),
			"start_eligibility": start_eligibility.duplicate(true),
			"submission_state": "local_only",
			"timing_status": "clock_anomaly" if clock_anomaly else "ok",
			"background_compensated": background_compensated,
		}
	return true


func abandon() -> void:
	if state != "finished":
		state = "abandoned"
		start_eligibility = {}


func set_background(value: bool) -> void:
	if state == "running":
		_checkpoint()
	_background = value


func elapsed_ms() -> int:
	if state == "running":
		_checkpoint()
	return _elapsed_ms


func result() -> Dictionary:
	return record.duplicate(true)


func _checkpoint() -> void:
	var mono := _mono()
	var wall := _wall()
	var mono_delta := mono - _last_mono
	var wall_delta := wall - _last_wall
	var delta := maxi(0, mono_delta)
	if mono_delta < 0 or wall_delta < 0:
		clock_anomaly = true
	if absi(wall_delta - mono_delta) > CLOCK_TOLERANCE_MS:
		# A suspended monotonic clock and a changed wall clock are not reliably
		# distinguishable on every OS. Include positive background wall time,
		# but mark the result local-only rather than claim a verified race.
		clock_anomaly = true
		if _background and wall_delta > delta:
			delta = wall_delta
			background_compensated = true
	_elapsed_ms += delta
	_last_mono = mono
	_last_wall = wall


func _mono() -> int:
	return int(monotonic_clock.call()) if monotonic_clock.is_valid() else Time.get_ticks_msec()


func _wall() -> int:
	return int(wall_clock.call()) if wall_clock.is_valid() else int(Time.get_unix_time_from_system() * 1000.0)
