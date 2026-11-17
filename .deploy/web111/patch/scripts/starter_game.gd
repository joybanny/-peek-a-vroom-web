@tool
class_name StarterGame
extends Control

const RaceSessionScript = preload("res://scripts/race_session.gd")
const SpeedMotion = preload("res://scripts/speed_motion.gd")
const RaceHoldScript = preload("res://scripts/race_hold_control.gd")
const RaceResultScript = preload("res://scripts/race_result_view.gd")

const CustomUI = preload("res://scripts/ui_customization.gd")
const PaperUI = preload("res://scripts/picturebook_ui.gd")
const DialogMotion = preload("res://scripts/paper_dialog_motion.gd")
const CompletionStars = preload("res://scripts/completion_stars.gd")
const Responsive = preload("res://scripts/responsive_layout.gd")

const Content = preload("res://scripts/game_content.gd")
const L = preload("res://scripts/localization.gd")
const SettingsView = preload("res://scripts/settings_view.gd")
const TutorialView = preload("res://scripts/tutorial_view.gd")
const MENU_TITLE_EN = preload("res://assets/ui/menu/title_en.png")
const SETTINGS_GEAR = preload("res://assets/ui/settings_gear.svg")

const GameThemeScript = preload("res://scripts/game_theme.gd")
const CarArtScript = preload("res://scripts/car_art.gd")
const GroundShadowScript = preload("res://scripts/vehicle_ground_shadow.gd")
const GiftMotionScript = preload("res://scripts/gift_box_motion.gd")
const HomeButtonScript = preload("res://scripts/home_button.gd")
const FeedbackSymbolScript = preload("res://scripts/feedback_symbol.gd")
const MenuTrafficScript = preload("res://scripts/menu_traffic.gd")
const MENU_EDGE_SHADER = preload("res://assets/ui/menu/edge_extend.gdshader")
const MENU_LOCKED_SHADER = preload("res://assets/ui/menu/locked_mode.gdshader")
const MENU_BACKGROUND = preload("res://assets/ui/menu/background.png")
const MENU_TITLE = preload("res://assets/ui/menu/title_cn.png")
const MENU_LOCK = preload("res://assets/ui/menu/lock.png")
const MENU_BUTTONS := {
	"starter": preload("res://assets/ui/menu/starter.png"),
	"history": preload("res://assets/ui/menu/history.png"),
	"garage": preload("res://assets/ui/menu/garage.png"),
}
const VehicleAssetsScript = preload("res://scripts/vehicle_assets.gd")
const ModeProgressionScript = preload("res://scripts/mode_progression.gd")
const DiscoveryPlannerScript = preload("res://scripts/discovery_planner.gd")
const GarageScene = preload("res://scenes/garage.tscn")
const GIFT_BOX_TEXTURE = preload("res://assets/ui/gift_box.png")
const BACKGROUND_TEXTURE = preload("res://assets/ui/main_game_background.png")
const GAME_TITLE_TEXTURE = preload("res://assets/ui/game_title.svg")
const GAMEPLAY_PROGRESS_GIFT_TEXTURE = preload("res://assets/ui/gameplay_progress_gift.png")
const GAMEPLAY_GIFT_TEXTURE = preload("res://assets/ui/gameplay_gift.png")
const GAMEPLAY_FAST_TRACK_TEXTURE = preload("res://assets/ui/speed-motion-v6/track.png")
const GAMEPLAY_FAST_KNOB_TEXTURE = preload("res://assets/ui/speed-motion-v6/knob.webp")
const GAMEPLAY_FAST_BOLT_TEXTURE = preload("res://assets/ui/speed-motion-v6/bolt.webp")
const BUBBLE_SQUARE_PINK_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_pink.png")
const BUBBLE_SQUARE_GREEN_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_green.png")
const BUBBLE_SQUARE_BLUE_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_blue.png")
const BUBBLE_SQUARE_YELLOW_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_yellow.png")
const BUBBLE_SQUARE_PURPLE_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_purple.png")
const BUBBLE_SQUARE_ORANGE_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_orange.png")
const BUBBLE_SQUARE_RED_TEXTURE = preload("res://assets/ui/bubbles/bubble_square_red.png")

enum Phase {
	IDLE,
	PREPARING,
	PACKING,
	ENTERING,
	PRESENTING,
	ANSWERING,
	REVEALING,
	COMPLETE,
}

const JUDGMENT_COUNT := 8
const INPUT_GUARD_SECONDS := 0.10
const HINT_SECONDS := 12.0
const REFERENCE_VIEWPORT_SIZE := Vector2(1080, 1920)
const BOTTOM_GESTURE_CLEARANCE := 120.0
const DEBUG_FOOTER_RESERVATION := 172.0
const FAST_TOGGLE_SIZE := Vector2(260, 134)
const FAST_KNOB_OFF_POSITION := Vector2(105, 26)
const FAST_KNOB_ON_POSITION := Vector2(175, 26)
const IN_GAME_RETURN_BUTTON_SIZE := Vector2(178, 187)
const ROAD_POSITION := Vector2(44, 270)
const CAR_TARGET_POSITION := Vector2(328, 428)
const GIFT_TARGET_POSITION := Vector2(359, 960)
const OPTIONS_POSITION := Vector2(36, 1175)
# Compact ordinary result; the original paper corners and all button artwork
# keep their uniform scale. Discovery cards retain their established geometry.
const COMPLETION_POSITION := Vector2(80, 405)
const COMPLETION_NEW_POSITION := Vector2(80, 268)
const COMPLETION_NEW_SIZE := Vector2(920, 1480)
const COMPLETION_STANDARD_SIZE := Vector2(920, 1150)
const COMPLETION_SCRIM := Color(0.12, 0.23, 0.29, 0.46)
const MODE_SELECTION_POSITION := Vector2.ZERO
const RETURN_CONFIRMATION_POSITION := Vector2(80, 582.5)

# Fully settled packing → next car/options, identical at either speed.
const CLOSED_BOX_HOLD_MS := 500.0

const NORMAL_MS := {
	"car_entry": 600,
	"packing": 800,
	"options": 400,
	"reveal": 700,
	"correct_feedback": 800,
	"incorrect_feedback": 1000,
}

const FAST_MS := {
	"car_entry": 100,
	"packing": 80,
	"options": 100,
	"reveal": 180,
	"correct_feedback": 250,
	"incorrect_feedback": 350,
}

const CAR_COLORS := GameThemeScript.CAR_COLORS

const CAR_BUBBLE_COLORS := Content.CAR_BACKPLATE_COLORS

const CAR_NAMES := {
	"fire_truck": "消防车",
	"ambulance": "救护车",
	"race_car": "赛车",
	"excavator": "挖掘机",
	"city_bus": "公交车",
	"police_car": "警车",
	"taxi": "出租车",
	"school_bus": "校车",
}

var _super_mode := false
var _super_car_pool: Array[String] = []
var _race = RaceSessionScript.new()
var _race_save_result: Dictionary = {}
var _super_hold: Control
var _super_result_view: Control
var _super_release_blocked := false
var _charge_sounding := false

var phase := Phase.IDLE
var _plan: Dictionary = {}
var _judgment_index := 0
var _correct_count := 0
var _judgment_results: Array[bool] = []
var _run_token := 0
var _answer_ready_at_ms := 0
var _hinted := false
var _hint_motion_active := false
var _hint_rest_position := Vector2.ZERO
var _fast_mode := false
var _active_tween: Tween
var _active_fast_multiplier := 1.0
var _active_kind := ""
var _active_base_seconds := 1.0
var _gameplay_paused := false
var _gameplay_elapsed_ms := 0.0
var _closed_box_ready_at_ms := 0.0
var _gameplay_tweens: Array[Tween] = []
var _gift_motion: Control
var _packing_start := Vector2.ZERO
var _packing_fast := false
var _packing_close_played := true
var _fast_track_material: ShaderMaterial
var _fast_bolt: TextureRect
var _fast_bolt_material: ShaderMaterial
var _speed_charge_progress := -1.0
var _speed_charge_elapsed := 0.0
var _speed_race_elapsed := 0.0
var _speed_race_entry_scale := SpeedMotion.RACE_SCALE
var _current_mode := "starter"
var _progress_persistence_enabled := true
var _preparation_click_ready := false
var _discovery_plan: Dictionary = {}
var _discovery_override: Dictionary = {}
var _newly_collected_this_level: Array[String] = []
var _debug_next_discovery_count := -1
var _content_offset := Vector2.ZERO
var _car_road_offset := Vector2.ZERO
var _menu_title_road_offset := 0.0
var _menu_action_road_offset := 0.0
var _memory_road_offset := Vector2.ZERO
var _fast_visual_padding := Vector2.ZERO
var _feedback_base_y := 1410.0

var _gameplay_canvas: Control
var _gameplay_screen_motion: Node
var _menu_screen_motion: Node
var _title_label: TextureRect
var _subtitle_label: Label
var _mode_backdrop: TextureRect
var _menu_surround: TextureRect
var _fast_toggle: CheckButton
var _fast_toggle_art: TextureRect
var _fast_toggle_knob: TextureRect
var _fast_toggle_knob_tween: Tween
var _in_game_return_button: Button
var _debug_discovery_selector: OptionButton
var _debug_reset_button: Button
var _instruction_label: Label
var _progress_box: HBoxContainer
var _progress_labels: Array[TextureRect] = []
var _progress_materials: Array[ShaderMaterial] = []
var _progress_badges: Array[Panel] = []
var _progress_badge_labels: Array[Label] = []
var _road_panel: PanelContainer
var _gift_panel: PanelContainer
var _gift_art: TextureRect
var _gift_label: Label
var _current_card: PanelContainer
var _current_card_shadow: TextureRect
var _current_card_background: TextureRect
var _current_ground_shadow: Node2D
var _current_art: Control
var _current_label: Label
var _options_box: Control
var _option_buttons: Array[Button] = []
var _option_shadows: Array[TextureRect] = []
var _option_backgrounds: Array[TextureRect] = []
var _option_art: Array[Control] = []
var _option_labels: Array[Label] = []
var _option_feedback_frames: Array[Panel] = []
var _option_feedback_badges: Array[Panel] = []
var _option_feedback_labels: Array[FeedbackSymbolScript] = []
var _option_press_tweens: Dictionary = {}
var _feedback_label: Label
var _completion_panel: PanelContainer
var _completion_title_label: Label
var _completion_names_label: Label
var _completion_decoration: Control
var _completion_car_showcase: Control
var _completion_car_cards: Array[Panel] = []
var _completion_car_backgrounds: Array[TextureRect] = []
var _completion_car_art: Array[Control] = []
var _completion_car_labels: Array[Label] = []
var _completion_backdrop: ColorRect
var _return_dialog_motion: RefCounted
var _completion_dialog_motion: RefCounted
var _return_heading: Label
var _return_description: Label
var _return_saved_focus: Dictionary = {}
var _garage_button: Button
var _replay_button: Button
var _mode_select_button: Button
var _mode_panel: PanelContainer
var _starter_mode_button: Button
var _history_mode_button: Button
var _garage_mode_button: Button
var _reset_progress_button: Button
var _reset_progress_blocker: ColorRect
var _reset_progress_panel: PanelContainer
var _reset_dialog_motion: RefCounted
var _mode_icons: Dictionary = {}
var _return_confirmation_blocker: ColorRect
var _return_confirmation_panel: PanelContainer
var _hint_timer: Timer
var _garage_view: Control
var _garage_return_screen := "mode"
var _settings_button: Button
var _settings_view: Control
var _settings_saved_focus: Dictionary = {}
var _settings_resume_game := false
var _settings_previous_focus: Control
var _settings_restore_focus := false
var _tutorial_view: Control
var _tutorial_active := false
var _tutorial_origin := "first_start"
var _tutorial_stage := ""
var _tutorial_restore: Dictionary = {}
var _tutorial_demonstrating := false
var _tutorial_replaying := false
var _tutorial_model_input := false
var _tutorial_feedback_tween: Tween
var _tutorial_feedback_index := -1
var _tutorial_feedback_progress := 0.0
var _tutorial_feedback_rest_position := Vector2.ZERO
var _tutorial_feedback_check_shown := false
var _tutorial_committed_scale := 1.0


var _web_language_callback: JavaScriptObject


func _web_language_changed(args: Array) -> void:
	if args.is_empty():
		return
	L.set_language(str(args[0]))
	_refresh_localization()


func _ready() -> void:
	if Engine.is_editor_hint() and not get_meta("content_preview", false):
		return
	set_meta("ui_scope", "game")
	_build_ui()
	resized.connect(_apply_responsive_layout)
	if get_viewport() is Window: get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	if get_meta("content_preview", false):
		return
	if OS.has_feature("web"):
		_web_language_callback = JavaScriptBridge.create_callback(_web_language_changed)
		JavaScriptBridge.get_interface("window").peekVroomSetLanguage = _web_language_callback
	_load_fast_mode()
	call_deferred("_show_mode_selection")
	_install_custom_ui.call_deferred()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.name = "Background"
	background.color = GameThemeScript.BACKGROUND_COLOR
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var sun := ColorRect.new()
	sun.name = "SkyGlow"
	sun.color = GameThemeScript.SKY_GLOW_COLOR
	sun.position = Vector2(0, 0)
	sun.size = Vector2(REFERENCE_VIEWPORT_SIZE.x, 260)
	sun.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sun)

	var background_art := TextureRect.new()
	background_art.name = "BackgroundArt"
	background_art.texture = Content.asset(BACKGROUND_TEXTURE)
	background_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_art)

	_gameplay_canvas = Control.new()
	_gameplay_canvas.name = "GameplayCanvas"
	_gameplay_canvas.position = Vector2.ZERO
	_gameplay_canvas.size = REFERENCE_VIEWPORT_SIZE
	_gameplay_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_gameplay_canvas)
	_gameplay_screen_motion = preload("res://scripts/paper_screen_motion.gd").install(_gameplay_canvas)

	_title_label = _make_title_image()
	_title_label.name = "Title"
	_title_label.position = Vector2(240, 28)
	_title_label.size = Vector2(600, 66)
	_title_label.visible = false
	_gameplay_canvas.add_child(_title_label)

	_subtitle_label = _make_label("Peek-a-Vroom", 24, Color("456279"), HORIZONTAL_ALIGNMENT_CENTER)
	_subtitle_label.name = "Subtitle"
	_subtitle_label.position = Vector2(240, 88)
	_subtitle_label.size = Vector2(600, 40)
	_subtitle_label.visible = false
	_gameplay_canvas.add_child(_subtitle_label)

	_fast_toggle = CheckButton.new()
	_fast_toggle.name = "FastModeToggle"
	_fast_toggle.text = ""
	_fast_toggle.position = Vector2(698, 1651)
	_fast_toggle.size = FAST_TOGGLE_SIZE
	_fast_toggle.tooltip_text = L.text("快速模式")
	_apply_invisible_button_style(_fast_toggle)
	_fast_toggle.toggled.connect(_on_fast_mode_toggled)
	_gameplay_canvas.add_child(_fast_toggle)
	_fast_toggle_art = TextureRect.new()
	_fast_toggle_art.name = "Track"
	_fast_toggle_art.position = Vector2(104, 39)
	_fast_toggle_art.size = Vector2(150, 58)
	_fast_toggle_art.texture = Content.asset(GAMEPLAY_FAST_TRACK_TEXTURE)
	_fast_toggle_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fast_toggle_art.stretch_mode = TextureRect.STRETCH_SCALE
	_fast_toggle_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fast_toggle.add_child(_fast_toggle_art)
	var track_shader := preload("res://assets/ui/speed-motion-v6/track.gdshader")
	_fast_track_material = ShaderMaterial.new()
	_fast_track_material.shader = track_shader
	_fast_toggle_art.material = _fast_track_material
	var fast_bolt := TextureRect.new()
	fast_bolt.name = "Bolt"
	fast_bolt.position = Vector2(8, 8)
	fast_bolt.size = Vector2(104, 120)
	fast_bolt.texture = Content.asset(GAMEPLAY_FAST_BOLT_TEXTURE)
	fast_bolt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fast_bolt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fast_bolt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fast_toggle.add_child(fast_bolt)
	_fast_bolt = fast_bolt
	_fast_bolt.pivot_offset = fast_bolt.size * 0.5
	_fast_bolt.z_index = 2
	_fast_bolt_material = ShaderMaterial.new()
	_fast_bolt_material.shader = preload("res://assets/ui/speed-motion-v6/bolt.gdshader")
	_fast_bolt.material = _fast_bolt_material
	_fast_toggle_knob = TextureRect.new()
	_fast_toggle_knob.name = "Knob"
	_fast_toggle_knob.position = FAST_KNOB_OFF_POSITION
	_fast_toggle_knob.size = Vector2(84, 84)
	_fast_toggle_knob.pivot_offset = _fast_toggle_knob.size / 2.0
	_fast_toggle_knob.texture = Content.asset(GAMEPLAY_FAST_KNOB_TEXTURE)
	_fast_toggle_knob.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fast_toggle_knob.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_fast_toggle_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fast_toggle.add_child(_fast_toggle_knob)
	# Capture the gesture above BaseButton: native toggling cannot leak after a hold.
	_fast_toggle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fast_toggle.focus_mode = Control.FOCUS_NONE
	_super_hold = RaceHoldScript.new()
	_super_hold.name = "SuperHoldInput"
	_fast_toggle.add_child(_super_hold)
	_super_hold.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_super_hold.short_pressed.connect(func():
		if not _super_mode: _on_fast_mode_toggled(not _fast_mode))
	_super_hold.activated.connect(_activate_super_mode)
	_super_hold.charge_changed.connect(_show_super_charge)
	_super_hold.cancelled.connect(_cancel_super_charge)
	_super_hold.released.connect(func():
		_super_release_blocked = false
		if _super_mode and _preparation_click_ready: _current_card.grab_focus())


	_in_game_return_button = HomeButtonScript.new() as Button
	_in_game_return_button.name = "InGameReturn"
	_in_game_return_button.position = Vector2(64, 1605)
	_in_game_return_button.size = IN_GAME_RETURN_BUTTON_SIZE
	_in_game_return_button.tooltip_text = L.text("返回主页")
	_in_game_return_button.visible = false
	_in_game_return_button.pressed.connect(_show_return_confirmation)
	_gameplay_canvas.add_child(_in_game_return_button)

	if OS.is_debug_build():
		_debug_discovery_selector = OptionButton.new()
		_debug_discovery_selector.name = "DebugDiscoverySelector"
		_debug_discovery_selector.position = Vector2(700, 1780)
		_debug_discovery_selector.size = Vector2(340, 82)
		_debug_discovery_selector.add_theme_font_size_override("font_size", 23)
		for item_text in ["开发测试：随机", "下一关：0 辆新车", "下一关：1 辆新车", "下一关：2 辆新车"]:
			_debug_discovery_selector.add_item(L.text(item_text))
		_debug_discovery_selector.item_selected.connect(_on_debug_discovery_selected)
		_debug_discovery_selector.z_index = 20
		add_child(_debug_discovery_selector)
		_debug_reset_button = Button.new()
		_debug_reset_button.name = "DebugResetProgress"
		_debug_reset_button.text = L.text("开发测试：复位进度")
		_debug_reset_button.position = Vector2(40, 1780)
		_debug_reset_button.size = Vector2(330, 82)
		_debug_reset_button.add_theme_font_size_override("font_size", 23)
		_debug_reset_button.pressed.connect(_on_debug_reset_progress)
		_debug_reset_button.z_index = 20
		add_child(_debug_reset_button)

	_progress_box = HBoxContainer.new()
	_progress_box.name = "Progress"
	_progress_box.position = Vector2(207, 171)
	_progress_box.size = Vector2(686, 67)
	_progress_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_progress_box.add_theme_constant_override("separation", 18)
	_gameplay_canvas.add_child(_progress_box)
	var progress_shader := Shader.new()
	progress_shader.code = """
		shader_type canvas_item;
		uniform float saturation = 1.0;
		uniform float paper_wash = 0.0;
		void fragment() {
			vec4 source = texture(TEXTURE, UV);
			float gray = dot(source.rgb, vec3(0.299, 0.587, 0.114));
			vec3 colored = mix(vec3(gray), source.rgb, saturation);
			colored = mix(colored, vec3(1.0), paper_wash);
			COLOR = vec4(colored, source.a);
		}
	"""
	for index in range(JUDGMENT_COUNT):
		var marker := TextureRect.new()
		marker.name = "Gift%d" % (index + 1)
		marker.custom_minimum_size = Vector2(70, 67)
		marker.texture = Content.asset(GAMEPLAY_PROGRESS_GIFT_TEXTURE)
		marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var marker_material := ShaderMaterial.new()
		marker_material.shader = progress_shader
		marker.material = marker_material
		var badge := Panel.new()
		badge.name = "StatusBadge"
		badge.position = Vector2(43, 38)
		badge.size = Vector2(27, 27)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.visible = false
		badge.z_index = 2
		marker.add_child(badge)
		var badge_label := _make_label("", 19, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
		badge_label.name = "Symbol"
		badge_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(badge_label)
		_progress_box.add_child(marker)
		_progress_labels.append(marker)
		_progress_materials.append(marker_material)
		_progress_badges.append(badge)
		_progress_badge_labels.append(badge_label)

	_instruction_label = _make_label(Content.text("remember"), 36, Color("17324d"), HORIZONTAL_ALIGNMENT_CENTER)
	_instruction_label.name = "Instruction"
	_instruction_label.position = Vector2(80, 190)
	_instruction_label.size = Vector2(920, 72)
	_gameplay_canvas.add_child(_instruction_label)

	_road_panel = PanelContainer.new()
	_road_panel.name = "Road"
	_road_panel.position = ROAD_POSITION
	_road_panel.size = Vector2(992, 320)
	_road_panel.add_theme_stylebox_override("panel", _style(Color(0, 0, 0, 0), 38))
	_gameplay_canvas.add_child(_road_panel)

	var road_label := _make_label("", 42, Color("f6e27f"), HORIZONTAL_ALIGNMENT_CENTER)
	road_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	road_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	road_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_road_panel.add_child(road_label)

	_gift_panel = PanelContainer.new()
	_gift_panel.name = "GiftBox"
	_gift_panel.position = GIFT_TARGET_POSITION
	_gift_panel.size = Vector2(382, 363)
	_gift_panel.pivot_offset = _gift_panel.size / 2.0
	_gift_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_gameplay_canvas.add_child(_gift_panel)

	var gift_content := Control.new()
	gift_content.name = "GiftContent"
	gift_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gift_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gift_content.clip_contents = false
	_gift_panel.add_child(gift_content)

	_gift_art = TextureRect.new()
	_gift_art.name = "Illustration"
	_gift_art.position = Vector2.ZERO
	_gift_art.size = Vector2(382, 363)
	_gift_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_gift_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_gift_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gift_art.texture = Content.asset(GAMEPLAY_GIFT_TEXTURE)
	gift_content.add_child(_gift_art)
	_gift_motion = GiftMotionScript.new()
	_gift_motion.name = "PaperBoxMotion"
	_gift_art.add_child(_gift_motion)
	_gift_motion.setup(_gift_art)

	_gift_label = _make_label("", 42, Color("a34343"), HORIZONTAL_ALIGNMENT_CENTER)
	_gift_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_gift_label.position = Vector2(46, 260)
	_gift_label.size = Vector2(290, 70)
	_gift_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gift_label.visible = false
	gift_content.add_child(_gift_label)

	_current_card = PanelContainer.new()
	_current_card.name = "CurrentCar"
	_current_card.position = CAR_TARGET_POSITION
	_current_card.size = Vector2(446, 417)
	_current_card.pivot_offset = _current_card.size / 2.0
	_current_card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_current_card.gui_input.connect(_on_current_card_gui_input)
	_gameplay_canvas.add_child(_current_card)

	_current_card_shadow = TextureRect.new()
	_current_card_shadow.name = "CardShadow"
	_current_card_shadow.set_meta("car_backplate", true)
	_current_card_shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_current_card_shadow.position = Vector2(7, 13)
	_current_card_shadow.texture = Content.asset(BUBBLE_SQUARE_GREEN_TEXTURE)
	_current_card_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_current_card_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_current_card_shadow.self_modulate = Color(0.16, 0.25, 0.34, 0.20)
	_current_card_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_current_card.add_child(_current_card_shadow)

	_current_card_background = TextureRect.new()
	_current_card_background.name = "CardBackground"
	_current_card_background.set_meta("car_backplate", true)
	_current_card_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_current_card_background.texture = Content.asset(BUBBLE_SQUARE_GREEN_TEXTURE)
	_current_card_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_current_card_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_current_card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_current_card.add_child(_current_card_background)

	var current_card_content := Control.new()
	current_card_content.name = "CurrentCarContent"
	current_card_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_card_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_current_card.add_child(current_card_content)

	_current_ground_shadow = GroundShadowScript.new()
	_current_ground_shadow.name = "GroundShadow"
	current_card_content.add_child(_current_ground_shadow)

	_current_art = CarArtScript.new() as Control
	_current_art.name = "CarArt"
	_current_art.position = Vector2(28, 62)
	_current_art.size = Vector2(368, 244)
	_current_art.visible = false
	current_card_content.add_child(_current_art)
	_current_card.item_rect_changed.connect(_sync_current_ground_shadow)
	_current_art.item_rect_changed.connect(_sync_current_ground_shadow)

	_current_label = _make_label("汽车", 44, Color("17324d"), HORIZONTAL_ALIGNMENT_CENTER)
	_current_label.name = "CarName"
	_current_label.set_meta("localization_skip_text", true)
	_current_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_current_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_current_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	current_card_content.add_child(_current_label)

	_options_box = Control.new()
	_options_box.name = "AnswerOptions"
	_options_box.position = OPTIONS_POSITION
	_options_box.size = Vector2(972, 381)
	_gameplay_canvas.add_child(_options_box)
	for option_index in range(4):
		var button := Button.new()
		button.name = "Option%d" % (option_index + 1)
		button.size = Vector2(390, 230)
		button.add_theme_font_size_override("font_size", 34)
		button.pivot_offset = button.size / 2.0
		button.set_meta("audio_role", &"answer")
		button.button_down.connect(_on_option_button_down.bind(option_index))
		button.button_up.connect(_on_option_button_up.bind(option_index))
		button.pressed.connect(_on_option_pressed.bind(option_index))
		_apply_invisible_button_style(button)
		_options_box.add_child(button)
		_option_buttons.append(button)
		button.set_meta("car_backplate", true)
		button.set_meta("answer_backplate", true)

		var card_shadow := TextureRect.new()
		card_shadow.name = "CardShadow"
		card_shadow.set_meta("car_backplate", true)
		card_shadow.set_meta("answer_backplate", true)
		card_shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_shadow.position = Vector2(7, 13)
		card_shadow.texture = Content.asset(BUBBLE_SQUARE_BLUE_TEXTURE)
		card_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_shadow.self_modulate = Color(0.16, 0.25, 0.34, 0.22)
		card_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(card_shadow)
		_option_shadows.append(card_shadow)

		var card_background := TextureRect.new()
		card_background.name = "CardBackground"
		card_background.set_meta("car_backplate", true)
		card_background.set_meta("answer_backplate", true)
		card_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_background.texture = Content.asset(BUBBLE_SQUARE_BLUE_TEXTURE) if option_index % 2 == 0 else Content.asset(BUBBLE_SQUARE_YELLOW_TEXTURE)
		card_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(card_background)
		_option_backgrounds.append(card_background)

		var art := CarArtScript.new() as Control
		art.name = "CarArt"
		art.position = Vector2(14, 22)
		art.size = Vector2(145, 116)
		button.add_child(art)
		_option_art.append(art)

		var label := _make_label("", 34, Color("17324d"), HORIZONTAL_ALIGNMENT_CENTER)
		label.name = "CarName"
		label.set_meta("localization_skip_text", true)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(label)
		_option_labels.append(label)

		var feedback_frame := Panel.new()
		feedback_frame.name = "FeedbackFrame"
		feedback_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		feedback_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		feedback_frame.visible = false
		feedback_frame.z_index = 3
		button.add_child(feedback_frame)
		_option_feedback_frames.append(feedback_frame)

		var feedback_badge := Panel.new()
		feedback_badge.name = "FeedbackBadge"
		feedback_badge.anchor_left = 1.0
		feedback_badge.anchor_right = 1.0
		feedback_badge.offset_left = -80.0
		feedback_badge.offset_top = 8.0
		feedback_badge.offset_right = -8.0
		feedback_badge.offset_bottom = 80.0
		feedback_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		feedback_badge.visible = false
		feedback_badge.z_index = 4
		button.add_child(feedback_badge)
		var feedback_symbol := FeedbackSymbolScript.new()
		feedback_symbol.name = "Symbol"
		feedback_symbol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		feedback_symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		feedback_badge.add_child(feedback_symbol)
		button.resized.connect(_layout_option_feedback_badge.bind(button, feedback_badge))
		_layout_option_feedback_badge(button, feedback_badge)
		_option_feedback_badges.append(feedback_badge)
		_option_feedback_labels.append(feedback_symbol)

	_feedback_label = _make_label("", 38, Color("17324d"), HORIZONTAL_ALIGNMENT_CENTER)
	_feedback_label.name = "InlineFeedback"
	_feedback_label.position = Vector2(80, _feedback_base_y)
	_feedback_label.size = Vector2(920, 90)
	_feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_gameplay_canvas.add_child(_feedback_label)

	_completion_backdrop = ColorRect.new()
	_completion_backdrop.name = "CompletionBackdrop"
	_completion_backdrop.color = COMPLETION_SCRIM
	_completion_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_completion_backdrop.visible = false
	_completion_backdrop.z_index = 49
	_gameplay_canvas.add_child(_completion_backdrop)

	_completion_panel = PanelContainer.new()
	_completion_panel.name = "Completion"
	_completion_panel.position = COMPLETION_POSITION
	_completion_panel.size = COMPLETION_STANDARD_SIZE
	_completion_panel.add_theme_stylebox_override("panel", _paper_style(Color("fff8e7"), Color("ffad86"), 8, 48))
	PaperUI.install_panel(_completion_panel)
	# Keep even the paper grain at its native aspect: taller accessible result
	# panels repeat only the quiet middle band instead of stretching its pixels.
	PaperUI.panel_backing(_completion_panel).axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	_completion_panel.visible = false
	_completion_panel.z_index = 50
	_gameplay_canvas.add_child(_completion_panel)

	var completion_content := Control.new()
	completion_content.name = "CompletionContent"
	_completion_panel.add_child(completion_content)
	_completion_title_label = _make_label(Content.text("complete"), 68, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	_completion_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	completion_content.add_child(_completion_title_label)
	PaperUI.heading(_completion_title_label)
	_completion_names_label = _make_label("", 34, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	_completion_names_label.name = "CompletionNames"
	_completion_names_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_completion_names_label.visible = false
	completion_content.add_child(_completion_names_label)
	PaperUI.typography(_completion_names_label)
	_completion_decoration = CompletionStars.new()
	_completion_decoration.name = "CompletionCelebration"
	completion_content.add_child(_completion_decoration)

	_completion_car_showcase = Control.new()
	_completion_car_showcase.name = "CompletionCarShowcase"
	_completion_car_showcase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_completion_car_showcase.visible = false
	completion_content.add_child(_completion_car_showcase)
	_build_completion_car_cards()

	_garage_button = Button.new()
	_garage_button.name = "OpenGarageFromCompletion"
	_garage_button.text = Content.text("garage")
	_garage_button.add_theme_font_size_override("font_size", 47)
	PaperUI.button(_garage_button, PaperUI.YELLOW)
	_garage_button.pressed.connect(_request_completion_action.bind("garage"))
	completion_content.add_child(_garage_button)
	_replay_button = Button.new()
	_replay_button.name = "Replay"
	_replay_button.text = Content.text("replay")
	_replay_button.add_theme_font_size_override("font_size", 47)
	PaperUI.button(_replay_button, PaperUI.BLUE)
	_replay_button.pressed.connect(_request_completion_action.bind("replay"))
	completion_content.add_child(_replay_button)
	_mode_select_button = HomeButtonScript.new() as Button
	_mode_select_button.name = "ChooseMode"
	_mode_select_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_select_button.custom_minimum_size = Vector2(110, 110)
	_mode_select_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mode_select_button.pressed.connect(_request_completion_action.bind("home"))
	completion_content.add_child(_mode_select_button)
	_super_result_view = RaceResultScript.new()
	_super_result_view.name = "SuperResults"
	_super_result_view.hide()
	_completion_panel.add_child(_super_result_view)
	_super_result_view.replay_requested.connect(_request_completion_action.bind("replay"))
	_super_result_view.home_requested.connect(_request_completion_action.bind("home"))
	_completion_dialog_motion = DialogMotion.new(_completion_panel, _completion_backdrop)
	for action in [_garage_button, _replay_button]:
		_wire_dialog_button(action)
	_layout_completion(false)

	_build_mode_selector()
	_build_return_confirmation()
	_build_reset_confirmation()
	_build_settings()
	_build_tutorial()
	_garage_view = GarageScene.instantiate() as Control
	_garage_view.set_meta("content_preview", get_meta("content_preview", false))
	_garage_view.close_requested.connect(_on_garage_close_requested)
	_garage_view.car_viewed.connect(_on_garage_car_viewed)
	add_child(_garage_view)

	_hint_timer = Timer.new()
	_hint_timer.name = "HintTimer"
	_hint_timer.one_shot = true
	_hint_timer.wait_time = Content.setting("hint_seconds")
	_hint_timer.timeout.connect(_on_hint_timeout)
	add_child(_hint_timer)

	_options_box.visible = false
	_current_card.visible = false


func _build_completion_car_cards() -> void:
	var showcase_textures: Array[Texture2D] = [Content.asset(BUBBLE_SQUARE_BLUE_TEXTURE), Content.asset(BUBBLE_SQUARE_YELLOW_TEXTURE)]
	for index in range(2):
		var card := Panel.new()
		card.name = "NewCarCard%d" % (index + 1)
		card.position = Vector2(index * 385, 0)
		card.size = Vector2(357, 365)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.visible = false
		card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		_completion_car_showcase.add_child(card)
		_completion_car_cards.append(card)

		var background := TextureRect.new()
		background.name = "CardBackground"
		background.set_meta("car_backplate", true)
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.texture = showcase_textures[index]
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(background)
		_completion_car_backgrounds.append(background)

		var art := CarArtScript.new() as Control
		art.name = "CarArt"
		art.position = Vector2(30, 24)
		art.size = Vector2(297, 259)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(art)
		_completion_car_art.append(art)

		var label := _make_label("", 38, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
		PaperUI.typography(label)
		label.name = "CarName"
		label.set_meta("localization_skip_text", true)
		label.position = Vector2(15, 269)
		label.size = Vector2(327, 64)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(label)
		_completion_car_labels.append(label)


func _set_completion_car_showcase(car_ids: Array[String]) -> void:
	var has_cars := not car_ids.is_empty()
	_completion_names_label.visible = has_cars
	_completion_car_showcase.visible = has_cars
	_layout_completion(has_cars)
	for index in range(_completion_car_cards.size()):
		var card := _completion_car_cards[index]
		var visible_card := index < car_ids.size()
		card.visible = visible_card
		if not visible_card:
			continue
		var car_id := car_ids[index]
		card.position.x = 192.5 if car_ids.size() == 1 else index * 385
		_completion_car_backgrounds[index].texture = Content.backplate_texture(car_id, BUBBLE_SQUARE_BLUE_TEXTURE if index == 0 else BUBBLE_SQUARE_YELLOW_TEXTURE)
		_completion_car_art[index].call("set_car_id", car_id)
		_completion_car_labels[index].text = _car_name(car_id)


func _layout_completion(has_cars: bool) -> void:
	if _super_mode and phase == Phase.COMPLETE:
		_completion_panel.position = Vector2(80,220)
		_completion_panel.size = Vector2(920,1480)
		return
	_completion_panel.position = COMPLETION_NEW_POSITION if has_cars else COMPLETION_POSITION
	_completion_panel.size = COMPLETION_NEW_SIZE if has_cars else COMPLETION_STANDARD_SIZE
	PaperUI.place(_completion_title_label, Rect2(70, 132 if has_cars else 110, 780, 100))
	_align_completion_title()
	PaperUI.place(_completion_names_label, Rect2(70, 238 if has_cars else 245, 780, 150 if not has_cars else 64))
	PaperUI.place(_completion_decoration, Rect2(150, 225, 620, 200))
	_completion_decoration.visible = not has_cars and not _completion_names_label.visible
	PaperUI.place(_completion_car_showcase, Rect2(89, 346, 742, 365))
	PaperUI.place(_garage_button, Rect2(105, 945 if has_cars else 665, 710, 195))
	PaperUI.place(_replay_button, Rect2(105, 720 if has_cars else 445, 710, 195))
	PaperUI.button(_garage_button, PaperUI.YELLOW)
	# Let the existing yellow paper blend into the cream backing. Its complete
	# texture/white rim remain contained; only this secondary action is quieter.
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		_garage_button.get_theme_stylebox(state).modulate_color.a *= 0.62
	PaperUI.button(_replay_button, PaperUI.BLUE)
	PaperUI.place(_mode_select_button, Rect2(405, 1195 if has_cars else 875, 110, 110))
	_mode_select_button.set_meta("authored_visual_size", Vector2(110, 110))
	_mode_select_button.add_theme_constant_override("icon_max_width", 110)
	var unit := _gameplay_canvas.scale.y / Responsive.units_per_point(self)
	Responsive.touch_frame(_garage_button, Rect2(105, 945 if has_cars else 665, 710, 195), unit)
	Responsive.touch_frame(_replay_button, Rect2(105, 720 if has_cars else 445, 710, 195), unit)
	Responsive.touch_frame(_mode_select_button, Rect2(405, 1195 if has_cars else 875, 110, 110), unit)
	var ordered := [_replay_button, _garage_button, _mode_select_button]
	for index in range(1, ordered.size()):
		ordered[index].position.y = maxf(ordered[index].position.y, ordered[index-1].position.y + ordered[index-1].size.y + 8.0 / unit)
	var paper_inset := (PaperUI.PANEL_SOURCE_SIZE.y - PaperUI.PANEL_INNER_BOTTOM_Y) * _completion_panel.size.x / PaperUI.PANEL_SOURCE_SIZE.x
	# The enlarged native hit target needs room above the painted inner border
	# as well as the house's 10px paper shadow, including short/safe-area screens.
	var footer := paper_inset + 80.0 + 10.0
	var extra := maxf(0.0, _mode_select_button.position.y + _mode_select_button.size.y + footer - _completion_panel.size.y)
	_completion_panel.size.y += extra
	_completion_panel.position.y -= extra * 0.5


func _align_completion_title() -> void:
	# Center the visible glyphs, not the font's advance box: the original font's
	# full-width Chinese exclamation mark has a large blank area on its right.
	# Correct only the title's X position, keeping its font, size and live text.
	var label := _completion_title_label
	if not is_instance_valid(label):
		return
	var line := TextLine.new()
	line.add_string(label.text, label.get_theme_font("font"), label.get_theme_font_size("font_size"))
	var server := TextServerManager.get_primary_interface()
	var pen := 0.0
	var ink_left := INF
	var ink_right := -INF
	for glyph in server.shaped_text_get_glyphs(line.get_rid()):
		var font_rid: RID = glyph.font_rid
		var font_size := Vector2i(int(glyph.font_size), 0)
		var glyph_size := server.font_get_glyph_size(font_rid, font_size, int(glyph.index))
		var offset := server.font_get_glyph_offset(font_rid, font_size, int(glyph.index))
		for repeat in range(int(glyph.repeat)):
			if glyph_size.x > 0.0 and glyph_size.y > 0.0:
				var left: float = pen + glyph.offset.x + offset.x
				ink_left = minf(ink_left, left)
				ink_right = maxf(ink_right, left + glyph_size.x)
			pen += float(glyph.advance)
	var correction := 0.0 if is_inf(ink_left) else (line.get_size().x - ink_left - ink_right) * 0.5
	label.position.x = (_completion_panel.size.x - label.size.x) * 0.5 + correction


func _wire_dialog_button(button: Button) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.resized.connect(func(): button.pivot_offset = button.size * 0.5)
	preload("res://scripts/paper_button_motion.gd").install(button)


func _dialog_reduced_motion() -> bool:
	var save = get_node_or_null("/root/SaveData")
	var settings: Dictionary = save.data.get("settings", {}) if save != null else {}
	return _fast_mode or bool(settings.get("reduced_motion", false))


func _cancel_dialog_motion() -> void:
	_set_return_focus_locked(false)
	for motion in [_return_dialog_motion, _completion_dialog_motion]:
		if motion != null:
			motion.cancel()


func _request_completion_action(action: String) -> void:
	if phase != Phase.COMPLETE or _completion_dialog_motion.closing:
		return
	var token := _run_token
	var on_closed := func():
		if token != _run_token or phase != Phase.COMPLETE:
			return
		match action:
			"replay": _start_level()
			"home": _show_mode_selection()
			"garage": _open_garage("completion")
	_completion_dialog_motion.dismiss(on_closed, _dialog_reduced_motion())


func _build_mode_selector() -> void:
	_menu_surround = TextureRect.new()
	_menu_surround.name = "MenuSurround"
	_menu_surround.texture = Content.asset(MENU_BACKGROUND)
	_menu_surround.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_surround.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_menu_surround.stretch_mode = TextureRect.STRETCH_SCALE
	_menu_surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var edge_material := ShaderMaterial.new()
	edge_material.shader = MENU_EDGE_SHADER
	_menu_surround.material = edge_material
	add_child(_menu_surround)
	_mode_panel = PanelContainer.new()
	_mode_panel.name = "ModeSelection"
	_mode_panel.position = MODE_SELECTION_POSITION
	_mode_panel.size = REFERENCE_VIEWPORT_SIZE
	_mode_panel.clip_contents = true
	_mode_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(_mode_panel)
	_mode_panel.visibility_changed.connect(func(): _menu_surround.visible = _mode_panel.visible)

	_mode_backdrop = TextureRect.new()
	_mode_backdrop.name = "Artwork"
	_mode_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_backdrop.texture = Content.asset(MENU_BACKGROUND)
	_mode_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mode_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mode_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mode_panel.add_child(_mode_backdrop)

	var content := Control.new()
	content.name = "HitTargets"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mode_panel.add_child(content)
	_menu_screen_motion = preload("res://scripts/paper_screen_motion.gd").install(content)
	var menu_title := TextureRect.new()
	menu_title.name = "MenuTitle"
	menu_title.texture = Content.asset(MENU_TITLE)
	menu_title.position = Vector2(219, 149)
	menu_title.size = Vector2(683, 368)
	menu_title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	menu_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(menu_title)
	var traffic := MenuTrafficScript.new()
	traffic.name = "MenuTraffic"
	traffic.size = REFERENCE_VIEWPORT_SIZE
	content.add_child(traffic)
	_starter_mode_button = _make_mode_button("StarterMode", "starter")
	_starter_mode_button.position = Vector2(56, 1021)
	_starter_mode_button.size = Vector2(463, 435)
	_starter_mode_button.pressed.connect(_on_starter_requested)
	content.add_child(_starter_mode_button)
	_history_mode_button = _make_mode_button("HistoryMode", "history")
	_history_mode_button.position = Vector2(563, 1022)
	_history_mode_button.size = Vector2(464, 434)
	_history_mode_button.pressed.connect(_start_mode.bind("history"))
	content.add_child(_history_mode_button)
	var lock_badge := TextureRect.new()
	lock_badge.name = "LockBadge"
	lock_badge.texture = Content.asset(MENU_LOCK)
	lock_badge.position = Vector2(20, -12)
	lock_badge.size = Vector2(138, 155)
	lock_badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lock_badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_history_mode_button.add_child(lock_badge)
	_garage_mode_button = _make_mode_button("OpenGarageFromModes", "garage")
	_garage_mode_button.position = Vector2(69, 1497)
	_garage_mode_button.size = Vector2(958, 302)
	_garage_mode_button.pressed.connect(_open_garage.bind("mode"))
	content.add_child(_garage_mode_button)
	_settings_button = Button.new()
	_settings_button.name = "OpenSettings"
	_settings_button.tooltip_text = L.text("设置")
	_settings_button.icon = SETTINGS_GEAR
	_settings_button.expand_icon = true
	_settings_button.add_theme_constant_override("icon_max_width", 78)
	_settings_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled"]:
		_settings_button.add_theme_stylebox_override(state, PaperUI.sticker(PaperUI.small(PaperUI.BLUE), 0, 23, Color("c7e7f1") if state == "pressed" else Color.WHITE))
	_settings_button.add_theme_stylebox_override("focus", PaperUI.focus())
	PaperUI.place(_settings_button, Rect2(908, 24, 128, 128))
	_settings_button.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton or event is InputEventScreenTouch: _settings_restore_focus = false
		elif event is InputEventKey: _settings_restore_focus = true)
	_settings_button.pressed.connect(_show_settings)
	content.add_child(_settings_button)
	_wire_dialog_button(_settings_button)


func _make_mode_button(button_name: String, mode_name: String) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = L.text({"starter": "入门模式", "history": "历史干扰", "garage": "我的车库"}[mode_name])
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = Color("ffb951")
	focus_style.set_border_width_all(5)
	focus_style.set_corner_radius_all(64)
	button.add_theme_stylebox_override("focus", focus_style)
	var icon := TextureRect.new()
	icon.name = "ModeIcon"
	icon.texture = Content.asset(MENU_BUTTONS[mode_name])
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if mode_name == "history":
		var locked_material := ShaderMaterial.new()
		locked_material.shader = MENU_LOCKED_SHADER
		icon.material = locked_material
	button.add_child(icon)
	_mode_icons[mode_name] = icon
	button.resized.connect(func(): button.pivot_offset = button.size * 0.5)
	preload("res://scripts/paper_button_motion.gd").install(button)
	return button


func _build_return_confirmation() -> void:
	_return_confirmation_blocker = ColorRect.new()
	_return_confirmation_blocker.name = "ReturnConfirmationBlocker"
	_return_confirmation_blocker.color = PaperUI.SCRIM
	_return_confirmation_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_return_confirmation_blocker.visible = false
	_return_confirmation_blocker.z_index = 59
	add_child(_return_confirmation_blocker)

	_return_confirmation_panel = PanelContainer.new()
	_return_confirmation_panel.name = "ReturnConfirmation"
	_return_confirmation_panel.position = RETURN_CONFIRMATION_POSITION
	_return_confirmation_panel.size = Vector2(920, 977)
	_return_confirmation_panel.add_theme_stylebox_override("panel", _paper_style(Color("fff8e7"), Color("ff9b77"), 9, 48))
	PaperUI.install_panel(_return_confirmation_panel)
	_return_confirmation_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_return_confirmation_panel.visible = false
	_return_confirmation_panel.z_index = 60
	add_child(_return_confirmation_panel)
	var content := Control.new()
	content.name = "ReturnContent"
	_return_confirmation_panel.add_child(content)
	var heading := _make_label("休息一下？", 57, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	_return_heading = heading
	PaperUI.place(heading, Rect2(70, 145, 780, 100))
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(heading)
	PaperUI.heading(heading, PaperUI.INK)
	var description := _make_label("这关不会保存。", 35, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	_return_description = description
	PaperUI.typography(description)
	PaperUI.place(description, Rect2(70, 273, 780, 70))
	description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(description)
	var continue_button := Button.new()
	continue_button.name = "ContinueCurrentLevel"
	continue_button.text = L.text("继续玩")
	continue_button.add_theme_font_size_override("font_size", 47)
	PaperUI.button(continue_button, PaperUI.BLUE)
	PaperUI.place(continue_button, Rect2(105, 412, 710, 195))
	continue_button.pressed.connect(_cancel_return_to_level)
	content.add_child(continue_button)
	var return_button := Button.new()
	return_button.name = "ConfirmReturnToModes"
	return_button.text = L.text("主页")
	return_button.add_theme_font_size_override("font_size", 47)
	PaperUI.button(return_button, PaperUI.YELLOW)
	PaperUI.place(return_button, Rect2(105, 637, 710, 195))
	return_button.pressed.connect(_confirm_return_to_modes)
	content.add_child(return_button)

	_return_dialog_motion = DialogMotion.new(_return_confirmation_panel, _return_confirmation_blocker)
	_wire_dialog_button(continue_button)
	_wire_dialog_button(return_button)

func _build_reset_confirmation() -> void:
	_reset_progress_blocker = ColorRect.new()
	_reset_progress_blocker.name = "ResetProgressBlocker"
	_reset_progress_blocker.color = PaperUI.SCRIM
	_reset_progress_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_reset_progress_blocker.z_index = 99
	_reset_progress_blocker.hide()
	add_child(_reset_progress_blocker)
	_reset_progress_panel = PanelContainer.new()
	_reset_progress_panel.name = "ResetProgressConfirmation"
	_reset_progress_panel.size = Vector2(920, 1120)
	_reset_progress_panel.add_theme_stylebox_override("panel", PaperUI.panel())
	PaperUI.install_panel(_reset_progress_panel)
	_reset_progress_panel.z_index = 100
	_reset_progress_panel.hide()
	add_child(_reset_progress_panel)
	var content := Control.new()
	content.name = "ResetContent"
	_reset_progress_panel.add_child(content)
	var heading := _make_label("重置游戏进度？", 60, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	PaperUI.heading(heading)
	PaperUI.place(heading, Rect2(70, 110, 780, 100))
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(heading)
	var description := _make_label("清空记录和解锁，恢复初始车库。\n声音、语言和速度不变。", 34, PaperUI.INK, HORIZONTAL_ALIGNMENT_CENTER)
	PaperUI.typography(description)
	PaperUI.place(description, Rect2(70, 260, 780, 180))
	description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(description)
	var note := _make_label("重置后无法撤销。", 30, Color("a6533d"), HORIZONTAL_ALIGNMENT_CENTER)
	PaperUI.typography(note)
	PaperUI.place(note, Rect2(70, 452, 780, 60))
	note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(note)
	var cancel := Button.new()
	cancel.name = "CancelProgressReset"
	cancel.text = L.text("先不重置")
	cancel.add_theme_font_size_override("font_size", 47)
	PaperUI.button(cancel, PaperUI.BLUE)
	PaperUI.place(cancel, Rect2(105, 550, 710, 195))
	cancel.pressed.connect(_close_reset_confirmation)
	content.add_child(cancel)
	var confirm := Button.new()
	confirm.name = "ConfirmProgressReset"
	confirm.text = L.text("确认重置")
	confirm.add_theme_font_size_override("font_size", 47)
	PaperUI.button(confirm, PaperUI.YELLOW)
	PaperUI.place(confirm, Rect2(105, 775, 710, 195))
	confirm.pressed.connect(_confirm_progress_reset)
	content.add_child(confirm)
	_reset_dialog_motion = DialogMotion.new(_reset_progress_panel, _reset_progress_blocker)


func _show_reset_confirmation() -> void:
	if not _settings_view.visible or not _mode_panel.visible or _reset_progress_panel.visible or _settings_view.motion.closing:
		return
	_settings_view.set_confirmation_open(true)
	_reset_dialog_motion.cancel()
	# Godot GUI picking follows sibling order, not the draw z-index.
	move_child(_reset_progress_blocker, get_child_count() - 1)
	move_child(_reset_progress_panel, get_child_count() - 1)
	for button_name in ["CancelProgressReset", "ConfirmProgressReset"]:
		var button := _reset_progress_panel.find_child(button_name, true, false) as Button
		button.focus_mode = Control.FOCUS_ALL
	var parts := _reset_progress_panel.get_node("ResetContent").get_children()
	_reset_dialog_motion.present("return", [DialogMotion.beat(parts[0],"title"),
		DialogMotion.beat(parts[1],"body"),DialogMotion.beat(parts[2],"detail"),
		DialogMotion.beat(parts[3],"action"),DialogMotion.beat(parts[4],"secondary")], _dialog_reduced_motion())
	if _settings_view.reset_opened_by_keyboard:
		(_reset_progress_panel.find_child("CancelProgressReset", true, false) as Button).grab_focus()


func _restore_settings_after_reset() -> void:
	if is_instance_valid(_settings_view):
		_settings_view.set_confirmation_open(false)
		if _settings_view.visible:
			for button_name in ["CancelProgressReset", "ConfirmProgressReset"]:
				var button := _reset_progress_panel.find_child(button_name, true, false) as Button
				button.focus_mode = Control.FOCUS_NONE
	_update_mode_buttons()


func _cancel_reset_confirmation() -> void:
	if _reset_dialog_motion != null: _reset_dialog_motion.cancel()
	_reset_progress_panel.hide()
	_reset_progress_blocker.hide()
	_restore_settings_after_reset()


func _close_reset_confirmation() -> void:
	_dismiss_reset_confirmation(false)


func _confirm_progress_reset() -> void:
	_dismiss_reset_confirmation(true)


func _dismiss_reset_confirmation(confirmed: bool) -> void:
	if not _reset_progress_panel.visible or not _mode_panel.visible or not _settings_view.visible or _reset_dialog_motion.closing:
		return
	var token := _run_token
	_reset_dialog_motion.dismiss(func():
		if token != _run_token or not _settings_view.visible: return
		_restore_settings_after_reset()
		if confirmed:
			_reset_saved_progress(true)
			_settings_view.show_reset_complete(), false)


func _unhandled_key_input(event: InputEvent) -> void:
	if _tutorial_active and event.is_action_pressed("ui_cancel"):
		_skip_tutorial()
		get_viewport().set_input_as_handled()
		return
	if _reset_progress_panel.visible:
		if event.is_action_pressed("ui_cancel"): _close_reset_confirmation()
		get_viewport().set_input_as_handled()
		return
	if _settings_view.visible:
		if event.is_action_pressed("ui_cancel"): _settings_view.dismiss()
		get_viewport().set_input_as_handled()
		return
	if _return_confirmation_panel.visible and event.is_action_pressed("ui_cancel"):
		_cancel_return_to_level()
		get_viewport().set_input_as_handled()


func _apply_responsive_layout() -> void:
	if _title_label == null:
		return
	if _return_dialog_motion != null:
		_return_dialog_motion.settle_for_layout()
	if _completion_dialog_motion != null:
		_completion_dialog_motion.settle_for_layout()
	if _reset_dialog_motion != null:
		_reset_dialog_motion.settle_for_layout()
	var safe := Responsive.safe_rect(self)
	var uniform_scale := minf(
		safe.size.x / REFERENCE_VIEWPORT_SIZE.x,
		safe.size.y / REFERENCE_VIEWPORT_SIZE.y,
	)
	_gameplay_canvas.size = REFERENCE_VIEWPORT_SIZE
	_gameplay_canvas.scale = Vector2.ONE * uniform_scale
	_gameplay_canvas.position = Vector2(
		safe.position.x + (safe.size.x - REFERENCE_VIEWPORT_SIZE.x * uniform_scale) * 0.5,
		safe.end.y - REFERENCE_VIEWPORT_SIZE.y * uniform_scale,
	)
	_content_offset = Vector2.ZERO
	_update_car_road_alignment()
	if uniform_scale > 0.0:
		_completion_backdrop.position = -_gameplay_canvas.position / uniform_scale
		_completion_backdrop.size = size / uniform_scale
	var sky_glow := get_node_or_null("SkyGlow") as ColorRect
	if sky_glow != null:
		sky_glow.size = Vector2(size.x, 260)
	_mode_panel.size = REFERENCE_VIEWPORT_SIZE
	_mode_panel.scale = Vector2.ONE * uniform_scale
	_mode_panel.position = Vector2(
		safe.position.x + (safe.size.x - REFERENCE_VIEWPORT_SIZE.x * uniform_scale) * 0.5,
		safe.position.y + (safe.size.y - REFERENCE_VIEWPORT_SIZE.y * uniform_scale) * 0.5,
	)
	(_menu_surround.material as ShaderMaterial).set_shader_parameter("viewport_size", size)
	_sync_menu_background()
	_return_confirmation_blocker.position = Vector2.ZERO
	_return_confirmation_blocker.size = size
	_return_confirmation_panel.position = _gameplay_canvas.position + RETURN_CONFIRMATION_POSITION * uniform_scale
	_return_confirmation_panel.scale = Vector2.ONE * uniform_scale
	_reset_progress_blocker.position = Vector2.ZERO
	_reset_progress_blocker.size = size
	_reset_progress_panel.position = _mode_panel.position + Vector2(80, 475) * uniform_scale
	_reset_progress_panel.scale = Vector2.ONE * uniform_scale
	_layout_compact_actions(uniform_scale)
	_layout_completion(_completion_car_showcase.visible)
	if _debug_reset_button != null:
		_debug_reset_button.position = Vector2(40, size.y - BOTTOM_GESTURE_CLEARANCE - _debug_reset_button.size.y)
	if _debug_discovery_selector != null:
		_debug_discovery_selector.position = Vector2(size.x - 380, size.y - BOTTOM_GESTURE_CLEARANCE - _debug_discovery_selector.size.y)


func _layout_compact_actions(canvas_unit: float) -> void:
	var unit := canvas_unit / Responsive.units_per_point(self)
	_in_game_return_button.set_meta("authored_visual_size", IN_GAME_RETURN_BUTTON_SIZE)
	_in_game_return_button.add_theme_constant_override("icon_max_width", int(IN_GAME_RETURN_BUTTON_SIZE.x))
	Responsive.touch_frame(_in_game_return_button, Rect2(Vector2(64,1605), IN_GAME_RETURN_BUTTON_SIZE), unit)
	_in_game_return_button._sync_pivot()
	for state in ["normal","hover","pressed","disabled"]:
		_settings_button.get_theme_stylebox(state).set_meta("authored_visual_size", Vector2(128,128))
	Responsive.touch_frame(_settings_button, Rect2(908,24,128,128), unit)
	# Keep the top-right gear fully inside the centered portrait canvas.
	_settings_button.position.x = minf(_settings_button.position.x, 1040.0 - _settings_button.size.x)
	_settings_button.position.y = maxf(16.0, _settings_button.position.y)
	# Increase only the native target, leaving the approved track/bolt/knob
	# drawing at its original size and ratio.
	_fast_toggle.scale = Vector2.ONE
	Responsive.touch_frame(_fast_toggle, Rect2(Vector2(698,1651), FAST_TOGGLE_SIZE), unit)
	_fast_visual_padding = (_fast_toggle.size - FAST_TOGGLE_SIZE) * 0.5
	_fast_toggle_art.position = Vector2(104,39) + _fast_visual_padding
	_fast_bolt.position = Vector2(8,8) + _fast_visual_padding
	_refresh_fast_toggle_art(false)
	var safe_local := Rect2((Responsive.safe_rect(self).position - _gameplay_canvas.position) / canvas_unit, Responsive.safe_rect(self).size / canvas_unit)
	_fast_toggle.position.x = clampf(_fast_toggle.position.x, safe_local.position.x, safe_local.end.x - _fast_toggle.size.x)
	for row in [
		[_return_confirmation_panel, "ContinueCurrentLevel", "ConfirmReturnToModes", 412.0, 637.0],
		[_reset_progress_panel, "CancelProgressReset", "ConfirmProgressReset", 550.0, 775.0]]:
		var first := (row[0] as Node).find_child(row[1], true, false) as Control
		var second := (row[0] as Node).find_child(row[2], true, false) as Control
		Responsive.touch_frame(first, Rect2(105,row[3],710,195), unit)
		Responsive.touch_frame(second, Rect2(105,row[4],710,195), unit)
		second.position.y = maxf(second.position.y, first.position.y + first.size.y + 8.0 / unit)


func _process(_delta: float) -> void:
	if _fast_bolt != null and _fast_toggle.is_visible_in_tree() and not _gameplay_paused:
		if _super_mode: _speed_race_elapsed += _delta
		_update_speed_motion()
	if is_instance_valid(_super_hold):
		_super_hold.enabled = not _tutorial_active and not _gameplay_paused and _is_level_in_progress() and _fast_toggle.is_visible_in_tree()
	if not _gameplay_paused:
		_gameplay_elapsed_ms += _delta * 1000.0
	_gameplay_tweens = _gameplay_tweens.filter(func(tween: Tween): return tween.is_valid())
	# A custom background can be installed after the initial responsive layout.
	if _gameplay_canvas != null:
		_update_car_road_alignment()
		_sync_current_ground_shadow()


func _sync_current_ground_shadow() -> void:
	if _current_ground_shadow == null or _current_art == null:
		return
	var portrait := _current_art.get_node_or_null("Portrait") as TextureRect
	# CurrentCar hides the entire branch synchronously when packing starts.
	# Do not defer an extra phase-based visibility change into a paused frame.
	_current_ground_shadow.visible = _current_art.visible and portrait != null and portrait.visible and portrait.texture != null
	if not _current_ground_shadow.visible:
		return
	_current_ground_shadow.set_vehicle(portrait.texture, portrait.size)
	_current_ground_shadow.transform = _current_art.get_transform() * portrait.get_transform()
	# The road stays still when the body is lifted or nudged. Horizontal entry,
	# editor sizing and the responsive road offset retain their original transforms.
	if absf(_current_card.scale.y) > 0.0001:
		_current_ground_shadow.position.y -= (_current_card.position.y - _car_target_position().y) / _current_card.scale.y
	var alpha := 1.0
	if portrait.material is ShaderMaterial:
		alpha = float(portrait.material.get_shader_parameter("presentation_alpha"))
	_current_ground_shadow.modulate = Color(1, 1, 1, alpha * _current_art.modulate.a * portrait.modulate.a)


func _update_car_road_alignment() -> void:
	var background := get_node_or_null("BackgroundArt") as TextureRect
	if background == null or background.texture == null or _current_card == null or _gameplay_canvas.scale.y <= 0.0:
		return
	var image_size := background.texture.get_size()
	var reference_scale := maxf(REFERENCE_VIEWPORT_SIZE.x / image_size.x, REFERENCE_VIEWPORT_SIZE.y / image_size.y)
	var reference_crop := (image_size * reference_scale - REFERENCE_VIEWPORT_SIZE) * 0.5
	# Bottom of the vehicle portrait at the approved 9:16 position, in background UVs.
	var road_uv := (Vector2(540, 734) + reference_crop) / (image_size * reference_scale)
	var cover_scale := maxf(size.x / image_size.x, size.y / image_size.y)
	var covered_size := image_size * cover_scale
	var road_point := covered_size * road_uv - (covered_size - size) * 0.5
	# Wide canvases have spare vertical crop: lower the artwork before moving a
	# vehicle above the screen. Tall phones have no spare crop, so the car follows it.
	var reference_road_y := _gameplay_canvas.position.y + 734.0 * _gameplay_canvas.scale.y
	var crop_shift := clampf(reference_road_y - road_point.y, 0.0, maxf(0.0, (covered_size.y - size.y) * 0.5))
	background.offset_bottom = crop_shift * 2.0
	road_point.y += crop_shift
	var local_road := (road_point - _gameplay_canvas.position) / _gameplay_canvas.scale
	var next_offset := Vector2(0, local_road.y - 734.0)
	if not next_offset.is_equal_approx(_car_road_offset):
		if phase != Phase.PACKING:
			_current_card.position += next_offset - _car_road_offset
		_car_road_offset = next_offset
	# A: the box, answer choices and feedback follow the same road correction
	# as the current car. Apply a delta so active hint/answer motion is retained.
	var memory_delta := next_offset - _memory_road_offset
	if not memory_delta.is_zero_approx():
		for control in [_gift_panel, _options_box, _feedback_label]:
			if is_instance_valid(control): control.position += memory_delta
		if _hint_motion_active: _hint_rest_position += memory_delta
		_memory_road_offset = next_offset
	_layout_gameplay_header()


func _layout_gameplay_header() -> void:
	# The car follows the cover-cropped road on tall phones. Its HUD must
	# reserve space above that actual target, not the old bottom-pinned y.
	var safe := Responsive.safe_rect(self)
	var canvas_scale := _gameplay_canvas.scale.y
	if canvas_scale <= 0.0: return
	var safe_top := (safe.position.y - _gameplay_canvas.position.y) / canvas_scale
	var car_top := _car_target_position().y
	_progress_box.position.y = maxf(safe_top + 40.0, car_top - 257.0)
	if is_instance_valid(_tutorial_view):
		var car_frame := Rect2(_gameplay_canvas.position + _car_target_position() * canvas_scale, _current_card.size * canvas_scale)
		_tutorial_view.set_gameplay_layout(safe, car_frame)


func _sync_menu_background() -> void:
	# One continuous, uniformly cover-cropped layer uses the editor's actual
	# background. A separate center image plus old/mirrored margins made seams.
	if _mode_backdrop.texture == null: return
	_menu_surround.texture = _mode_backdrop.texture
	_mode_backdrop.hide()
	var texture_size := _mode_backdrop.texture.get_size()
	var cover_scale := maxf(size.x / texture_size.x, size.y / texture_size.y)
	var cover_size := texture_size * cover_scale
	var frame := Rect2((size - cover_size) * 0.5, cover_size)
	(_menu_surround.material as ShaderMaterial).set_shader_parameter("artwork_rect", Vector4(frame.position.x, frame.position.y, frame.size.x, frame.size.y))
	# Keep the existing rigid vehicles on the background's road after crop.
	# Vehicle size, wheels, spring motion and driving speed do not change.
	var traffic := _mode_panel.find_child("MenuTraffic", true, false) as Control
	if traffic != null:
		var contain_scale := minf(REFERENCE_VIEWPORT_SIZE.x / texture_size.x, REFERENCE_VIEWPORT_SIZE.y / texture_size.y)
		var contained := texture_size * contain_scale
		var reference_origin := (REFERENCE_VIEWPORT_SIZE - contained) * 0.5
		var road_uv := (Vector2(540, MenuTrafficScript.ROAD_BOTTOM) - reference_origin) / contained
		var road_local := frame.position + road_uv * frame.size
		var parent_transform := (traffic.get_parent() as Control).get_global_transform().affine_inverse() * get_global_transform()
		traffic.position.y = (parent_transform * road_local).y - MenuTrafficScript.ROAD_BOTTOM
		# A keeps the three menu entry illustrations together with the road.
		var next_action_offset: float = traffic.position.y
		var safe_local_end: float = (parent_transform * Responsive.safe_rect(self).end).y
		var authored_bottom: float = _garage_mode_button.position.y - _menu_action_road_offset + _garage_mode_button.size.y
		next_action_offset = minf(next_action_offset, safe_local_end - authored_bottom - 24.0)
		for action in [_starter_mode_button,_history_mode_button,_garage_mode_button]:
			action.position.y += next_action_offset - _menu_action_road_offset
		_menu_action_road_offset = next_action_offset
		var title := _mode_panel.find_child("MenuTitle", true, false) as Control
		if title != null:
			# Preserve the approved title/vehicle separation on taller screens.
			var safe := Responsive.safe_rect(self)
			var safe_top := (parent_transform * safe.position).y
			var next_title_offset := maxf(traffic.position.y, safe_top + 40.0 - 149.0)
			title.position.y += next_title_offset - _menu_title_road_offset
			_menu_title_road_offset = next_title_offset


func _car_target_position() -> Vector2:
	return CAR_TARGET_POSITION + _car_road_offset


func _content_position(reference_position: Vector2) -> Vector2:
	return reference_position + _memory_road_offset


func _fast_toggle_y() -> float:
	return 1651.0


func _answer_area_top() -> float:
	return 1175.0


func _set_return_focus_locked(locked: bool) -> void:
	if locked:
		for control in _option_buttons + [_fast_toggle, _super_hold, _current_card, _debug_reset_button, _debug_discovery_selector]:
			if not is_instance_valid(control):
				continue
			if not _return_saved_focus.has(control):
				_return_saved_focus[control] = control.focus_mode
			control.focus_mode = Control.FOCUS_NONE
	else:
		for control in _return_saved_focus:
			if is_instance_valid(control):
				control.focus_mode = _return_saved_focus[control]
		_return_saved_focus.clear()


func _show_return_confirmation() -> void:
	if not _is_level_in_progress() or _gameplay_paused:
		return
	_set_gameplay_paused(true)
	_set_return_focus_locked(true)
	_in_game_return_button.visible = false
	_return_dialog_motion.present("return", [DialogMotion.beat(_return_heading,"title"),
		DialogMotion.beat(_return_description,"detail"),
		DialogMotion.beat(_return_confirmation_panel.find_child("ContinueCurrentLevel",true,false),"action"),
		DialogMotion.beat(_return_confirmation_panel.find_child("ConfirmReturnToModes",true,false),"secondary")], _dialog_reduced_motion())


func _cancel_return_to_level() -> void:
	if not _gameplay_paused or _return_dialog_motion.closing:
		return
	var token := _run_token
	var on_closed := func():
		if token != _run_token or not _is_level_in_progress():
			return
		_set_return_focus_locked(false)
		_set_gameplay_paused(false)
		_in_game_return_button.visible = true
	_return_dialog_motion.dismiss(on_closed, _dialog_reduced_motion())


func _confirm_return_to_modes() -> void:
	if not _gameplay_paused or _return_dialog_motion.closing:
		return
	var token := _run_token
	var on_closed := func():
		if token == _run_token:
			_show_mode_selection()
	_return_dialog_motion.dismiss(on_closed, _dialog_reduced_motion())


func _is_level_in_progress() -> bool:
	return phase in [Phase.PREPARING, Phase.PACKING, Phase.ENTERING, Phase.PRESENTING, Phase.ANSWERING, Phase.REVEALING]


func _show_mode_selection() -> void:
	_exit_super_mode()
	_gameplay_screen_motion.cancel()
	_menu_screen_motion.cancel()
	_cancel_tutorial()
	_cancel_settings()
	_cancel_dialog_motion()
	_close_reset_confirmation()
	_run_token += 1
	_cancel_gameplay_motion()
	_hint_timer.stop()
	_emit_event("game_ended")
	phase = Phase.IDLE
	_preparation_click_ready = false
	_current_card.mouse_default_cursor_shape = Control.CURSOR_ARROW
	_completion_panel.visible = false
	_completion_backdrop.visible = false
	_in_game_return_button.visible = false
	_return_confirmation_blocker.visible = false
	_return_confirmation_panel.visible = false
	_current_card.visible = false
	_gift_panel.visible = false
	_options_box.visible = false
	_road_panel.visible = false
	_progress_box.visible = false
	_instruction_label.visible = false
	_fast_toggle.visible = false
	if _debug_reset_button != null:
		_debug_reset_button.visible = false
	if _debug_discovery_selector != null:
		_debug_discovery_selector.visible = false
	_feedback_label.text = ""
	_feedback_label.visible = false
	_mode_panel.visible = true
	_update_mode_buttons()


func _start_mode(mode_name: String) -> void:
	_cancel_tutorial()
	if _settings_view.visible: return
	if mode_name == "history" and not _history_unlocked():
		return
	_current_mode = mode_name
	_progress_persistence_enabled = true
	_mode_panel.visible = false
	_instruction_label.visible = false
	_feedback_label.visible = false
	_fast_toggle.visible = true
	if _debug_reset_button != null:
		_debug_reset_button.visible = _debug_ui_enabled()
	if _debug_discovery_selector != null:
		_debug_discovery_selector.visible = _debug_ui_enabled()
	_in_game_return_button.visible = true
	_road_panel.visible = true
	_progress_box.visible = true
	_start_level()


func _update_mode_buttons() -> void:
	var progress := _progress_data()
	_set_history_mode_locked(not bool(progress.advanced_mode_unlocked))


func _set_history_mode_locked(locked: bool) -> void:
	_history_mode_button.disabled = locked
	_history_mode_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if locked else Control.CURSOR_POINTING_HAND
	_history_mode_button.tooltip_text = L.text("尚未解锁" if locked else "历史干扰")
	var illustration := _mode_icons["history"] as TextureRect
	(illustration.material as ShaderMaterial).set_shader_parameter("locked_amount", 1.0 if locked else 0.0)
	var lock_badge := _history_mode_button.find_child("LockBadge", true, false) as TextureRect
	if lock_badge != null:
		lock_badge.visible = locked


func _start_level() -> void:
	if is_instance_valid(_super_result_view): _super_result_view.hide()
	_completion_panel.get_node("CompletionContent").show()
	if _super_mode:
		_race.abandon()
		var store := get_node_or_null("/root/SaveData")
		var identity: Dictionary = store.ensure_race_data() if store != null else {"local_player_id":"guest", "display_id":""}
		_race.prepare(_current_mode,str(identity.local_player_id),str(identity.display_id))
		_race_save_result.clear()
	_menu_screen_motion.cancel()
	if not _super_mode: _gameplay_screen_motion.present()
	else: _gameplay_screen_motion.cancel()
	_cancel_settings()
	_cancel_dialog_motion()
	_run_token += 1
	var token := _run_token
	_cancel_gameplay_motion()
	_hint_timer.stop()
	phase = Phase.PREPARING
	_preparation_click_ready = false
	_judgment_index = 0
	_correct_count = 0
	_judgment_results.clear()
	_newly_collected_this_level.clear()
	_discovery_plan = {} if _super_mode else _plan_discoveries()
	var known_ids := _super_car_pool.duplicate() if _super_mode else _known_car_ids()
	var candidate_ids := known_ids.duplicate()
	for car_id in _discovery_plan.get("car_ids", []):
		if not candidate_ids.has(car_id):
			candidate_ids.append(car_id)
	var forced_positions: Dictionary = _discovery_plan.get("forced_positions", {})
	var sequence_seed := int(_discovery_plan.get("seed", 1)) ^ 0x5EED1234
	if sequence_seed == 0:
		sequence_seed = 1
	if _super_mode:
		sequence_seed = 0 # Random questions on replay; only the vehicle pool is frozen.
	if _current_mode == "history":
		_plan = SequenceGenerator.new().generate_history(candidate_ids, sequence_seed, forced_positions)
	else:
		_plan = SequenceGenerator.new().generate(candidate_ids, known_ids, sequence_seed, forced_positions)
	if _tutorial_active: _plan = _tutorial_practice_plan()
	if _plan.is_empty():
		_feedback_label.text = L.text("关卡准备失败，请重新打开游戏")
		return

	_completion_panel.visible = false
	_completion_backdrop.visible = false
	_return_confirmation_blocker.visible = false
	_return_confirmation_panel.visible = false
	_in_game_return_button.visible = true
	_mode_panel.visible = false
	_road_panel.visible = true
	_progress_box.visible = true
	_feedback_label.text = ""
	_options_box.visible = false
	_gift_panel.visible = true
	_gift_panel.scale = Vector2.ONE
	_gift_label.text = ""
	_update_progress()
	_fast_toggle.disabled = false
	_fast_toggle.visible = not _tutorial_active
	_emit_event("game_started")
	if not _tutorial_active: _emit_event("level_started", [1, int(_plan.seed)])

	if _tutorial_active:
		# A quiet opening establishes the scene before any object asks for a tap.
		_current_card.hide()
		_gift_panel.hide()
		_set_tutorial_step("arriving")
		await _tutorial_wait(0.65, token)
		if not _tutorial_valid(token): return
	_instruction_label.text = Content.text("remember")
	_set_current_car(_plan.preparation_car_id, true)
	if _tutorial_active:
		_current_card_background.hide()
		_current_card_shadow.hide()
	if _super_mode:
		_current_card.show()
		_current_card.position = _car_target_position()
		_current_card.scale = Vector2.ONE
		_current_card.modulate = Color.WHITE
	else:
		await _animate_car_entry(token, -1)
	if token != _run_token:
		return
	if _tutorial_active:
		await _animate_tutorial_card_backing(token)
		if not _tutorial_valid(token): return
		_set_tutorial_step("remember")
	_instruction_label.text = Content.text("tap")
	_preparation_click_ready = true
	_current_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_set_current_card_clickable(true)
	if _tutorial_active:
		_apply_tutorial_chrome()
		_tutorial_view.cue_observe(_current_card, _tutorial_demonstrating)
		if _tutorial_demonstrating:
			await _tutorial_wait(0.65, token)
			if not _tutorial_valid(token): return
			await _tutorial_view.animate_tap(_current_card)
			if not _tutorial_valid(token): return
			_tutorial_model_input = true
			_confirm_preparation()
			_tutorial_model_input = false
	await _await_preparation_confirmation(token)
	if token != _run_token:
		return
	if _tutorial_active:
		await _animate_tutorial_gift_entry(token)
		if not _tutorial_valid(token): return
	if _super_mode:
		_gift_motion.clear_car()
		_gift_motion.set_pose(0.0)
		_current_card.hide()
		await _present_judgment(token)
		return
	await _animate_packing(token, _plan.preparation_car_id, -1)
	if token != _run_token:
		return
	await _wait_for_closed_box(token)
	if token != _run_token:
		return
	await _present_judgment(token)


func _present_judgment(token: int) -> void:
	if token != _run_token:
		return
	_preparation_click_ready = false
	_current_card.mouse_default_cursor_shape = Control.CURSOR_ARROW
	var judgment: Dictionary = _plan.judgments[_judgment_index]
	_instruction_label.text = Content.text("question")
	_feedback_label.text = ""
	_gift_label.text = "?"
	if _tutorial_active:
		await _animate_tutorial_options(token, "choose")
		return
	_set_current_car(judgment.current_car_id)
	if _super_mode:
		_present_super_options(judgment)
		return
	await _animate_options(token, judgment)
	if token != _run_token:
		return


func _motion_audio() -> Node:
	if Engine.is_editor_hint() or get_meta("content_preview", false): return null
	var audio := get_node_or_null("/root/AudioManager")
	return audio if audio != null and audio.has_method("start_vehicle_motion") else null


func _start_road_audio(seconds: float) -> void:
	var audio := _motion_audio()
	if audio != null: audio.start_vehicle_motion(_current_car_id(), seconds)


func _update_road_audio(progress: float) -> void:
	var audio := _motion_audio()
	if audio != null: audio.update_vehicle_motion_progress(clampf(progress, 0.0, 1.0))


func _stop_road_audio() -> void:
	var audio := _motion_audio()
	if audio != null: audio.stop_vehicle_motion()


func _animate_car_entry(token: int, judgment_index: int) -> void:
	phase = Phase.ENTERING if judgment_index >= 0 else Phase.PREPARING
	_current_card.visible = true
	_current_card.position = _car_target_position() + Vector2(560, 0)
	_current_card.modulate = Color.WHITE
	_current_card.scale = Vector2.ONE
	_emit_event("car_entered", [_current_car_id(), judgment_index])
	var tween := _gameplay_tween().set_parallel(true)
	var seconds := _duration_seconds("car_entry")
	_start_road_audio(seconds)
	tween.tween_method(_update_road_audio, 0.0, 1.0, seconds).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(offset: Vector2): _current_card.position = _car_target_position() + offset, Vector2(560, 0), Vector2.ZERO, seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_current_card, "scale", Vector2.ONE, seconds)
	tween.tween_property(_current_card, "modulate", Color.WHITE, seconds * 0.7)
	await _await_tween(tween, "car_entry", token)
	if token == _run_token: _stop_road_audio()


func _animate_packing(token: int, car_id: String, judgment_index: int) -> void:
	_packing_close_played = false
	phase = Phase.PACKING
	_emit_event("packing_started", [car_id, judgment_index])
	var packing_audio := _motion_audio()
	if packing_audio != null: packing_audio.paper_pack_start(_duration_seconds("packing"))
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	_gift_motion.set_car(car_id)
	_gift_motion.set_reveal_layer(false)
	# Convert the actual displayed portrait to the authored box's local space.
	_packing_start = _gift_motion.get_global_transform().affine_inverse() * (_current_art.get_global_transform() * (_current_art.size * 0.5))
	_current_card.visible = false
	_packing_fast = _fast_mode
	var tween := _gameplay_tween()
	tween.tween_method(_pose_packing, 0.0, 1.0, _duration_seconds("packing"))
	await _await_tween(tween, "packing", token)
	if token != _run_token:
		return
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	_current_card.position = _car_target_position()
	_current_card.scale = Vector2.ONE
	_current_card.modulate = Color.WHITE
	_gift_panel.scale = Vector2.ONE
	_gift_label.text = ""
	# Anchor after the complete packing/bounce, matching the approved preview.
	_closed_box_ready_at_ms = _gameplay_elapsed_ms + CLOSED_BOX_HOLD_MS
	_emit_event("packing_completed", [car_id, judgment_index])
	_emit_event("current_car_promoted_to_memory", [car_id, judgment_index])


func _pose_packing(progress: float) -> void:
	# Follow the actual lid pose, including sped-up/paused packing. No timer can
	# fire after cancellation; each real packing owns one contact cue.
	if not _packing_close_played and progress >= (0.95 if _packing_fast else 0.775):
		_packing_close_played = true
		var audio := _motion_audio()
		if audio != null: audio.paper_box_close(_packing_fast)
	# Fast mode keeps its 80 ms contract: one opaque sink and close, no tiny bounces.
	if _packing_fast:
		var travel := clampf(progress / 0.72, 0.0, 1.0)
		_gift_motion.set_pose((1.0 - smoothstep(0.45, 1.0, progress)) * 0.34)
		_gift_motion.pose_car(_packing_start.lerp(Vector2(193,263), travel), lerpf(1.0, 0.68, travel), 0.0)
		_gift_motion.car_art.visible = progress < 0.72
		return
	var seconds := progress * 0.8
	var anticipation := smoothstep(0.0, 0.10, seconds)
	var travel := pow(clampf((seconds - 0.10) / 0.40, 0.0, 1.0), 1.24)
	var center := (_packing_start + Vector2(-9,14) * anticipation).lerp(Vector2(193,263), travel)
	center += Vector2(-76, -174) * sin(travel * PI)
	var angle := 0.035 * anticipation * (1.0 - travel) - 0.17 * sin(travel * PI)
	_gift_motion.pose_car(center, lerpf(1.0, 0.68, travel), angle)
	_gift_motion.car_art.visible = seconds < 0.50
	var lift := ease(clampf(seconds / 0.15, 0.0, 1.0), 0.35)
	var close := pow(clampf((seconds - 0.50) / 0.12, 0.0, 1.0), 2.4)
	var impact_time := maxf(0.0, seconds - 0.50)
	var impact := 22.0 * exp(-impact_time * 14.0) * sin(impact_time * 36.0)
	var tilt := 0.04 * exp(-impact_time * 14.0) * sin(impact_time * 34.0)
	_gift_motion.set_pose(lift * (1.0 - close), impact, tilt)


func _animate_options(token: int, judgment: Dictionary) -> void:
	# The memory stimulus and the complete choice set start on the same frame.
	# Observation at level start still uses its separate, user-confirmed entry.
	phase = Phase.PRESENTING
	_current_card.visible = true
	_current_card.position = _car_target_position() + Vector2(100, 0)
	_current_card.modulate = Color(1, 1, 1, 0)
	_current_card.scale = Vector2.ONE
	_emit_event("car_entered", [_current_car_id(), _judgment_index])
	_options_box.visible = true
	_layout_options(judgment.option_ids.size())
	for option_index in range(judgment.option_ids.size()):
		var button := _option_buttons[option_index]
		var car_id: String = judgment.option_ids[option_index]
		_set_option_content(option_index, car_id)
		button.set_meta("car_id", car_id)
		button.disabled = true
		button.scale = Vector2(0.25, 0.25)
		button.modulate = Color(1, 1, 1, 0)
		_apply_option_style(button, car_id, "normal")
	var tween := _gameplay_tween().set_parallel(true)
	var seconds := _duration_seconds("joint_entry")
	_start_road_audio(seconds)
	tween.tween_method(_update_road_audio, 0.0, 1.0, seconds).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(offset: Vector2): _current_card.position = _car_target_position() + offset, Vector2(100, 0), Vector2.ZERO, seconds).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_current_card, "modulate", Color.WHITE, seconds * 0.65)
	for button in _option_buttons:
		if not button.visible:
			continue
		tween.tween_property(button, "scale", Vector2.ONE, seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "modulate", Color.WHITE, seconds * 0.65)
	_emit_event("options_presented", [judgment.option_ids, judgment.correct_index, _judgment_index])
	phase = Phase.ANSWERING
	if _tutorial_active: _set_tutorial_step("choose")
	_answer_ready_at_ms = int(_gameplay_elapsed_ms) + int(INPUT_GUARD_SECONDS * 1000.0)
	_hinted = false
	if not _tutorial_active: _hint_timer.start()
	for button in _option_buttons:
		if button.visible:
			button.disabled = _tutorial_active and _tutorial_demonstrating
	await _await_tween(tween, "joint_entry", token)
	if token == _run_token: _stop_road_audio()
	if _tutorial_active and _tutorial_valid(token) and phase == Phase.ANSWERING:
		_current_art.set_presentation_alpha(1.0)
		_tutorial_view.cue_choices(_gift_panel, _tutorial_visible_options())
		if _tutorial_demonstrating: await _tutorial_model_choice(token)


func _layout_options(option_count: int) -> void:
	_cancel_tutorial_feedback()
	var positions: Array[Vector2] = []
	var option_size := Vector2(300, 300)
	if option_count == 2:
		_options_box.position = _content_position(OPTIONS_POSITION)
		positions = [Vector2.ZERO, Vector2(566, 0)]
		option_size = Vector2(407, 381)
		_feedback_base_y = 1550.0
	elif option_count == 3:
		_options_box.position = _content_position(Vector2(36, 925))
		positions = [Vector2(0, 0), Vector2(0, 330), Vector2(708, 165)]
		_feedback_base_y = 1550.0
	else:
		_options_box.position = _content_position(Vector2(36, 925))
		positions = [Vector2(0, 0), Vector2(708, 0), Vector2(0, 330), Vector2(708, 330)]
		_feedback_base_y = 1550.0
	_feedback_label.size.y = 72.0
	_feedback_label.position = _content_position(Vector2(80, _feedback_base_y))
	for option_index in range(_option_buttons.size()):
		var button := _option_buttons[option_index]
		button.visible = option_index < option_count
		button.disabled = true
		if button.visible:
			button.position = positions[option_index]
			button.size = option_size
			button.pivot_offset = button.size / 2.0


func _on_option_pressed(option_index: int) -> void:
	if _tutorial_active and (_tutorial_replaying or (_tutorial_demonstrating and not _tutorial_model_input)): return
	if phase != Phase.ANSWERING or _gameplay_paused:
		return
	if _gameplay_elapsed_ms < _answer_ready_at_ms:
		return
	if _tutorial_active:
		_settle_tutorial_choice_entry()
		_tutorial_committed_scale = _option_buttons[option_index].scale.x
	phase = Phase.REVEALING
	_hint_timer.stop()
	for index in range(_option_buttons.size()):
		_reset_option_press(index)
		var button := _option_buttons[index]
		button.disabled = true
	_resolve_answer(option_index, _run_token)


func _on_option_button_down(option_index: int) -> void:
	if _tutorial_active and (_tutorial_replaying or _tutorial_demonstrating): return
	if phase != Phase.ANSWERING or _gameplay_paused:
		return
	_animate_option_press(option_index, true)


func _on_option_button_up(option_index: int) -> void:
	# Disabled/repeated release events must not overwrite settled reveal emphasis.
	if phase != Phase.ANSWERING: return
	_animate_option_press(option_index, false)


func _animate_option_press(option_index: int, pressed: bool) -> void:
	if option_index < 0 or option_index >= _option_buttons.size():
		return
	var previous_tween = _option_press_tweens.get(option_index)
	if previous_tween is Tween and previous_tween.is_valid():
		previous_tween.kill()
	var tween := _gameplay_tween().set_parallel(true)
	_option_press_tweens[option_index] = tween
	var duration := 0.07 if pressed else 0.12
	var target_scale := Vector2.ONE * (0.965 if _tutorial_active else 0.94) if pressed else Vector2.ONE
	tween.tween_property(_option_buttons[option_index], "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var shadow_color := Color(0.16, 0.25, 0.34, 0.08) if pressed else Color(0.16, 0.25, 0.34, 0.22)
	tween.tween_property(_option_shadows[option_index], "self_modulate", shadow_color, duration)


func _reset_option_press(option_index: int) -> void:
	if option_index < 0 or option_index >= _option_buttons.size():
		return
	var previous_tween = _option_press_tweens.get(option_index)
	if previous_tween is Tween and previous_tween.is_valid():
		previous_tween.kill()
	_option_buttons[option_index].scale = Vector2.ONE
	_option_shadows[option_index].self_modulate = Color(0.16, 0.25, 0.34, 0.22)


func _resolve_answer(option_index: int, token: int) -> void:
	if _super_mode:
		await _resolve_super_answer(option_index, token)
		return
	if _tutorial_active:
		await _resolve_tutorial_answer(option_index, token)
		return
	var judgment: Dictionary = _plan.judgments[_judgment_index]
	var is_correct := option_index == int(judgment.correct_index)
	if not _tutorial_active:
		if is_correct: _correct_count += 1
		_judgment_results.append(is_correct)
	else:
		_set_tutorial_step("found" if is_correct else "retry")
	_apply_option_style(_option_buttons[option_index], judgment.option_ids[option_index], "correct" if is_correct else "incorrect")
	_update_progress()
	var response_time := maxi(0, int(_gameplay_elapsed_ms) - (_answer_ready_at_ms - int(INPUT_GUARD_SECONDS * 1000.0)))
	_emit_event("answer_committed", [judgment.option_ids[option_index], is_correct, response_time, _judgment_index])
	_collect_discovery(judgment.remembered_car_id)

	_emit_event("reveal_started", [judgment.remembered_car_id, _judgment_index])
	_gift_label.text = ""
	_feedback_label.visible = true
	_feedback_label.modulate = Color.WHITE
	_feedback_label.size = Vector2(440,64)
	var chosen_center: float = _options_box.position.x + _option_buttons[option_index].position.x + _option_buttons[option_index].size.x * 0.5
	_feedback_label.position = _content_position(Vector2(clampf(chosen_center - 220.0, 40.0, 600.0), _feedback_base_y + 20.0))
	_feedback_label.add_theme_font_size_override("font_size",30)
	_feedback_label.add_theme_stylebox_override("normal", PaperUI.feedback_sticker())
	_feedback_label.text = Content.text("correct") if is_correct else Content.text("incorrect")
	_feedback_label.add_theme_color_override("font_color", Color("648661") if is_correct else Color("9c8056"))
	if _fast_mode:
		await _resolve_fast_transition(option_index, judgment, token)
		return
	_gift_motion.clear_car()
	var reveal_tween := _gameplay_tween()
	var reveal_seconds := _duration_seconds("reveal")
	# Keep the existing reveal/feedback exposure windows. Wrong answers get a
	# short gentle beat within the reveal window before the correct car appears.
	reveal_tween.tween_method(func(progress: float):
		var delay := 0.12 if is_correct else 0.30
		var amount: float = _gift_motion.pose_reveal(progress,delay)
		if progress >= delay:
			if _gift_motion.car_id.is_empty():
				_gift_motion.set_car(judgment.remembered_car_id)
				_gift_motion.set_reveal_layer(true)
				if not is_correct:
					_apply_option_style(_option_buttons[judgment.correct_index], judgment.remembered_car_id, "correct")
				_set_reveal_emphasis(int(judgment.correct_index))
			_gift_motion.pose_car(Vector2(191, lerpf(250.0, -38.0, amount)), 0.80)
		, 0.0, 1.0, reveal_seconds)
	await _await_tween(reveal_tween, "reveal", token)
	if token != _run_token:
		return
	_emit_event("reveal_completed", [judgment.remembered_car_id, _judgment_index])

	var feedback_kind := "correct_feedback" if is_correct else "incorrect_feedback"
	await _wait_animation_segment(feedback_kind, token)
	if token != _run_token:
		return
	if _tutorial_active:
		await _finish_tutorial_answer(is_correct, token)
		return
	_options_box.visible = false
	_feedback_label.visible = false
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)

	if _judgment_index == JUDGMENT_COUNT - 1:
		_complete_level()
		return

	_instruction_label.text = Content.text("remember")
	_feedback_label.text = ""
	await _animate_packing(token, judgment.current_car_id, _judgment_index)
	if token != _run_token:
		return
	# A quiet closed-box beat separates putting this car away from new content.
	await _wait_for_closed_box(token)
	if token != _run_token:
		return
	_judgment_index += 1
	await _present_judgment(token)


func _resolve_fast_transition(option_index: int, judgment: Dictionary, token: int) -> void:
	# Keep the committed choice and (for an error) the correct choice readable.
	# The box is now packing the CURRENT memory stimulus, never the old answer.
	# A single tracked tween owns overlap, pause, acceleration and cancellation.
	var final_judgment := _judgment_index == JUDGMENT_COUNT - 1
	var index := _judgment_index
	var correct_index: int = judgment.correct_index
	_apply_option_style(_option_buttons[correct_index], judgment.remembered_car_id, "correct")
	_set_reveal_emphasis(correct_index)
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	if not final_judgment:
		_packing_close_played = false
		_emit_event("packing_started", [judgment.current_car_id, index])
		var packing_audio := _motion_audio()
		if packing_audio != null: packing_audio.paper_pack_start(minf(Content.setting("fast_overlap_packing") / 1000.0, _duration_seconds("overlap_feedback")))
		_gift_motion.set_car(judgment.current_car_id)
		_packing_start = _gift_motion.get_global_transform().affine_inverse() * (_current_art.get_global_transform() * (_current_art.size * 0.5))
		_packing_fast = true
	_current_card.visible = false
	var packed := [final_judgment]
	var seconds := _duration_seconds("overlap_feedback")
	var pack_seconds := minf(Content.setting("fast_overlap_packing") / 1000.0, seconds)
	var tween := _gameplay_tween()
	tween.tween_method(func(elapsed: float):
		if token != _run_token or not is_inside_tree():
			return
		if not packed[0]:
			_pose_packing(clampf(elapsed / pack_seconds, 0.0, 1.0))
			if elapsed >= pack_seconds:
				packed[0] = true
				_gift_motion.clear_car()
				_gift_motion.set_pose(0.0)
				# Remaining overlap feedback is part of the same 500 ms gap.
				_closed_box_ready_at_ms = _gameplay_elapsed_ms + CLOSED_BOX_HOLD_MS
				_emit_event("packing_completed", [judgment.current_car_id, index])
				_emit_event("current_car_promoted_to_memory", [judgment.current_car_id, index])
		# Keep both marks legible and retain the exact last~50ms exit window.
		var alpha := 1.0 - smoothstep(maxf(0.0, seconds - 0.05), seconds, elapsed)
		for i in range(judgment.option_ids.size()):
			_option_buttons[i].modulate.a = alpha
			# The vehicle shader owns its opacity independently of parent modulate.
			_option_art[i].set_presentation_alpha(alpha * (1.0 if i == correct_index else 0.28))
		_feedback_label.modulate.a = alpha
		, 0.0, seconds, seconds)
	await _await_tween(tween, "overlap_feedback", token)
	if token != _run_token:
		return
	_emit_event("reveal_completed", [judgment.remembered_car_id, index])
	_options_box.visible = false
	_feedback_label.visible = false
	_feedback_label.modulate = Color.WHITE
	_feedback_label.text = ""
	if final_judgment:
		_complete_level()
		return
	phase = Phase.PACKING
	await _wait_for_closed_box(token)
	if token != _run_token:
		return
	_judgment_index += 1
	await _present_judgment(token)


func _complete_level() -> void:
	if phase == Phase.COMPLETE:
		return
	_cancel_dialog_motion()
	phase = Phase.COMPLETE
	_set_return_focus_locked(true)
	_fast_toggle.disabled = true
	_fast_toggle.hide()
	_hint_timer.stop()
	_in_game_return_button.visible = false
	_return_confirmation_blocker.visible = false
	_return_confirmation_panel.visible = false
	_current_card.visible = false
	_options_box.visible = false
	_gift_panel.visible = false
	_instruction_label.text = Content.text("complete")
	_feedback_label.text = ""
	var newly_unlocked := _record_level_progress()
	if _super_mode:
		_show_super_results(newly_unlocked)
		_emit_event("level_completed", [_correct_count, JUDGMENT_COUNT, _newly_collected_this_level])
		return
	var has_new_cars := not _newly_collected_this_level.is_empty()
	if has_new_cars:
		_completion_title_label.text = Content.text("new_friend")
		_completion_names_label.text = L.text("已加入车库")
		_set_completion_car_showcase(_newly_collected_this_level)
	elif newly_unlocked:
		_completion_title_label.text = Content.text("unlocked")
		_set_completion_car_showcase([])
		_completion_names_label.text = L.text("新模式可玩啦！")
		_completion_names_label.show()
		_completion_decoration.hide()
	else:
		_completion_title_label.text = Content.text("complete")
		_completion_names_label.text = ""
		_set_completion_car_showcase([])
	_layout_completion(has_new_cars)
	_completion_panel.add_theme_stylebox_override("panel", _paper_style(Color("fff8e7"), Color("ff9b77") if has_new_cars else Color("ffad86"), 8, 48))
	PaperUI.install_panel(_completion_panel)
	_completion_backdrop.visible = true
	_completion_panel.visible = true
	var beats: Array = [DialogMotion.beat(_completion_title_label,"title"),
		DialogMotion.beat(_completion_decoration,"accent"),DialogMotion.beat(_replay_button,"action"),
		DialogMotion.beat(_garage_button,"secondary"),DialogMotion.beat(_mode_select_button,"utility")]
	if has_new_cars:
		beats = [DialogMotion.beat(_completion_title_label,"title"),DialogMotion.beat(_completion_car_showcase,"reward"),
			DialogMotion.beat(_completion_names_label,"detail"),DialogMotion.beat(_replay_button,"action"),
			DialogMotion.beat(_garage_button,"secondary"),DialogMotion.beat(_mode_select_button,"utility")]
	_completion_dialog_motion.present("new_car" if has_new_cars else "result", beats, _dialog_reduced_motion())
	if has_new_cars:
		for index in range(_completion_car_cards.size()):
			_completion_dialog_motion.emphasize(_completion_car_cards[index], 0.35+index*0.065, _dialog_reduced_motion(),1.07 if _newly_collected_this_level.size()>1 else 1.18)

	_emit_event("level_completed", [_correct_count, JUDGMENT_COUNT, _newly_collected_this_level])


func _record_level_progress() -> bool:
	if not _progress_persistence_enabled:
		return false
	var save_data := get_node_or_null("/root/SaveData")
	if save_data == null:
		return false
	var before_unlocked := bool(save_data.data.get("advanced_mode_unlocked", false))
	var progress := _progress_data()
	if _current_mode == "history":
		progress = ModeProgressionScript.apply_history_result(progress, _correct_count, JUDGMENT_COUNT)
	else:
		progress = ModeProgressionScript.apply_starter_result(progress, _correct_count)
	for key in ["advanced_mode_unlocked", "starter_unlock_streak", "recent_history_results"]:
		save_data.data[key] = progress[key]
	if _super_mode:
		# Races keep mode progression, but cannot alter ordinary discovery odds/pity.
		save_data.save()
		return not before_unlocked and bool(progress.advanced_mode_unlocked)
	var collected_discoverable := 0
	for car_id in save_data.data.get("collected_cars", []):
		if CarData.discoverable_ids().has(car_id):
			collected_discoverable += 1
	var remaining_count := CarData.discoverable_ids().size() - collected_discoverable
	save_data.record_completed_level(_correct_count, _newly_collected_this_level.size(), remaining_count)
	return not before_unlocked and bool(progress.advanced_mode_unlocked)


func _plan_discoveries() -> Dictionary:
	if not _discovery_override.is_empty():
		var override := _discovery_override.duplicate(true)
		_discovery_override.clear()
		return override
	if _debug_next_discovery_count >= 0:
		var requested_count := _debug_next_discovery_count
		_debug_next_discovery_count = -1
		if _debug_discovery_selector != null:
			_debug_discovery_selector.select(0)
		return _make_debug_discovery_plan(requested_count)
	var save_data := get_node_or_null("/root/SaveData")
	var collected := CarData.starter_ids()
	var recent: Array[int] = []
	var pity := 0
	if save_data != null:
		collected = _string_array(save_data.data.get("collected_cars", CarData.starter_ids()))
		for value in save_data.data.get("recent_level_results", []):
			recent.append(int(value))
		pity = int(save_data.data.get("zero_discovery_streak", 0))
	return DiscoveryPlannerScript.new().plan(collected, recent, pity, 0)


func _make_debug_discovery_plan(requested_count: int) -> Dictionary:
	var save_data := get_node_or_null("/root/SaveData")
	var collected := CarData.starter_ids()
	if save_data != null:
		collected = _string_array(save_data.data.get("collected_cars", CarData.starter_ids()))
	var remaining: Array[String] = []
	for car_id in CarData.discoverable_ids():
		if not collected.has(car_id):
			remaining.append(car_id)
	var count := mini(clampi(requested_count, 0, 2), remaining.size())
	var car_ids: Array[String] = []
	for index in range(count):
		car_ids.append(remaining[index])
	var positions: Array[int] = []
	if count == 1:
		positions = [0]
	elif count == 2:
		positions = [0, 3]
	var forced_positions := {}
	for index in range(count):
		forced_positions[positions[index]] = car_ids[index]
	return {
		"seed": 9000 + count,
		"count": count,
		"car_ids": car_ids,
		"positions": positions,
		"forced_positions": forced_positions,
		"probabilities": {"0": 1.0 if count == 0 else 0.0, "1": 1.0 if count == 1 else 0.0, "2": 1.0 if count == 2 else 0.0},
	}


func _known_car_ids() -> Array[String]:
	var save_data := get_node_or_null("/root/SaveData")
	if save_data == null:
		return CarData.starter_ids()
	var known := _string_array(save_data.data.get("known_cars", save_data.data.get("collected_cars", CarData.starter_ids())))
	return known if known.size() >= 4 else CarData.starter_ids()


func _collect_discovery(car_id: String) -> void:
	if _super_mode or not _progress_persistence_enabled or not _plan.get("discovery_car_ids", []).has(car_id):
		return
	var save_data := get_node_or_null("/root/SaveData")
	if save_data != null and save_data.add_car(car_id):
		_newly_collected_this_level.append(car_id)


func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			result.append(str(value))
	return result


func _progress_data() -> Dictionary:
	var save_data := get_node_or_null("/root/SaveData")
	if save_data == null:
		return {"advanced_mode_unlocked": false, "starter_unlock_streak": 0, "recent_history_results": []}
	return {
		"advanced_mode_unlocked": bool(save_data.data.get("advanced_mode_unlocked", false)),
		"starter_unlock_streak": int(save_data.data.get("starter_unlock_streak", 0)),
		"recent_history_results": save_data.data.get("recent_history_results", []).duplicate(),
	}


func _history_unlocked() -> bool:
	return bool(_progress_data().advanced_mode_unlocked)


func _open_garage(source_screen: String) -> void:
	if _settings_view.visible: return
	if source_screen == "completion" and phase != Phase.COMPLETE:
		return
	if source_screen == "mode" and phase != Phase.IDLE:
		return
	_garage_return_screen = source_screen
	var save_data := get_node_or_null("/root/SaveData")
	var collected := CarData.starter_ids()
	var unviewed: Array[String] = []
	if save_data != null:
		collected = _string_array(save_data.data.get("collected_cars", CarData.starter_ids()))
		unviewed = _string_array(save_data.data.get("unviewed_car_ids", []))
	_garage_view.show_collection(collected, unviewed)
	if source_screen == "mode":
		_mode_panel.hide()


func _make_title_image() -> TextureRect:
	var title := TextureRect.new()
	title.texture = Content.asset(GAME_TITLE_TEXTURE)
	title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return title


func _on_garage_car_viewed(car_id: String) -> void:
	if get_meta("content_preview", false):
		return
	var save_data := get_node_or_null("/root/SaveData")
	if save_data != null:
		save_data.mark_car_viewed(car_id)


func _on_garage_close_requested() -> void:
	_garage_view.visible = false
	if _garage_return_screen == "completion" and phase == Phase.COMPLETE:
		_completion_dialog_motion.cancel()
		_completion_backdrop.visible = true
		_completion_panel.visible = true
		_gameplay_screen_motion.present()
	else:
		_mode_panel.visible = true


func _on_hint_timeout() -> void:
	if _super_mode: return
	if phase != Phase.ANSWERING or _hinted or _gameplay_paused:
		return
	_hinted = true
	_feedback_label.text = Content.text("hint")
	_feedback_label.add_theme_color_override("font_color", Color("456279"))
	var original_position := _gift_panel.position
	_hint_rest_position = original_position
	_hint_motion_active = true
	var tween := _gameplay_tween()
	tween.tween_property(_gift_panel, "position:x", original_position.x - 18, 0.08)
	tween.tween_property(_gift_panel, "position:x", original_position.x + 18, 0.12)
	tween.tween_property(_gift_panel, "position:x", original_position.x, 0.08)
	tween.tween_callback(func(): _hint_motion_active = false)


func _on_fast_mode_toggled(enabled: bool) -> void:
	if _super_mode or _tutorial_active or _gameplay_paused:
		_fast_toggle.set_pressed_no_signal(_fast_mode)
		return
	var was_fast := _fast_mode
	_fast_mode = enabled
	var save_data := get_node_or_null("/root/SaveData")
	if save_data != null and not save_data.data.is_empty():
		var settings: Dictionary = save_data.data.get("settings", {})
		settings["fast_mode"] = enabled
		save_data.data["settings"] = settings
		save_data.save()
	if enabled and not was_fast:
		_sync_active_speed()
	_refresh_fast_toggle_art(true)


func _on_debug_discovery_selected(item_index: int) -> void:
	_debug_next_discovery_count = item_index - 1


func _on_debug_reset_progress() -> void:
	if not OS.is_debug_build():
		return
	_reset_saved_progress()


func _reset_saved_progress(keep_settings_open: bool = false) -> void:
	var save_data := get_node_or_null("/root/SaveData")
	if save_data != null:
		save_data.reset_progress()
	_debug_next_discovery_count = -1
	_discovery_override.clear()
	if _debug_discovery_selector != null:
		_debug_discovery_selector.select(0)
	if _garage_view != null:
		_garage_view.visible = false
	_load_fast_mode()
	if keep_settings_open:
		_update_mode_buttons()
		_settings_view.refresh()
	else:
		_show_mode_selection()


func _load_fast_mode() -> void:
	var save_data := get_node_or_null("/root/SaveData")
	if save_data != null:
		_fast_mode = bool(save_data.data.get("settings", {}).get("fast_mode", false))
	_fast_toggle.set_pressed_no_signal(_fast_mode)
	_refresh_fast_toggle_art(false)


func _duration_seconds(kind: String) -> float:
	return Content.setting(("fast_" if _fast_mode else "normal_") + kind) / 1000.0


func _await_tween(tween: Tween, kind: String, token: int) -> void:
	_active_tween = tween
	_active_kind = kind
	_active_base_seconds = _duration_seconds(kind)
	_active_fast_multiplier = _active_base_seconds / (Content.setting("fast_" + kind) / 1000.0)
	# A killed Tween never emits finished. Polling the run token also releases
	# canceled coroutines on home/restart instead of leaving stale continuations.
	# Keep the boundary itself paused too: a tween may have finished this frame
	# before Home is handled, but its next phase must wait for Continue.
	while token == _run_token and is_inside_tree() and (tween.is_valid() or _gameplay_paused):
		await get_tree().process_frame
	if token == _run_token and _active_tween == tween:
		_active_tween = null
		_active_kind = ""
		_active_fast_multiplier = 1.0


func _gameplay_tween() -> Tween:
	var tween := create_tween()
	_gameplay_tweens.append(tween)
	if _gameplay_paused:
		tween.pause()
	return tween


func _set_gameplay_paused(paused: bool) -> void:
	if paused and is_instance_valid(_super_hold): _super_hold.cancel()
	_gameplay_paused = paused
	if is_instance_valid(_tutorial_view): _tutorial_view.set_hint_paused(paused)
	var audio := _motion_audio()
	if audio != null: audio.set_gameplay_paused(paused)
	if is_instance_valid(_hint_timer):
		_hint_timer.paused = paused
	for tween in _gameplay_tweens:
		if tween.is_valid():
			if paused:
				tween.pause()
			else:
				tween.play()


func _sync_active_speed() -> void:
	if _active_tween != null and _active_tween.is_valid() and not _active_kind.is_empty():
		_active_tween.set_speed_scale(_active_base_seconds / _duration_seconds(_active_kind))


func _cancel_gameplay_motion() -> void:
	_closed_box_ready_at_ms = 0.0
	_packing_close_played = true
	var audio := _motion_audio()
	if audio != null: audio.stop_gameplay_sfx()
	_cancel_tutorial_feedback()
	for tween in _gameplay_tweens:
		if tween.is_valid():
			tween.kill()
	_gameplay_tweens.clear()
	if _hint_motion_active and is_instance_valid(_gift_panel):
		_gift_panel.position = _hint_rest_position
	_hint_motion_active = false
	_refresh_fast_toggle_art(false)
	_kill_active_tween()
	_set_gameplay_paused(false)
	if _gift_motion != null:
		_gift_motion.clear_car()
		_gift_motion.set_pose(0.0)
	for index in range(_option_buttons.size()):
		_reset_option_press(index)
		_set_option_visual_alpha(index, 1.0)
		_option_buttons[index].modulate = Color.WHITE
		_option_feedback_badges[index].hide()


func _exit_tree() -> void:
	_exit_super_mode()
	_cancel_tutorial()
	_cancel_settings()
	_cancel_dialog_motion()
	_run_token += 1
	_cancel_gameplay_motion()


func _wait_for_closed_box(token: int) -> void:
	# Use unpaused gameplay time, not a speed-scaled Tween or wall-clock timer.
	# Keep the phase boundary paused even if the deadline already elapsed.
	while token == _run_token and is_inside_tree() and (_gameplay_paused or _gameplay_elapsed_ms < _closed_box_ready_at_ms):
		await get_tree().process_frame


func _wait_animation_segment(kind: String, token: int) -> void:
	var tween := _gameplay_tween()
	tween.tween_interval(_duration_seconds(kind))
	await _await_tween(tween, kind, token)


func _await_preparation_confirmation(token: int) -> void:
	while token == _run_token and is_inside_tree() and (_preparation_click_ready or _gameplay_paused):
		await get_tree().process_frame


func _on_current_card_gui_input(event: InputEvent) -> void:
	if _super_release_blocked or not _preparation_click_ready or phase != Phase.PREPARING or _gameplay_paused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_confirm_preparation()
	elif event is InputEventScreenTouch and event.pressed:
		_confirm_preparation()
	elif event is InputEventKey and not event.echo and event.is_action_pressed("ui_accept"):
		_confirm_preparation()
		accept_event()


func _confirm_preparation() -> void:
	if _tutorial_active and (_tutorial_replaying or (_tutorial_demonstrating and not _tutorial_model_input)): return
	if _super_release_blocked or not _preparation_click_ready or phase != Phase.PREPARING or _gameplay_paused:
		return
	if _super_mode and not _race.start(): return
	_preparation_click_ready = false
	_current_card.mouse_default_cursor_shape = Control.CURSOR_ARROW
	_set_current_card_clickable(false)
	_instruction_label.text = Content.text("packing")
	if _tutorial_active:
		_set_tutorial_step("packing")
		_tutorial_view.clear_cue()


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	_active_fast_multiplier = 1.0


func _set_current_car(car_id: String, is_preparation: bool = false) -> void:
	_current_art.set_presentation_alpha(1.0)
	_current_card.set_meta("car_id", car_id)
	_current_art.call("set_car_id", car_id)
	_configure_current_car_presentation(car_id)
	_current_label.text = _car_name(car_id)
	# Keep the observation card through its packing animation; the next car resets this.
	_current_card_shadow.set_meta("preparation_backplate", is_preparation)
	_current_card_background.set_meta("preparation_backplate", is_preparation)
	var bubble_texture := Content.backplate_texture(car_id, null, {}, is_preparation)
	_current_card_shadow.texture = bubble_texture
	_current_card_background.texture = bubble_texture
	_current_card_background.self_modulate = Color.WHITE
	_current_label.add_theme_color_override("font_color", Color("17324d"))
	_sync_current_ground_shadow()


func _set_current_card_clickable(clickable: bool) -> void:
	if _super_mode:
		_current_card.focus_mode = Control.FOCUS_ALL if clickable else Control.FOCUS_NONE
		if clickable and not _super_release_blocked: _current_card.grab_focus()
	_current_card_background.self_modulate = Color.WHITE
	_current_card_shadow.self_modulate = Color(0.12, 0.23, 0.34, 0.28) if clickable else Color(0.16, 0.25, 0.34, 0.20)


func _current_car_id() -> String:
	return str(_current_card.get_meta("car_id", ""))


func _set_option_visual_alpha(option_index: int, alpha: float) -> void:
	if option_index < 0 or option_index >= _option_art.size(): return
	alpha = clampf(alpha, 0.0, 1.0)
	_option_backgrounds[option_index].self_modulate = Color(1, 1, 1, alpha)
	_option_art[option_index].set_presentation_alpha(alpha)
	_option_labels[option_index].modulate = Color(1, 1, 1, alpha)
	_option_shadows[option_index].self_modulate = Color(0.16, 0.25, 0.34, 0.22 * alpha)
	_option_feedback_badges[option_index].modulate = Color.WHITE


func _set_reveal_emphasis(correct_index: int) -> void:
	for index in range(_option_buttons.size()):
		_set_option_visual_alpha(index, 1.0 if index == correct_index else 0.28)


func _set_option_content(option_index: int, car_id: String) -> void:
	if option_index < 0 or option_index >= _option_art.size() or option_index >= _option_labels.size():
		return
	_set_option_visual_alpha(option_index, 1.0)
	_option_art[option_index].call("set_car_id", car_id)
	_configure_option_presentation(option_index, car_id)
	_option_labels[option_index].text = _car_name(car_id)


func _configure_current_car_presentation(car_id: String) -> void:
	var has_final_art := VehicleAssetsScript.texture_for(car_id) != null
	_current_art.visible = has_final_art
	if has_final_art:
		_current_art.position = Vector2(28, 62)
		_current_art.size = Vector2(368, 244)
		_current_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		_current_label.position = Vector2(28, 320)
		_current_label.size = Vector2(368, 1)
		_current_label.visible = false
	else:
		_current_label.visible = true
		_current_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_current_label.add_theme_font_size_override("font_size", 44)


func _configure_option_presentation(option_index: int, car_id: String) -> void:
	var has_final_art := VehicleAssetsScript.texture_for(car_id) != null
	var art := _option_art[option_index]
	var label := _option_labels[option_index]
	art.visible = has_final_art
	if has_final_art:
		var card_size := _option_buttons[option_index].size
		art.position = card_size * Vector2(0.08, 0.15)
		art.size = card_size * Vector2(0.84, 0.66)
		label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		label.position = Vector2(20, 202)
		label.size = Vector2(350, 16)
		label.visible = false
	else:
		label.visible = true
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 34)


func _layout_option_feedback_badge(button: Button, badge: Panel) -> void:
	var frame := FeedbackSymbolScript.Cue.answer_badge_frame(button)
	badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	badge.position = frame.position
	badge.size = frame.size
	badge.pivot_offset = frame.size * 0.5


func _apply_option_style(button: Button, car_id: String, state: String) -> void:
	var option_index := _option_buttons.find(button)
	if option_index >= 0:
		var bubble_texture := Content.backplate_texture(car_id, null, {}, true)
		var shadow := _option_shadows[option_index]
		var background := _option_backgrounds[option_index]
		var feedback_frame := _option_feedback_frames[option_index]
		var feedback_badge := _option_feedback_badges[option_index]
		var feedback_label := _option_feedback_labels[option_index]
		shadow.texture = bubble_texture
		background.texture = bubble_texture
		if state == "normal": _set_option_visual_alpha(option_index, 1.0)
		# A local paper sticker carries the result; never draw a second hard frame.
		feedback_frame.visible = false
		feedback_badge.visible = state in ["correct", "incorrect"]
		_layout_option_feedback_badge(button, feedback_badge)
		feedback_badge.pivot_offset = feedback_badge.size * 0.5
		feedback_badge.rotation = FeedbackSymbolScript.Cue.BADGE_ROTATION
		feedback_badge.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		feedback_label.is_correct = state == "correct"
		if feedback_badge.visible:
			feedback_badge.scale = Vector2.ONE * 0.82
			var sticker_tween := _gameplay_tween()
			sticker_tween.tween_property(feedback_badge, "scale", Vector2.ONE, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_apply_invisible_button_style(button)
	var text_color := Color("17324d")
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		button.add_theme_color_override(color_name, text_color)
	var label := button.get_node_or_null("CarName") as Label
	if label != null:
		label.add_theme_color_override("font_color", text_color)


func _update_progress() -> void:
	for index in range(_progress_labels.size()):
		var marker := _progress_labels[index]
		var marker_material := _progress_materials[index]
		var badge := _progress_badges[index]
		var badge_label := _progress_badge_labels[index]
		if index >= _judgment_results.size():
			marker.self_modulate = Color(0.96, 0.96, 0.96, 1.0)
			marker_material.set_shader_parameter("saturation", 0.35)
			marker_material.set_shader_parameter("paper_wash", 0.58)
			marker.scale = Vector2.ONE
			badge.visible = false
			badge_label.text = ""
			continue
		marker.scale = Vector2.ONE
		badge.visible = true
		if _judgment_results[index]:
			marker.self_modulate = Color.WHITE
			marker_material.set_shader_parameter("saturation", 1.0)
			marker_material.set_shader_parameter("paper_wash", 0.0)
			badge.add_theme_stylebox_override("panel", _round_badge_style(Color("27a96b"), 14))
			badge_label.text = "✓"
		else:
			marker.self_modulate = Color(0.82, 0.84, 0.88, 1.0)
			marker_material.set_shader_parameter("saturation", 0.0)
			marker_material.set_shader_parameter("paper_wash", 0.18)
			badge.add_theme_stylebox_override("panel", _round_badge_style(Color("e4525d"), 14))
			badge_label.text = "×"


func _emit_event(signal_name: String, arguments: Array = []) -> void:
	if get_meta("content_preview", false):
		return
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal(signal_name):
		bus.emit_signal.callv([signal_name] + arguments)


func _car_name(car_id: String) -> String:
	var data := CarData.find(car_id)
	return L.car_name(car_id, data)


func _car_color(car_id: String) -> Color:
	return CAR_COLORS.get(car_id, Color("8aa6bf"))


func _text_color_for(color: Color) -> Color:
	return Color("17324d") if color.get_luminance() > 0.68 else Color("ffffff")


func _bubble_texture_for_car(car_id: String) -> Texture2D:
	return Content.backplate_texture(car_id)


func _update_speed_motion() -> void:
	if _fast_bolt == null: return
	var save = get_node_or_null("/root/SaveData")
	var settings: Dictionary = save.data.get("settings", {}) if save != null else {}
	var mode := "charge" if _speed_charge_progress >= 0.0 else ("race" if _super_mode else "normal")
	var pose := SpeedMotion.sample(mode, _speed_charge_elapsed if mode == "charge" else _speed_race_elapsed,
		_speed_charge_progress, bool(settings.get("reduced_motion",false)), _speed_race_entry_scale, _super_mode)
	_fast_bolt.position = Vector2(8,8) + _fast_visual_padding
	_fast_bolt.scale = pose.scale
	_fast_bolt.rotation = pose.angle
	_fast_bolt.modulate = Color.WHITE
	_fast_bolt_material.set_shader_parameter("fill_amount", pose.fill)
	_fast_bolt_material.set_shader_parameter("fast", _fast_mode and mode == "normal")


func _refresh_fast_toggle_art(animate: bool = true) -> void:
	if _fast_toggle_art == null or _fast_toggle_knob == null: return
	_update_speed_motion()
	_fast_toggle_art.modulate = Color.WHITE
	_fast_track_material.set_shader_parameter("race_mode", _super_mode)
	var target_position := (FAST_KNOB_ON_POSITION if _fast_mode or _super_mode else FAST_KNOB_OFF_POSITION) + _fast_visual_padding
	var target_amount := 1.0 if _fast_mode or _super_mode else 0.0
	if _fast_toggle_knob_tween != null and _fast_toggle_knob_tween.is_valid():
		_fast_toggle_knob_tween.kill()
	if not animate or not is_inside_tree():
		_fast_toggle_knob.position = target_position
		_fast_track_material.set_shader_parameter("enabled_amount", target_amount)
		return
	_fast_toggle_knob_tween = _gameplay_tween().set_parallel(true)
	_fast_toggle_knob_tween.tween_property(_fast_toggle_knob, "position", target_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var amount := float(_fast_track_material.get_shader_parameter("enabled_amount"))
	_fast_toggle_knob_tween.tween_method(func(value: float): _fast_track_material.set_shader_parameter("enabled_amount", value), amount, target_amount, 0.2)


func _feedback_frame_style(color: Color) -> StyleBoxFlat:
	var style := _style(Color.TRANSPARENT, 48, color, 12)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _round_badge_style(fill: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = Color(1, 1, 1, 0.96)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.shadow_color = Color(0.18, 0.22, 0.28, 0.18)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 3)
	return style


func _make_label(text_value: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = L.text(text_value)
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _style(fill: Color, radius: int, border: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style


func _debug_ui_enabled() -> bool:
	return OS.is_debug_build() and bool(ProjectSettings.get_setting("debug/show_game_controls", false))


func _paper_style(_fill: Color, _border: Color, _border_width: int, _radius: int) -> StyleBoxEmpty:
	return PaperUI.panel()


func _apply_invisible_button_style(button: BaseButton) -> void:
	for style_name in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
		button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	if button is CheckButton:
		var empty_icon := ImageTexture.new()
		for icon_name in ["checked", "unchecked", "checked_disabled", "unchecked_disabled"]:
			button.add_theme_icon_override(icon_name, empty_icon)


static func phase_names() -> Array[String]:
	return ["IDLE", "PREPARING", "PACKING", "ENTERING", "PRESENTING", "ANSWERING", "REVEALING", "COMPLETE"]


static func normal_timings() -> Dictionary:
	return NORMAL_MS.duplicate(true)


static func fast_timings() -> Dictionary:
	return FAST_MS.duplicate(true)


func debug_select_correct() -> void:
	if phase == Phase.ANSWERING:
		_answer_ready_at_ms = 0
		_on_option_pressed(int(_plan.judgments[_judgment_index].correct_index))


func debug_select_incorrect() -> void:
	if phase == Phase.ANSWERING:
		_answer_ready_at_ms = 0
		var correct_index := int(_plan.judgments[_judgment_index].correct_index)
		_on_option_pressed((correct_index + 1) % _plan.judgments[_judgment_index].option_ids.size())


func debug_enable_fast_mode() -> void:
	_fast_mode = true
	_fast_toggle.set_pressed_no_signal(true)
	_sync_active_speed()
	_refresh_fast_toggle_art(false)


func debug_disable_fast_mode() -> void:
	_fast_mode = false
	_fast_toggle.set_pressed_no_signal(false)
	_refresh_fast_toggle_art(false)


func debug_click_preparation() -> void:
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_on_current_card_gui_input(click)


func debug_preparation_ready() -> bool:
	return _preparation_click_ready


func debug_press_option(option_index: int) -> void:
	_on_option_pressed(option_index)


func debug_correct_index() -> int:
	if _plan.is_empty() or _judgment_index >= _plan.judgments.size():
		return -1
	return int(_plan.judgments[_judgment_index].correct_index)


func debug_answer_guard_remaining_ms() -> int:
	return maxi(0, _answer_ready_at_ms - int(_gameplay_elapsed_ms))


func debug_trigger_hint() -> void:
	_on_hint_timeout()


func debug_hint_fired() -> bool:
	return _hinted


func debug_judgment_index() -> int:
	return _judgment_index


func debug_progress_states() -> Array[String]:
	var states: Array[String] = []
	for index in range(JUDGMENT_COUNT):
		if index >= _judgment_results.size():
			states.append("pending")
		else:
			states.append("correct" if _judgment_results[index] else "incorrect")
	return states


func debug_set_progress_results(results: Array[bool]) -> void:
	_judgment_results = results.duplicate()
	_update_progress()


func debug_start_mode(mode_name: String, enable_persistence: bool = false) -> void:
	_cancel_tutorial()
	_current_mode = mode_name
	_progress_persistence_enabled = enable_persistence
	_mode_panel.visible = false
	_instruction_label.visible = false
	_feedback_label.visible = false
	_fast_toggle.visible = true
	if _debug_reset_button != null:
		_debug_reset_button.visible = _debug_ui_enabled()
	if _debug_discovery_selector != null:
		_debug_discovery_selector.visible = _debug_ui_enabled()
	_road_panel.visible = true
	_progress_box.visible = true
	_start_level()


func debug_force_discoveries(forced_positions: Dictionary, seed_value: int = 777) -> void:
	var positions: Array[int] = []
	for position in forced_positions.keys():
		positions.append(int(position))
	positions.sort()
	var car_ids: Array[String] = []
	for position in positions:
		car_ids.append(str(forced_positions[position]))
	_discovery_override = {
		"seed": seed_value,
		"count": positions.size(),
		"car_ids": car_ids,
		"positions": positions,
		"forced_positions": forced_positions.duplicate(true),
		"probabilities": {"0": 0.0, "1": 1.0 if positions.size() == 1 else 0.0, "2": 1.0 if positions.size() == 2 else 0.0},
	}


func debug_set_next_discovery_count(count: int) -> void:
	_debug_next_discovery_count = clampi(count, 0, 2)
	if _debug_discovery_selector != null:
		_debug_discovery_selector.select(_debug_next_discovery_count + 1)


func debug_reset_progress() -> void:
	_on_debug_reset_progress()


func debug_discovery_ids() -> Array[String]:
	return _string_array(_plan.get("discovery_car_ids", []))


func debug_newly_collected() -> Array[String]:
	return _newly_collected_this_level.duplicate()


func debug_completion_text() -> String:
	var text_value := "%s %s" % [_completion_title_label.text, _completion_names_label.text]
	for index in range(_completion_car_cards.size()):
		if _completion_car_cards[index].visible:
			text_value += " " + _completion_car_labels[index].text
	return text_value


func debug_visible_option_count() -> int:
	var count := 0
	for button in _option_buttons:
		if button.visible:
			count += 1
	return count


func debug_options_presented() -> bool:
	return _options_box.visible and debug_visible_option_count() > 0


func debug_current_option_ids() -> Array[String]:
	var ids: Array[String] = []
	for button in _option_buttons:
		if button.visible:
			ids.append(str(button.get_meta("car_id", "")))
	return ids


func debug_current_car_id() -> String:
	return _current_car_id()


func debug_open_garage(source_screen: String) -> void:
	_open_garage(source_screen)


func debug_garage() -> Control:
	return _garage_view


func debug_close_garage() -> void:
	_on_garage_close_requested()


func debug_completion_visible() -> bool:
	return _completion_panel.visible


func debug_mode_selection_visible() -> bool:
	return _mode_panel.visible


func debug_show_mode_selection() -> void:
	_show_mode_selection()


func debug_layout_answer_options(option_count: int) -> void:
	_options_box.visible = true
	_in_game_return_button.visible = true
	_return_confirmation_blocker.visible = false
	_return_confirmation_panel.visible = false
	_layout_options(option_count)


func debug_show_completion_layout() -> void:
	_fast_toggle.hide()
	_options_box.visible = false
	_in_game_return_button.visible = false
	_return_confirmation_blocker.visible = false
	_return_confirmation_panel.visible = false
	_mode_panel.visible = false
	_completion_names_label.text = ""
	_set_completion_car_showcase([])
	_completion_backdrop.visible = true
	_completion_panel.visible = true


func debug_show_return_confirmation() -> void:
	_in_game_return_button.visible = false
	_return_confirmation_blocker.visible = true
	_return_confirmation_panel.visible = true


func _install_custom_ui() -> void:
	await get_tree().process_frame
	CustomUI.install(self, "game")
	_apply_responsive_layout()
	_refresh_localization()


func _build_settings() -> void:
	_settings_view = SettingsView.new()
	_settings_view.name = "Settings"
	add_child(_settings_view)
	_settings_view.language_changed.connect(_refresh_localization)
	_settings_view.closed.connect(_on_settings_closed)
	_reset_progress_button = _settings_view.reset_button
	_settings_view.reset_requested.connect(_show_reset_confirmation)
	_settings_view.tutorial_requested.connect(_tutorial_from_settings)


func _show_settings() -> void:
	if is_instance_valid(_super_hold): _super_hold.cancel()
	if _settings_view.visible or _reset_progress_panel.visible or _return_confirmation_panel.visible or _completion_panel.visible:
		return
	_settings_previous_focus = get_viewport().gui_get_focus_owner()
	_settings_resume_game = _is_level_in_progress() and not _gameplay_paused
	if _settings_resume_game: _set_gameplay_paused(true)
	_lock_settings_background(self)
	_settings_view.present(_settings_restore_focus)


func _lock_settings_background(node: Node) -> void:
	if node == _settings_view: return
	if node is Control:
		_settings_saved_focus[node] = node.focus_mode
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children(): _lock_settings_background(child)


func _on_settings_closed() -> void:
	for control in _settings_saved_focus:
		if is_instance_valid(control): control.focus_mode = _settings_saved_focus[control]
	_settings_saved_focus.clear()
	if _settings_resume_game and _is_level_in_progress(): _set_gameplay_paused(false)
	_settings_resume_game = false
	if _settings_restore_focus and is_instance_valid(_settings_previous_focus) and _settings_previous_focus.is_visible_in_tree():
		_settings_previous_focus.grab_focus()
	_settings_previous_focus = null


func _cancel_settings() -> void:
	if is_instance_valid(_reset_progress_panel) and _reset_progress_panel.visible: _cancel_reset_confirmation()
	if is_instance_valid(_settings_view): _settings_view.cancel()
	_on_settings_closed()


func _refresh_localization() -> void:
	if _super_mode and phase == Phase.COMPLETE and is_instance_valid(_super_result_view): _super_result_view.refresh()
	L.refresh_tree(self)
	_align_completion_title()
	var title := _mode_panel.get_node("HitTargets/MenuTitle") as TextureRect
	title.texture = Content.asset(MENU_TITLE_EN if L.current_language() == "en" else MENU_TITLE)
	if not _current_car_id().is_empty(): _current_label.text = _car_name(_current_car_id())
	for index in range(_option_buttons.size()):
		var car_id := str(_option_buttons[index].get_meta("car_id", ""))
		if not car_id.is_empty(): _option_labels[index].text = _car_name(car_id)
	for index in range(_completion_car_cards.size()):
		if index < _newly_collected_this_level.size(): _completion_car_labels[index].text = _car_name(_newly_collected_this_level[index])
	if is_instance_valid(_garage_view): _garage_view.refresh_localization()
	if is_instance_valid(_settings_view): _settings_view.refresh()
	if is_instance_valid(_tutorial_view): _tutorial_view.refresh_localization()
	_update_mode_buttons()



func _build_tutorial() -> void:
	_tutorial_view = TutorialView.new()
	_tutorial_view.name = "Tutorial"
	add_child(_tutorial_view)
	_tutorial_view.skip_requested.connect(_skip_tutorial)
	_tutorial_view.play_requested.connect(_play_after_tutorial)
	_tutorial_view.replay_requested.connect(_replay_tutorial)
	_tutorial_view.home_requested.connect(_home_after_tutorial)
	_tutorial_view.language_requested.connect(_tutorial_language_requested)


func _on_starter_requested() -> void:
	if _settings_view.visible or not _mode_panel.visible: return
	var save := get_node_or_null("/root/SaveData")
	if not get_meta("content_preview", false) and save != null and not bool(save.data.settings.get("tutorial_completed", false)) and (not bool(save.data.settings.get("tutorial_seen", false)) or bool(save.data.settings.get("tutorial_pending", false))):
		# Existing seen saves stay opted out; only newly interrupted first-use runs retry.
		if not save.has_play_progress(save.data):
			_begin_tutorial("first_start")
			return
		_set_tutorial_preference("tutorial_seen", true)
		_set_tutorial_preference("tutorial_pending", false)
	_start_mode("starter")


func _tutorial_from_settings() -> void:
	if not _settings_view.visible or _reset_progress_panel.visible: return
	_settings_view.dismiss(func(): _begin_tutorial("settings"))


func _begin_tutorial(origin: String = "first_start") -> void:
	if _tutorial_active: return
	_show_mode_selection()
	_tutorial_origin = origin
	_tutorial_restore = {"fast": _fast_mode, "discovery": _discovery_override.duplicate(true), "debug_count": _debug_next_discovery_count, "card_focus": _current_card.focus_mode}
	_tutorial_restore.plates = []
	for plate in [_current_card_background, _current_card_shadow]:
		_tutorial_restore.plates.append({"visible": plate.visible, "scale": plate.scale, "pivot": plate.pivot_offset, "modulate": plate.modulate})
	_tutorial_restore.gift_modulate = _gift_panel.modulate
	_tutorial_restore.gift_scale = _gift_panel.scale
	_tutorial_active = true
	_tutorial_demonstrating = false
	_tutorial_replaying = false
	_tutorial_model_input = false
	if origin == "first_start":
		var save := get_node_or_null("/root/SaveData")
		if save != null and not bool(save.data.settings.get("tutorial_completed", false)):
			_set_tutorial_preference("tutorial_pending", true)
	_set_tutorial_preference("tutorial_seen", true)
	_current_mode = "starter"
	_progress_persistence_enabled = false
	_fast_mode = false
	_fast_toggle.set_pressed_no_signal(false)
	_refresh_fast_toggle_art(false)
	_debug_next_discovery_count = -1
	_discovery_override = {"seed": 771, "count": 0, "car_ids": [], "positions": [], "forced_positions": {}}
	_current_card.focus_mode = Control.FOCUS_ALL
	_start_level()
	_apply_tutorial_chrome()


func _tutorial_practice_plan() -> Dictionary:
	var ids := CarData.starter_ids()
	if ids.size() < 3: ids = CarData.all_ids()
	if ids.size() < 3: return {}
	var choices: Array[String] = [ids[0], ids[2]]
	# One complete, child-operated hide-and-find demonstration. Incorrect
	# attempts repeat this same memory; only a correct choice completes it.
	return {"seed": 771, "preparation_car_id": ids[0], "discovery_car_ids": [], "discovery_positions": [], "judgments": [
		{"index": 0, "current_car_id": ids[0], "remembered_car_id": ids[0], "option_ids": choices, "correct_index": 0}]}


func _apply_tutorial_chrome() -> void:
	if not _tutorial_active: return
	_progress_box.hide()
	_fast_toggle.hide()
	_in_game_return_button.hide()
	_instruction_label.hide()
	_feedback_label.hide()
	if _debug_reset_button != null: _debug_reset_button.hide()
	if _debug_discovery_selector != null: _debug_discovery_selector.hide()


func _set_tutorial_step(stage: String) -> void:
	if not _tutorial_active: return
	_tutorial_stage = stage
	_tutorial_view.show_step(stage)
	_apply_tutorial_chrome()


func _tutorial_valid(token: int) -> bool:
	return _tutorial_active and token == _run_token and is_inside_tree()


func _animate_tutorial_card_backing(token: int) -> void:
	# The vehicle keeps its settled pose while its existing editable paper plate
	# grows underneath it. Each texture scales uniformly around its own center.
	var tween := _gameplay_tween().set_parallel(true)
	for plate in [_current_card_background, _current_card_shadow]:
		plate.show()
		plate.pivot_offset = plate.size * 0.5
		plate.scale = Vector2.ONE * 0.25
		plate.modulate.a = 0.0
		tween.tween_property(plate, "scale", Vector2.ONE, 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(plate, "modulate:a", 1.0, 0.18)
	await _await_tutorial_tween(tween, token)


func _animate_tutorial_gift_entry(token: int) -> void:
	phase = Phase.PACKING
	_gift_panel.show()
	_gift_panel.modulate.a = 0.0
	_gift_panel.scale = Vector2.ONE * 0.25
	var tween := _gameplay_tween().set_parallel(true)
	tween.tween_property(_gift_panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_gift_panel, "modulate:a", 1.0, 0.18)
	await _await_tutorial_tween(tween, token)


func _animate_tutorial_options(token: int, next_stage: String) -> void:
	if not _tutorial_valid(token): return
	var judgment: Dictionary = _plan.judgments[0]
	phase = Phase.PRESENTING
	_current_card.hide()
	_options_box.show()
	_layout_options(2)
	var tween := _gameplay_tween().set_parallel(true)
	for index in range(2):
		var button := _option_buttons[index]
		_set_option_content(index, judgment.option_ids[index])
		button.set_meta("car_id", judgment.option_ids[index])
		_apply_option_style(button, judgment.option_ids[index], "normal")
		button.disabled = true
		button.scale = Vector2.ONE * 0.25
		button.modulate = Color(1, 1, 1, 0)
		tween.tween_property(button, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "modulate", Color.WHITE, 0.24)
	_emit_event("options_presented", [judgment.option_ids, judgment.correct_index, 0])
	await _await_tutorial_tween(tween, token)
	if not _tutorial_valid(token): return
	phase = Phase.ANSWERING
	_answer_ready_at_ms = int(_gameplay_elapsed_ms) + int(INPUT_GUARD_SECONDS * 1000.0)
	_hinted = false
	for index in range(2): _option_buttons[index].disabled = false
	_set_tutorial_step(next_stage)
	_tutorial_view.cue_choices(_gift_panel, _tutorial_visible_options())


func _tutorial_wait(seconds: float, token: int) -> void:
	# Engine-time frames work in both real play and fixed-FPS capture.
	var elapsed := 0.0
	while elapsed < seconds and _tutorial_valid(token):
		await get_tree().process_frame
		if not _gameplay_paused: elapsed += get_process_delta_time()


func _await_tutorial_tween(tween: Tween, token: int) -> void:
	# Tutorial-only beats do not introduce authored game-speed setting keys.
	while _tutorial_valid(token) and tween.is_valid():
		await get_tree().process_frame


func _tutorial_visible_options() -> Array:
	var options: Array = []
	for button in _option_buttons:
		if button.visible: options.append(button)
	return options


func _tutorial_model_choice(token: int) -> void:
	# Only the first round is modeled. The box opens before the hand chooses,
	# showing which previous car is the answer while the new arrival stays vivid.
	if not _tutorial_valid(token): return
	var judgment: Dictionary = _plan.judgments[_judgment_index]
	await _tutorial_wait(0.65, token)
	if not _tutorial_valid(token): return
	_gift_label.text = ""
	_gift_motion.set_car(judgment.remembered_car_id)
	_gift_motion.set_reveal_layer(true)
	var reveal := _gameplay_tween()
	reveal.tween_method(func(amount: float):
		_gift_motion.set_pose(amount)
		_gift_motion.pose_car(Vector2(191, lerpf(250.0, -38.0, amount)), 0.8), 0.0, 1.0, 0.65)
	await _await_tutorial_tween(reveal, token)
	if not _tutorial_valid(token): return
	_tutorial_view.cue_choices(_gift_panel, _tutorial_visible_options(), int(judgment.correct_index))
	await _tutorial_wait(0.65, token)
	if not _tutorial_valid(token): return
	await _tutorial_view.animate_tap(_option_buttons[judgment.correct_index])
	if not _tutorial_valid(token): return
	_tutorial_model_input = true
	_on_option_pressed(int(judgment.correct_index))
	_tutorial_model_input = false


func _settle_tutorial_choice_entry() -> void:
	# An intentional tap can pass the input guard before the entry tween ends.
	# Settle that presentation so it cannot overwrite the feedback transform.
	if _active_kind != "joint_entry" or _active_tween == null or not _active_tween.is_valid(): return
	_kill_active_tween()
	_stop_road_audio()
	_current_card.position = _car_target_position()
	_current_card.modulate = Color.WHITE
	for button in _option_buttons:
		if button.visible:
			button.scale = Vector2.ONE
			button.modulate = Color.WHITE


func _start_tutorial_correct_feedback(option_index: int, token: int) -> void:
	_cancel_tutorial_feedback()
	_tutorial_feedback_index = option_index
	_tutorial_feedback_rest_position = _option_buttons[option_index].position
	_tutorial_feedback_check_shown = false
	# A held physical press has already supplied the first beat. A modeled or
	# very quick tap starts with the same gentle compression before rebounding.
	var start := 0.18 if _tutorial_committed_scale <= 0.985 else 0.0
	_pose_tutorial_feedback(start)
	_tutorial_feedback_tween = _gameplay_tween()
	_tutorial_feedback_tween.tween_method(_pose_tutorial_feedback, start, 1.0, 0.42 * (1.0 - start))
	_tutorial_feedback_tween.tween_callback(func():
		if _tutorial_valid(token) and _tutorial_feedback_index == option_index:
			_pose_tutorial_feedback(1.0))


func _pose_tutorial_feedback(progress: float) -> void:
	if _tutorial_feedback_index < 0 or _tutorial_feedback_index >= _option_buttons.size(): return
	_tutorial_feedback_progress = progress
	var scale_value: float
	var lift: float
	var shadow_alpha: float
	if progress < 0.18:
		var amount := smoothstep(0.0, 0.18, progress)
		scale_value = lerpf(1.0, 0.965, amount)
		lift = lerpf(0.0, 3.0, amount)
		shadow_alpha = lerpf(0.22, 0.12, amount)
	elif progress < 0.55:
		var amount := 1.0 - pow(1.0 - clampf((progress - 0.18) / 0.37, 0.0, 1.0), 3.0)
		scale_value = lerpf(0.965, 1.035, amount)
		lift = lerpf(3.0, -7.0, amount)
		shadow_alpha = lerpf(0.12, 0.26, amount)
	else:
		var amount := smoothstep(0.55, 1.0, progress)
		scale_value = lerpf(1.035, 1.0, amount)
		lift = lerpf(-7.0, 0.0, amount)
		shadow_alpha = lerpf(0.26, 0.22, amount)
	var button := _option_buttons[_tutorial_feedback_index]
	button.scale = Vector2.ONE * scale_value
	button.position = _tutorial_feedback_rest_position + Vector2(0, lift)
	_option_shadows[_tutorial_feedback_index].self_modulate = Color(0.16, 0.25, 0.34, shadow_alpha)
	if progress >= 0.18 and not _tutorial_feedback_check_shown:
		_tutorial_feedback_check_shown = true
		_tutorial_view.cue_success(button)


func _cancel_tutorial_feedback() -> void:
	if _tutorial_feedback_tween != null and _tutorial_feedback_tween.is_valid():
		_tutorial_feedback_tween.kill()
	_tutorial_feedback_tween = null
	if _tutorial_feedback_index >= 0 and _tutorial_feedback_index < _option_buttons.size():
		var button := _option_buttons[_tutorial_feedback_index]
		button.position = _tutorial_feedback_rest_position
		button.scale = Vector2.ONE
		_option_shadows[_tutorial_feedback_index].self_modulate = Color(0.16, 0.25, 0.34, 0.22)
	_tutorial_feedback_index = -1
	_tutorial_feedback_progress = 0.0
	_tutorial_feedback_check_shown = false


func _resolve_tutorial_answer(option_index: int, token: int) -> void:
	var judgment: Dictionary = _plan.judgments[_judgment_index]
	var correct := option_index == int(judgment.correct_index)
	_set_tutorial_step("found" if correct else "retry")
	_tutorial_view.clear_cue()
	# No textual verdict, score, or collection write; keep feedback on its paper seal.
	if correct:
		# The tutorial uses one textured paper check, never the ordinary badge
		# and a second overlay marker on the same card.
		_apply_option_style(_option_buttons[option_index], judgment.option_ids[option_index], "normal")
		_start_tutorial_correct_feedback(option_index, token)
	else:
		_apply_option_style(_option_buttons[option_index], judgment.option_ids[option_index], "incorrect")
	_emit_event("answer_committed", [judgment.option_ids[option_index], correct, 0, _judgment_index])
	_emit_event("reveal_started", [judgment.remembered_car_id, _judgment_index])
	_gift_label.text = ""
	_gift_motion.set_car(judgment.remembered_car_id)
	_gift_motion.set_reveal_layer(true)
	var reveal := _gameplay_tween()
	var opening: float = _gift_motion.open_amount
	var emphasis_shown := [false]
	reveal.tween_method(func(amount: float):
		if amount >= 0.12 and not emphasis_shown[0]:
			emphasis_shown[0] = true
			if not correct: _apply_option_style(_option_buttons[judgment.correct_index], judgment.remembered_car_id, "correct")
			_set_reveal_emphasis(int(judgment.correct_index))
		_gift_motion.set_pose(amount)
		_gift_motion.pose_car(Vector2(191, lerpf(250.0, -38.0, amount)), 0.8), opening, 1.0, 0.65)
	await _await_tutorial_tween(reveal, token)
	if not _tutorial_valid(token): return
	_emit_event("reveal_completed", [judgment.remembered_car_id, _judgment_index])
	await _tutorial_wait(0.85 if correct else 0.7, token)
	if not _tutorial_valid(token): return
	await _finish_tutorial_answer(correct, token)


func _tutorial_replay_memory(token: int) -> void:
	# The opened gift demonstrates its contents, then closes around that same
	# car. Do not introduce a second vehicle or a second observation task.
	_tutorial_replaying = true
	_options_box.hide()
	_current_card.hide()
	_tutorial_view.clear_cue()
	phase = Phase.REVEALING
	var close := _gameplay_tween()
	close.tween_method(func(amount: float):
		_gift_motion.set_pose(1.0 - amount)
		_gift_motion.pose_car(Vector2(191, lerpf(-38.0, 250.0, amount)), 0.8), 0.0, 1.0, 0.45)
	await _await_tutorial_tween(close, token)
	if not _tutorial_valid(token): return
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	await _tutorial_wait(0.25, token)
	if not _tutorial_valid(token): return
	_tutorial_replaying = false
	await _animate_tutorial_options(token, "retry")


func _finish_tutorial_answer(correct: bool, token: int) -> void:
	if not _tutorial_valid(token): return
	_cancel_tutorial_feedback()
	_feedback_label.hide()
	if not correct:
		await _tutorial_replay_memory(token)
		return
	_tutorial_view.clear_cue()
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	_options_box.hide()
	_hint_timer.stop()
	_current_card.hide()
	_gift_panel.hide()
	_road_panel.hide()
	phase = Phase.COMPLETE
	_set_gameplay_paused(true)
	_tutorial_stage = "complete"
	_set_tutorial_preference("tutorial_completed", true)
	_set_tutorial_preference("tutorial_pending", false)
	_tutorial_view.show_complete()


func _set_tutorial_preference(key: String, value: bool) -> void:
	if get_meta("content_preview", false): return
	var save := get_node_or_null("/root/SaveData")
	if save == null or save.data.is_empty(): return
	if save.data.settings.get(key, false) == value: return
	save.data.settings[key] = value
	save.save()


func _cancel_tutorial() -> void:
	if not _tutorial_active: return
	_cancel_tutorial_feedback()
	_tutorial_active = false
	_tutorial_demonstrating = false
	_tutorial_replaying = false
	_tutorial_model_input = false
	_current_art.set_presentation_alpha(1.0)
	_gift_panel.modulate = _tutorial_restore.get("gift_modulate", Color.WHITE)
	_gift_panel.scale = _tutorial_restore.get("gift_scale", Vector2.ONE)
	for index in range(2):
		var plate: TextureRect = [_current_card_background, _current_card_shadow][index]
		var rest: Dictionary = _tutorial_restore.plates[index]
		plate.visible = rest.visible
		plate.scale = rest.scale
		plate.pivot_offset = rest.pivot
		plate.modulate = rest.modulate
	_tutorial_stage = ""
	if is_instance_valid(_tutorial_view): _tutorial_view.dismiss()
	if not _tutorial_restore.is_empty():
		_fast_mode = bool(_tutorial_restore.fast)
		_discovery_override = _tutorial_restore.discovery.duplicate(true)
		_debug_next_discovery_count = int(_tutorial_restore.debug_count)
		_current_card.focus_mode = int(_tutorial_restore.card_focus)
		_fast_toggle.set_pressed_no_signal(_fast_mode)
		_refresh_fast_toggle_art(false)
	_tutorial_restore.clear()
	_set_gameplay_paused(false)


func _skip_tutorial() -> void:
	if not _tutorial_active: return
	_set_tutorial_preference("tutorial_pending", false)
	var origin := _tutorial_origin
	_show_mode_selection()
	if origin == "first_start": _start_mode("starter")
	else: _show_settings()


func _play_after_tutorial() -> void:
	if not _tutorial_active: return
	_show_mode_selection()
	_start_mode("starter")


func _replay_tutorial() -> void:
	if not _tutorial_active: return
	var origin := _tutorial_origin
	_show_mode_selection()
	_begin_tutorial(origin)


func _home_after_tutorial() -> void:
	if _tutorial_active: _show_mode_selection()


func _tutorial_language_requested(language: String) -> void:
	if not _tutorial_active: return
	L.set_language(language)
	_refresh_localization()


# Super mode is an ephemeral session. Ordinary speed remains an untouched preference.
func _activate_super_mode() -> void:
	if _tutorial_active or _gameplay_paused or not _is_level_in_progress(): return
	if _current_mode == "history" and not _history_unlocked(): return
	_super_release_blocked = true
	if not _super_mode:
		_super_car_pool = _known_car_ids().duplicate()
	_discovery_override.clear()
	_debug_next_discovery_count = -1
	if _debug_discovery_selector != null: _debug_discovery_selector.select(0)
	_speed_race_entry_scale = SpeedMotion.CHARGE_SCALE if _speed_charge_progress >= 0.0 else SpeedMotion.RACE_SCALE
	_speed_race_elapsed = 0.0
	_super_mode = true
	_cancel_super_charge()
	_start_level()
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("activate_super_music"): audio.activate_super_music()
	_refresh_fast_toggle_art(false)


func _exit_super_mode() -> void:
	if is_instance_valid(_super_hold): _super_hold.cancel()
	_race.abandon()
	_super_mode = false
	_super_car_pool.clear()
	if is_instance_valid(_current_card): _current_card.focus_mode = Control.FOCUS_NONE
	_super_release_blocked = false
	_cancel_super_charge()
	if is_instance_valid(_super_result_view): _super_result_view.hide()
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("stop_super_mode"): audio.stop_super_mode()


func _show_super_charge(amount: float) -> void:
	if amount <= 0.0:
		_cancel_super_charge()
		_refresh_fast_toggle_art(false)
		return
	if not _charge_sounding:
		_charge_sounding = true
		var audio := get_node_or_null("/root/AudioManager")
		if audio != null and audio.has_method("start_super_charge"): audio.start_super_charge()
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("update_super_charge"): audio.update_super_charge(amount)
	if _fast_toggle_knob_tween != null and _fast_toggle_knob_tween.is_valid(): _fast_toggle_knob_tween.kill()
	# Hold input stays at 250/1500 ms; only its visual 1250 ms fill is normalized.
	_speed_charge_progress = clampf((amount * 1500.0 - 250.0) / 1250.0, 0.0, 1.0)
	_speed_charge_elapsed = _speed_charge_progress * 1.25
	_fast_toggle_knob.position = (FAST_KNOB_ON_POSITION if _fast_mode or _super_mode else FAST_KNOB_OFF_POSITION) + _fast_visual_padding
	_fast_track_material.set_shader_parameter("enabled_amount", 1.0)
	_update_speed_motion()


func _cancel_super_charge() -> void:
	_speed_charge_progress = -1.0
	_speed_charge_elapsed = 0.0
	_update_speed_motion()
	_charge_sounding = false
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method("cancel_super_charge"): audio.cancel_super_charge()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if is_instance_valid(_super_hold): _super_hold.cancel()
		if _super_mode: _race.set_background(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		if _super_mode: _race.set_background(false)


func _present_super_options(judgment: Dictionary) -> void:
	_current_card.show()
	_current_card.position = _car_target_position()
	_current_card.scale = Vector2.ONE
	_current_card.modulate = Color.WHITE
	_gift_motion.clear_car()
	_gift_motion.set_pose(0.0)
	_options_box.show()
	_layout_options(judgment.option_ids.size())
	for index in range(judgment.option_ids.size()):
		var id: String = judgment.option_ids[index]
		_set_option_content(index,id)
		var button := _option_buttons[index]
		button.set_meta("car_id",id)
		button.scale = Vector2.ONE
		button.modulate = Color.WHITE
		button.disabled = false
		_apply_option_style(button,id,"normal")
		_set_option_visual_alpha(index,1.0)
	phase = Phase.ANSWERING
	_answer_ready_at_ms = int(_gameplay_elapsed_ms) + int(INPUT_GUARD_SECONDS * 1000.0)
	_hinted = false
	_hint_timer.stop()


func _resolve_super_answer(option_index: int, token: int) -> void:
	var judgment: Dictionary = _plan.judgments[_judgment_index]
	var correct := option_index == int(judgment.correct_index)
	if not _race.submit(correct,_judgment_index): return
	# The session freezes before audio, collection writes or the final feedback.
	if _race.state == "finished":
		var save := get_node_or_null("/root/SaveData")
		_race_save_result = save.append_race_record(_race.record) if save != null else {"saved":false}
	if correct: _correct_count += 1
	_judgment_results.append(correct)
	_apply_option_style(_option_buttons[option_index],judgment.option_ids[option_index],"correct" if correct else "incorrect")
	_apply_option_style(_option_buttons[judgment.correct_index],judgment.remembered_car_id,"correct")
	_update_progress()
	_emit_event("answer_committed",[judgment.option_ids[option_index],correct,0,_judgment_index])
	_collect_discovery(judgment.remembered_car_id)
	# Keep the current stimulus visible, with both marks, until the atomic switch.
	var end_ms := _gameplay_elapsed_ms + 200.0
	while token == _run_token and is_inside_tree() and (_gameplay_paused or _gameplay_elapsed_ms < end_ms):
		await get_tree().process_frame
	if token != _run_token or not _super_mode: return
	if _judgment_index == JUDGMENT_COUNT - 1:
		_complete_level()
		return
	_emit_event("current_car_promoted_to_memory",[judgment.current_car_id,_judgment_index])
	_judgment_index += 1
	await _present_judgment(token)


func _show_super_results(newly_unlocked: bool) -> void:
	_completion_panel.get_node("CompletionContent").hide()
	var reward := ""
	if newly_unlocked:
		reward = "History mode unlocked!" if L.current_language() == "en" else "新模式可玩啦！"
	_super_result_view.present(_race.record,bool(_race_save_result.get("saved",false)),reward,get_node_or_null("/root/SaveData"),str(_race_save_result.get("storage_status","")))
	_super_result_view.show()
	_layout_completion(false)
	_completion_backdrop.show()
	_completion_panel.show()
	_completion_dialog_motion.present("result",[DialogMotion.beat(_super_result_view,"body")],_dialog_reduced_motion())
