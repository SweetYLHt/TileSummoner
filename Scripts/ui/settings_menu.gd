## 设置菜单控制器
##
## 处理游戏设置的加载、保存和UI交互
extends Control
class_name SettingsMenu

## 设置已更改信号
signal settings_changed()

## 返回主菜单信号
signal back_requested()

## 设置数据
var _master_volume: float = 0.8
var _music_volume: float = 0.6
var _sfx_volume: float = 0.7
var _fullscreen: bool = false
var _vsync: bool = true
var _language: StringName = &"zh_CN"

## UI 引用
var _master_slider: HSlider
var _music_slider: HSlider
var _sfx_slider: HSlider
var _fullscreen_check: CheckBox
var _vsync_check: CheckBox
var _language_option: OptionButton


func _ready() -> void:
	_find_ui_elements()
	_load_settings()
	_connect_signals()
	_apply_settings()


## 查找UI元素
func _find_ui_elements() -> void:
	_master_slider = $Panel/VBoxContainer/AudioSection/MasterVolumeBox/HSlider
	_music_slider = $Panel/VBoxContainer/AudioSection/MusicVolumeBox/HSlider
	_sfx_slider = $Panel/VBoxContainer/AudioSection/SfxVolumeBox/HSlider
	_fullscreen_check = $Panel/VBoxContainer/DisplaySection/FullscreenBox/CheckBox
	_vsync_check = $Panel/VBoxContainer/DisplaySection/VSyncBox/CheckBox
	_language_option = $Panel/VBoxContainer/LanguageSection/LanguageBox/OptionButton


## 连接信号
func _connect_signals() -> void:
	if _master_slider:
		_master_slider.value_changed.connect(_on_master_volume_changed)
	if _music_slider:
		_music_slider.value_changed.connect(_on_music_volume_changed)
	if _sfx_slider:
		_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if _fullscreen_check:
		_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if _vsync_check:
		_vsync_check.toggled.connect(_on_vsync_toggled)
	if _language_option:
		_language_option.item_selected.connect(_on_language_selected)

	# 返回按钮
	var back_button = $Panel/VBoxContainer/BackButton
	if back_button:
		back_button.pressed.connect(_on_back_pressed)


## 从配置文件加载设置
func _load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load("user://settings.cfg")

	if err != OK:
		# 使用默认值
		_set_ui_values()
		return

	# 读取设置
	_master_volume = config.get_value("audio", "master_volume", 0.8)
	_music_volume = config.get_value("audio", "music_volume", 0.6)
	_sfx_volume = config.get_value("audio", "sfx_volume", 0.7)
	_fullscreen = config.get_value("display", "fullscreen", false)
	_vsync = config.get_value("display", "vsync", true)
	_language = config.get_value("general", "language", &"zh_CN")

	_set_ui_values()


## 设置UI控件值
func _set_ui_values() -> void:
	if _master_slider:
		_master_slider.value = _master_volume
	if _music_slider:
		_music_slider.value = _music_volume
	if _sfx_slider:
		_sfx_slider.value = _sfx_volume
	if _fullscreen_check:
		_fullscreen_check.button_pressed = _fullscreen
	if _vsync_check:
		_vsync_check.button_pressed = _vsync

	# 设置语言选项
	if _language_option:
		_language_option.clear()
		_language_option.add_item("简体中文", 0)
		_language_option.add_item("English", 1)

		match _language:
			&"zh_CN":
				_language_option.selected = 0
			&"en":
				_language_option.selected = 1
			_:
				_language_option.selected = 0


## 应用设置到游戏
func _apply_settings() -> void:
	# 设置全屏
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		if _fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# 设置VSync
	if _vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## 保存设置到配置文件
func _save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "music_volume", _music_volume)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.set_value("display", "fullscreen", _fullscreen)
	config.set_value("display", "vsync", _vsync)
	config.set_value("general", "language", _language)

	config.save("user://settings.cfg")


## ============================================================================
## 信号处理
## ============================================================================

func _on_master_volume_changed(value: float) -> void:
	_master_volume = value
	# TODO: 实际应用音量设置
	settings_changed.emit()


func _on_music_volume_changed(value: float) -> void:
	_music_volume = value
	# TODO: 实际应用音量设置
	settings_changed.emit()


func _on_sfx_volume_changed(value: float) -> void:
	_sfx_volume = value
	# TODO: 实际应用音量设置
	settings_changed.emit()


func _on_fullscreen_toggled(pressed: bool) -> void:
	_fullscreen = pressed
	_apply_settings()
	settings_changed.emit()


func _on_vsync_toggled(pressed: bool) -> void:
	_vsync = pressed
	_apply_settings()
	settings_changed.emit()


func _on_language_selected(index: int) -> void:
	match index:
		0:
			_language = &"zh_CN"
		1:
			_language = &"en"
		_:
			_language = &"zh_CN"
	# TODO: 实现语言切换
	settings_changed.emit()


func _on_back_pressed() -> void:
	_save_settings()
	back_requested.emit()
	SceneManager.transition_to_main_menu()
