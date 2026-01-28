## 主菜单UI控制器
##
## 赛博朋克风格主菜单，左侧导航 + 右侧装饰区域
## 包含标题动画、按钮 hover 效果和背景发光球体
extends Control
class_name MainMenuUI


## ============================================================================
## 常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const BUTTON_HOVER_OFFSET_X := 8.0
const BUTTON_HOVER_DURATION := 0.2

## 入场动画时间参数
const ANIM_TITLE_DELAY := 0.0
const ANIM_UNDERLINE_DELAY := 0.15
const ANIM_SUBTITLE_DELAY := 0.2
const ANIM_BUTTON_START_DELAY := 0.25
const ANIM_BUTTON_INTERVAL := 0.1
const ANIM_VERSION_DELAY := 0.5
const ANIM_ELEMENT_DURATION := 0.4


## ============================================================================
## 节点引用
## ============================================================================

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _exit_button: Button = %ExitButton
@onready var _continue_button: Button = %ContinueButton
@onready var _save_slots_button: Button = %SaveSlotsButton
@onready var _title_rich_text: RichTextLabel = %TitleRichText
@onready var _gold_underline: ColorRect = %GoldUnderline
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _glow_orbs: Node2D = %GlowOrbsContainer
@onready var _version_label: Label = %VersionLabel


## ============================================================================
## 内部状态
## ============================================================================

var _button_tweens: Dictionary = {}


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_setup_title_bbcode()
	_connect_signals()
	_setup_button_styles()
	_setup_button_hover_effects()
	_play_enter_animation()


## ============================================================================
## 标题设置
## ============================================================================

## 设置 RichTextLabel BBCode 标题内容
func _setup_title_bbcode() -> void:
	if not _title_rich_text:
		return
	_title_rich_text.bbcode_enabled = true
	_title_rich_text.text = "[font_size=72][color=#f5f5f7]TILE[/color][/font_size]\n[font_size=48][color=#dfb22a][outline_size=3][outline_color=#dfb22a66]SUMMONER[/outline_color][/outline_size][/color][/font_size]"


## ============================================================================
## 信号连接
## ============================================================================

## 连接所有按钮信号
func _connect_signals() -> void:
	if _start_button:
		_start_button.pressed.connect(_on_start_pressed)
	if _settings_button:
		_settings_button.pressed.connect(_on_settings_pressed)
	if _exit_button:
		_exit_button.pressed.connect(_on_exit_pressed)


## ============================================================================
## 按钮样式
## ============================================================================

## 为所有按钮应用对应样式
func _setup_button_styles() -> void:
	if _continue_button:
		MenuButtonStyler.apply_to_button(_continue_button, MenuButtonStyler.ButtonType.PRIMARY)
	if _start_button:
		MenuButtonStyler.apply_to_button(_start_button, MenuButtonStyler.ButtonType.PRIMARY)
	if _save_slots_button:
		MenuButtonStyler.apply_to_button(_save_slots_button, MenuButtonStyler.ButtonType.DEFAULT)
	if _settings_button:
		MenuButtonStyler.apply_to_button(_settings_button, MenuButtonStyler.ButtonType.DEFAULT)
	if _exit_button:
		MenuButtonStyler.apply_to_button(_exit_button, MenuButtonStyler.ButtonType.DANGER)


## ============================================================================
## Hover 效果
## ============================================================================

## 为可用按钮设置 hover 平移效果
func _setup_button_hover_effects() -> void:
	var buttons: Array[Button] = [
		_start_button, _settings_button, _exit_button,
	]
	for button in buttons:
		if button and not button.disabled:
			button.mouse_entered.connect(_animate_button_hover.bind(button, true))
			button.mouse_exited.connect(_animate_button_hover.bind(button, false))


## 按钮 hover 平移动画
func _animate_button_hover(button: Button, entered: bool) -> void:
	if not button:
		return

	# 取消之前的 tween
	var button_id := button.get_instance_id()
	if _button_tweens.has(button_id):
		var old_tween: Tween = _button_tweens[button_id]
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := create_tween()
	var target_x := BUTTON_HOVER_OFFSET_X if entered else 0.0
	tween.tween_property(button, "position:x", target_x, BUTTON_HOVER_DURATION) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	_button_tweens[button_id] = tween


## ============================================================================
## 入场动画
## ============================================================================

## 播放入场动画序列
func _play_enter_animation() -> void:
	# 初始化所有元素为不可见
	_set_initial_animation_state()

	# 标题区域
	if _title_rich_text:
		var title_tween := create_tween()
		title_tween.tween_property(_title_rich_text, "modulate:a", 1.0, ANIM_ELEMENT_DURATION) \
			.set_delay(ANIM_TITLE_DELAY) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		title_tween.parallel().tween_property(_title_rich_text, "position:y",
			_title_rich_text.position.y, ANIM_ELEMENT_DURATION) \
			.from(_title_rich_text.position.y - 30.0) \
			.set_delay(ANIM_TITLE_DELAY) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 金色下划线展开
	if _gold_underline:
		var target_width := _gold_underline.size.x
		_gold_underline.size.x = 0.0
		var underline_tween := create_tween()
		underline_tween.tween_property(_gold_underline, "size:x", target_width, 0.3) \
			.set_delay(ANIM_UNDERLINE_DELAY) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 副标题淡入
	if _subtitle_label:
		var subtitle_tween := create_tween()
		subtitle_tween.tween_property(_subtitle_label, "modulate:a", 1.0, ANIM_ELEMENT_DURATION) \
			.set_delay(ANIM_SUBTITLE_DELAY) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 按钮依次滑入
	var buttons: Array[Button] = []
	if _continue_button:
		buttons.append(_continue_button)
	if _start_button:
		buttons.append(_start_button)
	if _save_slots_button:
		buttons.append(_save_slots_button)
	if _settings_button:
		buttons.append(_settings_button)
	if _exit_button:
		buttons.append(_exit_button)

	for i in range(buttons.size()):
		var button := buttons[i]
		var delay := ANIM_BUTTON_START_DELAY + i * ANIM_BUTTON_INTERVAL
		var btn_tween := create_tween()
		btn_tween.tween_property(button, "modulate:a", 1.0, ANIM_ELEMENT_DURATION) \
			.set_delay(delay) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		btn_tween.parallel().tween_property(button, "position:x",
			button.position.x, ANIM_ELEMENT_DURATION) \
			.from(button.position.x - 20.0) \
			.set_delay(delay) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 版本标签淡入
	if _version_label:
		var ver_tween := create_tween()
		ver_tween.tween_property(_version_label, "modulate:a", 1.0, ANIM_ELEMENT_DURATION) \
			.set_delay(ANIM_VERSION_DELAY) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


## 设置动画初始状态 (全部透明)
func _set_initial_animation_state() -> void:
	if _title_rich_text:
		_title_rich_text.modulate.a = 0.0
	if _gold_underline:
		_gold_underline.modulate.a = 1.0
	if _subtitle_label:
		_subtitle_label.modulate.a = 0.0
	if _version_label:
		_version_label.modulate.a = 0.0

	var buttons: Array[Button] = []
	if _continue_button:
		buttons.append(_continue_button)
	if _start_button:
		buttons.append(_start_button)
	if _save_slots_button:
		buttons.append(_save_slots_button)
	if _settings_button:
		buttons.append(_settings_button)
	if _exit_button:
		buttons.append(_exit_button)

	for button in buttons:
		button.modulate.a = 0.0


## ============================================================================
## 按钮回调
## ============================================================================

## 开始游戏按钮
func _on_start_pressed() -> void:
	SceneManager.transition_to_terrain_config()


## 设置按钮
func _on_settings_pressed() -> void:
	SceneManager.show_settings_popup()


## 退出按钮
func _on_exit_pressed() -> void:
	get_tree().quit()
