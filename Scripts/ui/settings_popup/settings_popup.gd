## 设置弹窗控制器
##
## 玻璃拟态设置弹窗，可从主菜单或游戏内打开
## 提供音频、视频、游戏性、语言设置功能
extends Control
class_name SettingsPopup


## ============================================================================
## 依赖
## ============================================================================

## @deprecated 使用 UIThemeConstants 和组件类替代
const _Style := preload("res://Scripts/ui/settings_popup/settings_popup_style.gd")

## 新组件样式
const _UITheme := preload("res://Scripts/ui/components/ui_theme_constants.gd")
const _StyledButton := preload("res://Scripts/ui/components/styled_button.gd")
const _GlassPanel := preload("res://Scripts/ui/components/glass_panel.gd")


## ============================================================================
## 信号
## ============================================================================

## 弹窗关闭时触发
signal closed()

## 设置保存时触发
signal settings_saved()


## ============================================================================
## 常量
## ============================================================================

const ANIM_DURATION := 0.25
const CONFIG_PATH := "user://settings.cfg"


## ============================================================================
## 节点引用
## ============================================================================

@onready var _dim_overlay: ColorRect = $DimOverlay
@onready var _glass_panel: Panel = $PopupContainer/GlassPanel

## 音频控件
@onready var _master_slider: HSlider = %MasterVolumeSlider
@onready var _music_slider: HSlider = %MusicVolumeSlider
@onready var _sfx_slider: HSlider = %SfxVolumeSlider

## 音频百分比标签
@onready var _master_value_label: Label = %MasterValueLabel
@onready var _music_value_label: Label = %MusicValueLabel
@onready var _sfx_value_label: Label = %SfxValueLabel

## 视频控件
@onready var _resolution_option: OptionButton = %ResolutionOption
@onready var _display_mode_option: OptionButton = %DisplayModeOption

## Gameplay 控件
@onready var _health_bars_toggle: CheckButton = %HealthBarsToggle
@onready var _camera_shake_toggle: CheckButton = %CameraShakeToggle
@onready var _auto_save_toggle: CheckButton = %AutoSaveToggle

## 语言控件
@onready var _language_option: OptionButton = %LanguageOption

## 按钮
@onready var _save_button: Button = %SaveButton
@onready var _cancel_button: Button = %CancelButton
@onready var _restore_button: Button = %RestoreDefaultsButton
@onready var _close_button: Button = $PopupContainer/GlassPanel/CloseButton

## Footer 面板
@onready var _footer_panel: PanelContainer = $PopupContainer/GlassPanel/ContentMargin/VBoxContainer/FooterPanel


## ============================================================================
## 设置数据
## ============================================================================

## 当前设置值
var _master_volume: float = 0.8
var _music_volume: float = 0.6
var _sfx_volume: float = 0.7
var _resolution: StringName = &"1920x1080"
var _display_mode: StringName = &"fullscreen"
var _show_health_bars: bool = true
var _camera_shake: bool = true
var _auto_save: bool = false
var _language: StringName = &"zh_CN"

## 打开弹窗时的原始值（用于取消时恢复）
var _original_master_volume: float = 0.8
var _original_music_volume: float = 0.6
var _original_sfx_volume: float = 0.7
var _original_resolution: StringName = &"1920x1080"
var _original_display_mode: StringName = &"fullscreen"
var _original_show_health_bars: bool = true
var _original_camera_shake: bool = true
var _original_auto_save: bool = false
var _original_language: StringName = &"zh_CN"


## ============================================================================
## 默认值
## ============================================================================

const DEFAULT_MASTER_VOLUME := 0.8
const DEFAULT_MUSIC_VOLUME := 0.6
const DEFAULT_SFX_VOLUME := 0.7
const DEFAULT_RESOLUTION := &"1920x1080"
const DEFAULT_DISPLAY_MODE := &"fullscreen"
const DEFAULT_SHOW_HEALTH_BARS := true
const DEFAULT_CAMERA_SHAKE := true
const DEFAULT_AUTO_SAVE := false
const DEFAULT_LANGUAGE := &"zh_CN"


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	visible = false
	_setup_styles()
	_setup_language_options()
	_setup_resolution_options()
	_setup_display_mode_options()
	_connect_signals()
	_load_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			_on_cancel_pressed()
			get_viewport().set_input_as_handled()


## ============================================================================
## 公共方法
## ============================================================================

## 显示弹窗
func show_popup() -> void:
	_load_settings()
	_store_original_values()
	_update_ui_from_settings()

	visible = true
	modulate.a = 1.0

	var tween := create_tween()

	# 背景模糊：渐变 shader intensity 0 -> 1
	if _dim_overlay and _dim_overlay.material:
		_dim_overlay.material.set_shader_parameter("intensity", 0.0)
		tween.tween_method(_set_blur_intensity, 0.0, 1.0, ANIM_DURATION) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 弹窗面板：淡入 + 缩放
	if _glass_panel:
		_glass_panel.modulate.a = 0.0
		_glass_panel.scale = Vector2(0.95, 0.95)
		tween.parallel().tween_property(_glass_panel, "modulate:a", 1.0, ANIM_DURATION) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(_glass_panel, "scale", Vector2.ONE, ANIM_DURATION) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


## 隐藏弹窗
func hide_popup() -> void:
	var tween := create_tween()

	# 背景模糊：渐变 shader intensity 1 -> 0
	if _dim_overlay and _dim_overlay.material:
		tween.tween_method(_set_blur_intensity, 1.0, 0.0, ANIM_DURATION) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	# 弹窗面板：淡出 + 缩放
	if _glass_panel:
		tween.parallel().tween_property(_glass_panel, "modulate:a", 0.0, ANIM_DURATION) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(_glass_panel, "scale", Vector2(0.95, 0.95), ANIM_DURATION) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tween.tween_callback(func():
		visible = false
		closed.emit()
	)


## 设置背景模糊强度 (tween_method 回调)
func _set_blur_intensity(value: float) -> void:
	if _dim_overlay and _dim_overlay.material:
		_dim_overlay.material.set_shader_parameter("intensity", value)


## ============================================================================
## 私有方法 - 初始化
## ============================================================================

## 设置控件样式
func _setup_styles() -> void:
	# 玻璃面板样式 - 使用新组件
	if _glass_panel:
		_GlassPanel.apply_to_panel(_glass_panel, _GlassPanel.PanelVariant.DEFAULT)

	# 滑块样式 - 暂时保留旧实现
	if _master_slider:
		_Style.apply_slider_style(_master_slider)
	if _music_slider:
		_Style.apply_slider_style(_music_slider)
	if _sfx_slider:
		_Style.apply_slider_style(_sfx_slider)

	# 按钮样式 - 使用新组件
	if _save_button:
		_StyledButton.apply_to_button(_save_button, _StyledButton.ButtonType.FILLED)
	if _cancel_button:
		_StyledButton.apply_to_button(_cancel_button, _StyledButton.ButtonType.SECONDARY)
	if _restore_button:
		_StyledButton.apply_to_button(_restore_button, _StyledButton.ButtonType.TEXT)

	# 选项按钮样式 - 暂时保留旧实现
	if _language_option:
		_Style.apply_option_button_style(_language_option)
	if _resolution_option:
		_Style.apply_option_button_style(_resolution_option)
	if _display_mode_option:
		_Style.apply_option_button_style(_display_mode_option)

	# Footer 面板样式 - 使用新组件
	if _footer_panel:
		_GlassPanel.apply_to_panel(_footer_panel, _GlassPanel.PanelVariant.FOOTER)


## 设置语言选项列表 (4个选项)
func _setup_language_options() -> void:
	if not _language_option:
		return

	_language_option.clear()
	_language_option.add_item("EN-UK", 0)
	_language_option.add_item("EN-US", 1)
	_language_option.add_item("Chinese", 2)
	_language_option.add_item("Japanese", 3)


## 设置分辨率选项列表
func _setup_resolution_options() -> void:
	if not _resolution_option:
		return

	_resolution_option.clear()
	_resolution_option.add_item("2560 x 1440", 0)
	_resolution_option.add_item("1920 x 1080", 1)
	_resolution_option.add_item("1600 x 900", 2)


## 设置显示模式选项列表
func _setup_display_mode_options() -> void:
	if not _display_mode_option:
		return

	_display_mode_option.clear()
	_display_mode_option.add_item("Fullscreen", 0)
	_display_mode_option.add_item("Borderless Windowed", 1)
	_display_mode_option.add_item("Windowed", 2)


## 连接信号
func _connect_signals() -> void:
	# 滑块
	if _master_slider:
		_master_slider.value_changed.connect(_on_master_volume_changed)
	if _music_slider:
		_music_slider.value_changed.connect(_on_music_volume_changed)
	if _sfx_slider:
		_sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	# 视频选项
	if _resolution_option:
		_resolution_option.item_selected.connect(_on_resolution_selected)
	if _display_mode_option:
		_display_mode_option.item_selected.connect(_on_display_mode_selected)

	# Gameplay 切换开关
	if _health_bars_toggle:
		_health_bars_toggle.toggled.connect(_on_health_bars_toggled)
	if _camera_shake_toggle:
		_camera_shake_toggle.toggled.connect(_on_camera_shake_toggled)
	if _auto_save_toggle:
		_auto_save_toggle.toggled.connect(_on_auto_save_toggled)

	# 语言选项
	if _language_option:
		_language_option.item_selected.connect(_on_language_selected)

	# 按钮
	if _save_button:
		_save_button.pressed.connect(_on_save_pressed)
	if _cancel_button:
		_cancel_button.pressed.connect(_on_cancel_pressed)
	if _restore_button:
		_restore_button.pressed.connect(_on_restore_defaults_pressed)
	if _close_button:
		_close_button.pressed.connect(_on_cancel_pressed)

	# 遮罩层点击关闭
	if _dim_overlay:
		_dim_overlay.gui_input.connect(_on_dim_overlay_input)


## ============================================================================
## 私有方法 - 设置管理
## ============================================================================

## 从配置文件加载设置
func _load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)

	if err != OK:
		# 使用默认值
		_reset_to_defaults()
		return

	_master_volume = config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)
	_music_volume = config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
	_sfx_volume = config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)
	_resolution = config.get_value("video", "resolution", DEFAULT_RESOLUTION)
	_display_mode = config.get_value("video", "display_mode", DEFAULT_DISPLAY_MODE)
	_show_health_bars = config.get_value("gameplay", "show_health_bars", DEFAULT_SHOW_HEALTH_BARS)
	_camera_shake = config.get_value("gameplay", "camera_shake", DEFAULT_CAMERA_SHAKE)
	_auto_save = config.get_value("gameplay", "auto_save", DEFAULT_AUTO_SAVE)
	_language = config.get_value("general", "language", DEFAULT_LANGUAGE)


## 保存设置到配置文件
func _save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "music_volume", _music_volume)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.set_value("video", "resolution", _resolution)
	config.set_value("video", "display_mode", _display_mode)
	config.set_value("gameplay", "show_health_bars", _show_health_bars)
	config.set_value("gameplay", "camera_shake", _camera_shake)
	config.set_value("gameplay", "auto_save", _auto_save)
	config.set_value("general", "language", _language)

	var err := config.save(CONFIG_PATH)
	if err != OK:
		push_error("Failed to save settings: %d" % err)


## 应用设置到游戏
func _apply_settings() -> void:
	# 显示模式
	match _display_mode:
		&"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		&"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		&"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# 分辨率（仅窗口模式下生效）
	if _display_mode == &"windowed":
		match _resolution:
			&"2560x1440":
				DisplayServer.window_set_size(Vector2i(2560, 1440))
			&"1920x1080":
				DisplayServer.window_set_size(Vector2i(1920, 1080))
			&"1600x900":
				DisplayServer.window_set_size(Vector2i(1600, 900))

	# TODO: 实际应用音量和语言设置


## 重置为默认值
func _reset_to_defaults() -> void:
	_master_volume = DEFAULT_MASTER_VOLUME
	_music_volume = DEFAULT_MUSIC_VOLUME
	_sfx_volume = DEFAULT_SFX_VOLUME
	_resolution = DEFAULT_RESOLUTION
	_display_mode = DEFAULT_DISPLAY_MODE
	_show_health_bars = DEFAULT_SHOW_HEALTH_BARS
	_camera_shake = DEFAULT_CAMERA_SHAKE
	_auto_save = DEFAULT_AUTO_SAVE
	_language = DEFAULT_LANGUAGE


## 存储打开时的原始值
func _store_original_values() -> void:
	_original_master_volume = _master_volume
	_original_music_volume = _music_volume
	_original_sfx_volume = _sfx_volume
	_original_resolution = _resolution
	_original_display_mode = _display_mode
	_original_show_health_bars = _show_health_bars
	_original_camera_shake = _camera_shake
	_original_auto_save = _auto_save
	_original_language = _language


## 恢复原始值
func _restore_original_values() -> void:
	_master_volume = _original_master_volume
	_music_volume = _original_music_volume
	_sfx_volume = _original_sfx_volume
	_resolution = _original_resolution
	_display_mode = _original_display_mode
	_show_health_bars = _original_show_health_bars
	_camera_shake = _original_camera_shake
	_auto_save = _original_auto_save
	_language = _original_language


## 根据设置更新 UI 控件
func _update_ui_from_settings() -> void:
	# 音频滑块
	if _master_slider:
		_master_slider.value = _master_volume
	if _music_slider:
		_music_slider.value = _music_volume
	if _sfx_slider:
		_sfx_slider.value = _sfx_volume

	# 百分比标签
	_update_volume_label(_master_value_label, _master_volume)
	_update_volume_label(_music_value_label, _music_volume)
	_update_volume_label(_sfx_value_label, _sfx_volume)

	# 分辨率
	if _resolution_option:
		match _resolution:
			&"2560x1440":
				_resolution_option.selected = 0
			&"1920x1080":
				_resolution_option.selected = 1
			&"1600x900":
				_resolution_option.selected = 2
			_:
				_resolution_option.selected = 1

	# 显示模式
	if _display_mode_option:
		match _display_mode:
			&"fullscreen":
				_display_mode_option.selected = 0
			&"borderless":
				_display_mode_option.selected = 1
			&"windowed":
				_display_mode_option.selected = 2
			_:
				_display_mode_option.selected = 0

	# Gameplay 开关
	if _health_bars_toggle:
		_health_bars_toggle.button_pressed = _show_health_bars
	if _camera_shake_toggle:
		_camera_shake_toggle.button_pressed = _camera_shake
	if _auto_save_toggle:
		_auto_save_toggle.button_pressed = _auto_save

	# 语言
	if _language_option:
		match _language:
			&"en_UK":
				_language_option.selected = 0
			&"en_US":
				_language_option.selected = 1
			&"zh_CN":
				_language_option.selected = 2
			&"ja":
				_language_option.selected = 3
			_:
				_language_option.selected = 2


## 更新音量百分比标签
func _update_volume_label(label: Label, value: float) -> void:
	if label:
		label.text = "%d%%" % int(value * 100)


## ============================================================================
## 信号处理 - 滑块
## ============================================================================

func _on_master_volume_changed(value: float) -> void:
	_master_volume = value
	_update_volume_label(_master_value_label, value)


func _on_music_volume_changed(value: float) -> void:
	_music_volume = value
	_update_volume_label(_music_value_label, value)


func _on_sfx_volume_changed(value: float) -> void:
	_sfx_volume = value
	_update_volume_label(_sfx_value_label, value)


## ============================================================================
## 信号处理 - 视频选项
## ============================================================================

func _on_resolution_selected(index: int) -> void:
	match index:
		0:
			_resolution = &"2560x1440"
		1:
			_resolution = &"1920x1080"
		2:
			_resolution = &"1600x900"
		_:
			_resolution = &"1920x1080"


func _on_display_mode_selected(index: int) -> void:
	match index:
		0:
			_display_mode = &"fullscreen"
		1:
			_display_mode = &"borderless"
		2:
			_display_mode = &"windowed"
		_:
			_display_mode = &"fullscreen"


## ============================================================================
## 信号处理 - Gameplay 切换开关
## ============================================================================

func _on_health_bars_toggled(pressed: bool) -> void:
	_show_health_bars = pressed


func _on_camera_shake_toggled(pressed: bool) -> void:
	_camera_shake = pressed


func _on_auto_save_toggled(pressed: bool) -> void:
	_auto_save = pressed


## ============================================================================
## 信号处理 - 语言选项
## ============================================================================

func _on_language_selected(index: int) -> void:
	match index:
		0:
			_language = &"en_UK"
		1:
			_language = &"en_US"
		2:
			_language = &"zh_CN"
		3:
			_language = &"ja"
		_:
			_language = &"zh_CN"


## ============================================================================
## 信号处理 - 按钮
## ============================================================================

func _on_save_pressed() -> void:
	_save_settings()
	_apply_settings()
	settings_saved.emit()
	hide_popup()


func _on_cancel_pressed() -> void:
	_restore_original_values()
	hide_popup()


func _on_restore_defaults_pressed() -> void:
	_reset_to_defaults()
	_update_ui_from_settings()


func _on_dim_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_cancel_pressed()
