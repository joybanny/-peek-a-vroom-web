class_name RaceRecords
extends RefCounted
## Pure validation/ranking helpers. Display names never serve as identities.

const SCHEMA_VERSION := 1
const RULES_VERSION := 2 # Frozen personal pool; no discoveries.
const DISPLAY_ID_LIMIT := 20
const MAX_SAFE_INTEGER := 9007199254740991
const SUBMISSION_STATES := ["local_only", "pending", "submitted", "failed", "unconfirmed"]


static func new_id() -> String:
	return Crypto.new().generate_random_bytes(16).hex_encode()


static func sanitize_display_id(value: Variant) -> String:
	if not value is String:
		return ""
	var result := ""
	for character in value:
		var point: int = character.unicode_at(0)
		if point >= 32 and point != 127 and not (point >= 0x202a and point <= 0x202e) and not (point >= 0x2066 and point <= 0x2069):
			result += character
	return result.strip_edges().left(DISPLAY_ID_LIMIT)


static func defaults() -> Dictionary:
	return {"version": SCHEMA_VERSION, "local_player_id": new_id(), "display_id": "", "records": []}


static func normalize(value: Variant) -> Dictionary:
	var result := defaults()
	if not value is Dictionary:
		return result
	var player: Variant = value.get("local_player_id", "")
	if player is String and not player.is_empty() and player.length() <= 128:
		result.local_player_id = player
	result.display_id = sanitize_display_id(value.get("display_id", ""))
	var rows: Variant = value.get("records", [])
	var seen: Dictionary = {}
	if rows is Array:
		for raw in rows:
			var row := normalize_record(raw)
			if not row.is_empty() and not seen.has(row.run_id):
				seen[row.run_id] = true
				result.records.append(row)
	return result


static func valid_integer(value: Variant, minimum: int = 0, maximum: int = MAX_SAFE_INTEGER) -> bool:
	if not (value is int or value is float):
		return false
	var number := float(value)
	return is_finite(number) and number == floor(number) and number >= minimum and number <= maximum


static func normalize_record(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	for key in ["run_id", "local_player_id"]:
		var id: Variant = value.get(key, "")
		if not id is String or id.is_empty() or id.length() > 128:
			return {}
	if value.get("mode") not in ["starter", "history"]:
		return {}
	for key in ["rules_version", "elapsed_ms", "wrong_count", "penalty_ms", "total_ms", "completed_at"]:
		if not valid_integer(value.get(key)):
			return {}
	if int(value.rules_version) < 1 or int(value.wrong_count) > 8:
		return {}
	if int(value.penalty_ms) != int(value.wrong_count) * 5000 or int(value.total_ms) != int(value.elapsed_ms) + int(value.penalty_ms):
		return {}
	var result: Dictionary = value.duplicate(true)
	result.display_id_snapshot = sanitize_display_id(value.get("display_id_snapshot", ""))
	for key in ["rules_version", "elapsed_ms", "wrong_count", "penalty_ms", "total_ms", "completed_at"]:
		result[key] = int(value[key])
	result.platform_id = str(value.get("platform_id", "local")).left(64)
	result.start_eligibility = value.get("start_eligibility", {}).duplicate(true) if value.get("start_eligibility", {}) is Dictionary else {}
	result.submission_state = value.get("submission_state", "local_only") if value.get("submission_state", "local_only") in SUBMISSION_STATES else "local_only"
	# A reload must never create a submission/retry queue.
	if result.submission_state == "pending":
		result.submission_state = "unconfirmed"
	result.timing_status = "clock_anomaly" if value.get("timing_status", "ok") != "ok" else "ok"
	if result.timing_status != "ok" and result.submission_state in ["pending", "submitted"]:
		result.submission_state = "local_only"
	return result


static func board(race_data: Dictionary, mode: String, current_run_id: String = "", rules_version: int = RULES_VERSION) -> Dictionary:
	var ranked: Array = []
	for row in race_data.get("records", []):
		if row is Dictionary and row.get("mode") == mode and row.get("rules_version") == rules_version:
			ranked.append(row)
	ranked.sort_custom(_before)
	var current: Dictionary = {}
	var current_rank := 0
	var rows: Array = []
	for index in range(ranked.size()):
		var source: Dictionary = ranked[index]
		if index >= 100 and source.run_id != current_run_id:
			continue
		var row: Dictionary = source.duplicate(true)
		row["rank"] = index + 1
		if row.run_id == current_run_id:
			current = row
			current_rank = index + 1
		if index < 100:
			rows.append(row)
	return {"rows": rows, "rank": current_rank, "current": current, "total": ranked.size(), "mode": mode, "rules_version": rules_version}


static func _before(a: Dictionary, b: Dictionary) -> bool:
	if a.total_ms != b.total_ms:
		return a.total_ms < b.total_ms
	if a.completed_at != b.completed_at:
		return a.completed_at < b.completed_at
	return a.run_id < b.run_id
