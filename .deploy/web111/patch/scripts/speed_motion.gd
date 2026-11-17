extends RefCounted
## Approved v6 visual math only. Input thresholds and racing rules live elsewhere.
const CHARGE_SCALE := 1.42
const RACE_SCALE := 1.28
static func sample(mode: String, elapsed: float, progress: float = 0.0, reduced: bool = false, entry_scale: float = RACE_SCALE, from_race: bool = false) -> Dictionary:
	var scale := 1.0
	var angle := 0.0
	var squash := 0.0
	var pulse := 1.0
	var fill := 0.0
	if mode == "charge":
		fill = clampf(progress, 0.0, 1.0)
		var initial := RACE_SCALE if from_race else 1.0
		scale = lerpf(initial, CHARGE_SCALE, 1.0 - pow(1.0 - fill, 2.0))
		if not reduced: angle = sin(elapsed * PI * 12.0) * (2.0 + fill * 5.0)
	elif mode == "race":
		fill = 1.0
		scale = RACE_SCALE + (entry_scale - RACE_SCALE) * pow(1.0 - minf(1.0, elapsed / 0.18), 2.0)
		var beat := fmod(maxf(0.0, elapsed), 1.8)
		if not reduced and beat < 0.96:
			var q := beat / 0.96
			var envelope := sin(q * PI)
			angle = sin(q * PI * 5.0) * envelope * 14.0
			squash = cos(q * PI * 5.0) * envelope * 0.10
			pulse = 1.0 + sin(q * PI * 3.0) * envelope * 0.045
	return {"scale":Vector2(scale * pulse * (1.0 + squash), scale * pulse / (1.0 + squash)), "angle":deg_to_rad(angle), "fill":fill}
static func fill_edge(progress: float) -> float:
	return 1.0 if progress <= 0.0 else (0.0 if progress >= 1.0 else 0.92 - progress * 0.84)
