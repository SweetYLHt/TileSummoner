## SettingsPopup 弹窗控制器测试套件
## 测试范围：
## 1. 弹窗结构（遮罩层、玻璃面板、边框）
## 2. UI 控件存在性
## 3. 显示/隐藏功能
## 4. 设置持久化
## 5. 按钮交互

class_name TestSettingsPopup
extends GdUnitTestSuite


## ============================================================================
## 常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const COLOR_TOLERANCE := 0.05
const POPUP_SCENE_PATH := "res://Scenes/ui/settings_popup/settings_popup.tscn"


## ============================================================================
## 实例变量
## ============================================================================

var _popup: SettingsPopup = null


## ============================================================================
## 生命周期
## ============================================================================

func before_test() -> void:
	var scene := load(POPUP_SCENE_PATH)
	if scene:
		_popup = scene.instantiate() as SettingsPopup
		if _popup:
			add_child(_popup)
			await get_tree().process_frame


func after_test() -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
		_popup = null


## ============================================================================
## 辅助方法
## ============================================================================

func _colors_are_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < COLOR_TOLERANCE \
		and absf(a.g - b.g) < COLOR_TOLERANCE \
		and absf(a.b - b.b) < COLOR_TOLERANCE


func _skip_if_no_popup() -> bool:
	if not _popup:
		push_warning("Popup not loaded, skipping test")
		return true
	return false


## ============================================================================
## 结构测试
## ============================================================================

## 测试1: 遮罩层存在且为 ColorRect
func test_dim_overlay_exists() -> void:
	if _skip_if_no_popup():
		return
	var overlay := _popup.get_node_or_null("DimOverlay")
	assert_that(overlay).is_not_null()
	assert_that(overlay).is_instanceof(ColorRect)


## 测试2: 玻璃面板存在
func test_glass_panel_exists() -> void:
	if _skip_if_no_popup():
		return
	var panel := _popup.get_node_or_null("PopupContainer/GlassPanel")
	assert_that(panel).is_not_null()
	assert_that(panel).is_instanceof(Panel)


## 测试3: 左边框强调条存在且宽度约为 6px
func test_left_border_accent_exists() -> void:
	if _skip_if_no_popup():
		return
	var border := _popup.get_node_or_null("PopupContainer/GlassPanel/LeftBorderAccent")
	assert_that(border).is_not_null()
	if border is ColorRect:
		assert_that(border.size.x).is_equal_approx(6.0, 1.0)


## 测试4: 关闭按钮存在
func test_close_button_exists() -> void:
	if _skip_if_no_popup():
		return
	var btn := _popup.get_node_or_null("PopupContainer/GlassPanel/CloseButton")
	assert_that(btn).is_not_null()


## 测试5: 标题标签包含 SETTINGS 文本
func test_title_label_text() -> void:
	if _skip_if_no_popup():
		return
	var label := _popup.get_node_or_null("%TitleLabel")
	if not label:
		label = _popup.find_child("TitleLabel", true, false)
	assert_that(label).is_not_null()
	if label is Label:
		assert_that(label.text.to_upper()).contains("SETTINGS")


## 测试S1: 标题包含金色句号 "."
func test_title_has_gold_dot() -> void:
	if _skip_if_no_popup():
		return
	var dot_label := _popup.find_child("DotLabel", true, false) as Label
	assert_that(dot_label).is_not_null()
	if dot_label:
		assert_that(dot_label.text).is_equal(".")
		var font_color: Color = dot_label.get_theme_color("font_color")
		assert_bool(_colors_are_close(font_color, GOLD_COLOR)).is_true()


## 测试S2: 标题下有金色下划线（约80px宽）
func test_gold_underline_exists() -> void:
	if _skip_if_no_popup():
		return
	var underline := _popup.find_child("GoldUnderline", true, false) as ColorRect
	assert_that(underline).is_not_null()
	if underline:
		assert_bool(_colors_are_close(underline.color, GOLD_COLOR)).is_true()
		assert_that(underline.custom_minimum_size.x).is_equal_approx(80.0, 5.0)


## 测试S5: 底部栏有独立深色半透明背景面板
func test_footer_has_dark_background() -> void:
	if _skip_if_no_popup():
		return
	var footer_panel := _popup.find_child("FooterPanel", true, false) as PanelContainer
	assert_that(footer_panel).is_not_null()


## 测试Y10: 遮罩层使用带模糊效果的 shader material
func test_dim_overlay_has_blur_shader() -> void:
	if _skip_if_no_popup():
		return
	var overlay := _popup.get_node_or_null("DimOverlay") as ColorRect
	assert_that(overlay).is_not_null()
	if overlay:
		assert_that(overlay.material).is_not_null()
		assert_that(overlay.material).is_instanceof(ShaderMaterial)


## ============================================================================
## 音频控件测试
## ============================================================================

## 测试6: 主音量滑块存在
func test_master_volume_slider_exists() -> void:
	if _skip_if_no_popup():
		return
	var slider := _popup.get_node_or_null("%MasterVolumeSlider")
	assert_that(slider).is_not_null()
	assert_that(slider).is_instanceof(HSlider)


## 测试7: 音乐音量滑块存在
func test_music_volume_slider_exists() -> void:
	if _skip_if_no_popup():
		return
	var slider := _popup.get_node_or_null("%MusicVolumeSlider")
	assert_that(slider).is_not_null()
	assert_that(slider).is_instanceof(HSlider)


## 测试8: 音效音量滑块存在
func test_sfx_volume_slider_exists() -> void:
	if _skip_if_no_popup():
		return
	var slider := _popup.get_node_or_null("%SfxVolumeSlider")
	assert_that(slider).is_not_null()
	assert_that(slider).is_instanceof(HSlider)


## 测试S7: 三个滑块都有百分比值 Label
func test_volume_value_labels_exist() -> void:
	if _skip_if_no_popup():
		return
	var master_val := _popup.get_node_or_null("%MasterValueLabel") as Label
	var music_val := _popup.get_node_or_null("%MusicValueLabel") as Label
	var sfx_val := _popup.get_node_or_null("%SfxValueLabel") as Label
	assert_that(master_val).is_not_null()
	assert_that(music_val).is_not_null()
	assert_that(sfx_val).is_not_null()


## 测试Y5: 滑块行使用垂直布局，标签在上滑块在下
func test_slider_layout_vertical() -> void:
	if _skip_if_no_popup():
		return
	var master_row := _popup.find_child("MasterVolumeRow", true, false)
	assert_that(master_row).is_not_null()
	assert_that(master_row).is_instanceof(VBoxContainer)


## 测试C1: Music 标签文本为 "MUSIC"（非 "Music Volume"）
func test_music_label_text() -> void:
	if _skip_if_no_popup():
		return
	var music_row := _popup.find_child("MusicVolumeRow", true, false)
	if not music_row:
		assert_that(music_row).is_not_null()
		return
	var label_row := music_row.get_node_or_null("LabelRow")
	if label_row:
		var label := label_row.get_node_or_null("Label") as Label
		if label:
			assert_that(label.text.to_upper()).is_equal("MUSIC")
			return
	# Fallback: 查找第一个 Label 子节点
	for child in music_row.get_children():
		if child is HBoxContainer:
			for sub in child.get_children():
				if sub is Label:
					assert_that(sub.text.to_upper()).is_equal("MUSIC")
					return


## 测试C1: SFX 标签文本为 "SFX"（非 "SFX Volume"）
func test_sfx_label_text() -> void:
	if _skip_if_no_popup():
		return
	var sfx_row := _popup.find_child("SfxVolumeRow", true, false)
	if not sfx_row:
		assert_that(sfx_row).is_not_null()
		return
	var label_row := sfx_row.get_node_or_null("LabelRow")
	if label_row:
		var label := label_row.get_node_or_null("Label") as Label
		if label:
			assert_that(label.text.to_upper()).is_equal("SFX")
			return
	for child in sfx_row.get_children():
		if child is HBoxContainer:
			for sub in child.get_children():
				if sub is Label:
					assert_that(sub.text.to_upper()).is_equal("SFX")
					return


## ============================================================================
## Video 区域测试（替换原 Display 区域）
## ============================================================================

## 测试C3/S4: Video 区域标题为 "VIDEO"
func test_video_section_title() -> void:
	if _skip_if_no_popup():
		return
	var title := _popup.find_child("DisplayTitle", true, false) as Label
	assert_that(title).is_not_null()
	if title:
		assert_that(title.text.to_upper()).is_equal("VIDEO")


## 测试S4: Resolution OptionButton 存在
func test_resolution_option_exists() -> void:
	if _skip_if_no_popup():
		return
	var option := _popup.get_node_or_null("%ResolutionOption")
	assert_that(option).is_not_null()
	assert_that(option).is_instanceof(OptionButton)


## 测试S4: Display Mode OptionButton 存在
func test_display_mode_option_exists() -> void:
	if _skip_if_no_popup():
		return
	var option := _popup.get_node_or_null("%DisplayModeOption")
	assert_that(option).is_not_null()
	assert_that(option).is_instanceof(OptionButton)


## ============================================================================
## Gameplay 区域测试
## ============================================================================

## 测试S3: Gameplay 区域标题存在
func test_gameplay_section_exists() -> void:
	if _skip_if_no_popup():
		return
	var title := _popup.find_child("GameplayTitle", true, false) as Label
	assert_that(title).is_not_null()
	if title:
		assert_that(title.text.to_upper()).is_equal("GAMEPLAY")


## 测试S3: Show Health Bars 开关存在
func test_health_bars_toggle_exists() -> void:
	if _skip_if_no_popup():
		return
	var toggle := _popup.get_node_or_null("%HealthBarsToggle")
	assert_that(toggle).is_not_null()
	assert_that(toggle).is_instanceof(CheckButton)


## 测试S3: Camera Shake 开关存在
func test_camera_shake_toggle_exists() -> void:
	if _skip_if_no_popup():
		return
	var toggle := _popup.get_node_or_null("%CameraShakeToggle")
	assert_that(toggle).is_not_null()
	assert_that(toggle).is_instanceof(CheckButton)


## 测试S3: Auto-Save 开关存在
func test_auto_save_toggle_exists() -> void:
	if _skip_if_no_popup():
		return
	var toggle := _popup.get_node_or_null("%AutoSaveToggle")
	assert_that(toggle).is_not_null()
	assert_that(toggle).is_instanceof(CheckButton)


## ============================================================================
## 语言控件测试
## ============================================================================

## 测试11: 语言选项存在
func test_language_option_exists() -> void:
	if _skip_if_no_popup():
		return
	var option := _popup.get_node_or_null("%LanguageOption")
	assert_that(option).is_not_null()
	assert_that(option).is_instanceof(OptionButton)


## 测试C2: 语言下拉框有 4 个选项
func test_language_has_four_options() -> void:
	if _skip_if_no_popup():
		return
	var option := _popup.get_node_or_null("%LanguageOption") as OptionButton
	assert_that(option).is_not_null()
	if option:
		assert_that(option.item_count).is_equal(4)


## ============================================================================
## 底部按钮测试
## ============================================================================

## 测试12: 保存按钮存在且文本正确
func test_save_button_exists() -> void:
	if _skip_if_no_popup():
		return
	var btn := _popup.get_node_or_null("%SaveButton")
	assert_that(btn).is_not_null()
	if btn is Button:
		assert_that(btn.text.to_upper()).contains("SAVE")


## 测试13: 取消按钮存在
func test_cancel_button_exists() -> void:
	if _skip_if_no_popup():
		return
	var btn := _popup.get_node_or_null("%CancelButton")
	assert_that(btn).is_not_null()


## 测试14: 恢复默认按钮存在
func test_restore_defaults_button_exists() -> void:
	if _skip_if_no_popup():
		return
	var btn := _popup.get_node_or_null("%RestoreDefaultsButton")
	assert_that(btn).is_not_null()


## ============================================================================
## 显示/隐藏功能测试
## ============================================================================

## 测试15: 弹窗初始为隐藏状态
func test_initial_hidden() -> void:
	if _skip_if_no_popup():
		return
	assert_bool(_popup.visible).is_false()


## 测试16: show_popup 使弹窗可见
func test_show_popup_makes_visible() -> void:
	if _skip_if_no_popup():
		return
	_popup.show_popup()
	await get_tree().process_frame
	assert_bool(_popup.visible).is_true()


## 测试17: hide_popup 使弹窗隐藏
func test_hide_popup_makes_invisible() -> void:
	if _skip_if_no_popup():
		return
	_popup.show_popup()
	await get_tree().process_frame
	_popup.hide_popup()
	await get_tree().create_timer(0.4).timeout
	assert_bool(_popup.visible).is_false()


## ============================================================================
## 设置值测试
## ============================================================================

## 测试18: 加载设置后滑块有合理值
func test_load_settings_sets_slider_values() -> void:
	if _skip_if_no_popup():
		return
	_popup.show_popup()
	await get_tree().process_frame
	var slider := _popup.get_node_or_null("%MasterVolumeSlider") as HSlider
	if slider:
		assert_that(slider.value).is_greater_equal(0.0)
		assert_that(slider.value).is_less_equal(1.0)


## 测试19: 取消按钮恢复原始值
func test_cancel_restores_original_values() -> void:
	if _skip_if_no_popup():
		return
	_popup.show_popup()
	await get_tree().process_frame

	var slider := _popup.get_node_or_null("%MasterVolumeSlider") as HSlider
	if not slider:
		return

	var original := slider.value
	slider.value = 0.1

	# 模拟取消操作
	if _popup.has_method("_on_cancel_pressed"):
		_popup._on_cancel_pressed()
	await get_tree().create_timer(0.4).timeout

	# 重新打开弹窗
	_popup.show_popup()
	await get_tree().process_frame

	# 值应该恢复
	assert_that(slider.value).is_equal_approx(original, 0.05)


## ============================================================================
## ESC 键测试
## ============================================================================

## 测试20: ESC 键关闭弹窗
func test_esc_key_closes_popup() -> void:
	if _skip_if_no_popup():
		return
	_popup.show_popup()
	await get_tree().process_frame

	# 模拟 ESC 键
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	_popup._unhandled_input(event)

	await get_tree().create_timer(0.4).timeout
	assert_bool(_popup.visible).is_false()


## ============================================================================
## 信号测试
## ============================================================================

## 测试21: 弹窗有 closed 信号
func test_popup_has_closed_signal() -> void:
	if _skip_if_no_popup():
		return
	assert_bool(_popup.has_signal("closed")).is_true()


## 测试22: 弹窗有 settings_saved 信号
func test_popup_has_settings_saved_signal() -> void:
	if _skip_if_no_popup():
		return
	assert_bool(_popup.has_signal("settings_saved")).is_true()
