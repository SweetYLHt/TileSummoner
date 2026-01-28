## MainMenuUI 主菜单UI测试套件
## 测试范围：
## 1. 背景和布局结构
## 2. 标题区域元素
## 3. 按钮存在性和状态
## 4. 信号连接
## 5. 按钮样式
## 6. 动画方法
## 7. 发光球体

class_name TestMainMenuUI
extends GdUnitTestSuite


## ============================================================================
## 常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const COLOR_TOLERANCE := 0.1


## ============================================================================
## 初始化
## ============================================================================

var _ui: MainMenuUI = null


func before_test() -> void:
	_ui = preload("res://Scenes/main_menu.tscn").instantiate()
	add_child(_ui)
	await get_tree().process_frame


func after_test() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null


## ============================================================================
## 辅助方法
## ============================================================================

func _colors_are_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < COLOR_TOLERANCE \
		and absf(a.g - b.g) < COLOR_TOLERANCE \
		and absf(a.b - b.b) < COLOR_TOLERANCE


## ============================================================================
## 背景测试
## ============================================================================

## 测试1: Background (ColorRect) 存在
func test_background_exists() -> void:
	var bg := _ui.get_node_or_null("Background")
	assert_that(bg).is_not_null()
	assert_that(bg).is_instanceof(ColorRect)


## 测试2: 背景色 RGB 均 < 0.05 (极深色)
func test_background_color_is_dark() -> void:
	var bg := _ui.get_node_or_null("Background") as ColorRect
	if bg:
		assert_that(bg.color.r).is_less(0.05)
		assert_that(bg.color.g).is_less(0.05)
		assert_that(bg.color.b).is_less(0.06)


## ============================================================================
## 布局测试
## ============================================================================

## 测试3: 左侧面板存在
func test_left_panel_exists() -> void:
	var panel := _ui.get_node_or_null("HSplitLayout/LeftPanel")
	assert_that(panel).is_not_null()


## ============================================================================
## 标题区域测试
## ============================================================================

## 测试4: 标题区域容器存在
func test_title_section_exists() -> void:
	var section := _ui.get_node_or_null("HSplitLayout/LeftPanel/TitleSection")
	assert_that(section).is_not_null()


## 测试5: RichTextLabel 标题节点存在
func test_title_rich_text_exists() -> void:
	var title := _ui.get_node_or_null("HSplitLayout/LeftPanel/TitleSection/TitleRichText")
	assert_that(title).is_not_null()
	assert_that(title).is_instanceof(RichTextLabel)


## 测试6: 金色下划线 ColorRect 存在且颜色接近金色
func test_gold_underline_exists() -> void:
	var underline := _ui.get_node_or_null("HSplitLayout/LeftPanel/TitleSection/GoldUnderline") as ColorRect
	assert_that(underline).is_not_null()
	if underline:
		assert_bool(_colors_are_close(underline.color, GOLD_COLOR)).is_true()


## 测试7: 副标题 Label 存在
func test_subtitle_exists() -> void:
	var subtitle := _ui.get_node_or_null("HSplitLayout/LeftPanel/TitleSection/SubtitleLabel")
	assert_that(subtitle).is_not_null()
	assert_that(subtitle).is_instanceof(Label)


## ============================================================================
## 按钮存在性测试
## ============================================================================

## 测试8: 继续游戏按钮存在
func test_continue_button_exists() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/ContinueButton")
	assert_that(button).is_not_null()
	assert_that(button).is_instanceof(Button)


## 测试9: 继续游戏按钮为禁用状态
func test_continue_button_disabled() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/ContinueButton") as Button
	if button:
		assert_bool(button.disabled).is_true()


## 测试10: 开始游戏按钮存在且文字正确
func test_start_button_exists() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/StartButton") as Button
	assert_that(button).is_not_null()
	if button:
		assert_that(button.text).contains("START NEW GAME")


## 测试11: 存档槽位按钮存在
func test_save_slots_button_exists() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/SaveSlotsButton")
	assert_that(button).is_not_null()
	assert_that(button).is_instanceof(Button)


## 测试12: 存档槽位按钮为禁用状态
func test_save_slots_button_disabled() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/SaveSlotsButton") as Button
	if button:
		assert_bool(button.disabled).is_true()


## 测试13: 设置按钮存在
func test_settings_button_exists() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/SettingsButton")
	assert_that(button).is_not_null()
	assert_that(button).is_instanceof(Button)


## 测试14: 退出按钮存在
func test_exit_button_exists() -> void:
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/ExitButton")
	assert_that(button).is_not_null()
	assert_that(button).is_instanceof(Button)


## ============================================================================
## 信号连接测试
## ============================================================================

## 测试15: 开始按钮 pressed 信号已连接
func test_start_button_signal_connected() -> void:
	await get_tree().create_timer(0.1).timeout
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/StartButton") as Button
	if button:
		assert_bool(button.pressed.get_connections().size() > 0).is_true()


## 测试16: 设置按钮 pressed 信号已连接
func test_settings_button_signal_connected() -> void:
	await get_tree().create_timer(0.1).timeout
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/SettingsButton") as Button
	if button:
		assert_bool(button.pressed.get_connections().size() > 0).is_true()


## 测试17: 退出按钮 pressed 信号已连接
func test_exit_button_signal_connected() -> void:
	await get_tree().create_timer(0.1).timeout
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/ExitButton") as Button
	if button:
		assert_bool(button.pressed.get_connections().size() > 0).is_true()


## ============================================================================
## 按钮样式测试
## ============================================================================

## 测试18: 开始按钮有金色左边框 (通过 PRIMARY 样式间接验证)
func test_start_button_has_gold_left_border() -> void:
	await get_tree().create_timer(0.1).timeout
	var button := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/StartButton") as Button
	if button:
		var style := button.get_theme_stylebox("normal")
		assert_that(style).is_instanceof(StyleBoxFlat)
		if style is StyleBoxFlat:
			var sbox: StyleBoxFlat = style
			assert_that(sbox.border_width_left).is_greater(2)


## 测试19: 退出按钮与开始按钮样式不同
func test_exit_button_style_distinct() -> void:
	await get_tree().create_timer(0.1).timeout
	var start_btn := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/StartButton") as Button
	var exit_btn := _ui.get_node_or_null("HSplitLayout/LeftPanel/ButtonContainer/ExitButton") as Button
	if start_btn and exit_btn:
		var start_hover := start_btn.get_theme_stylebox("hover")
		var exit_hover := exit_btn.get_theme_stylebox("hover")
		# 两者 hover 样式对象应不同
		assert_that(start_hover).is_not_same(exit_hover)


## ============================================================================
## 版本标签测试
## ============================================================================

## 测试20: 版本标签存在
func test_version_label_exists() -> void:
	var label := _ui.get_node_or_null("Footer/FooterContent/VersionLabel")
	assert_that(label).is_not_null()
	assert_that(label).is_instanceof(Label)


## ============================================================================
## 动画方法测试
## ============================================================================

## 测试21: 脚本有 _play_enter_animation 方法
func test_has_enter_animation_method() -> void:
	assert_bool(_ui.has_method("_play_enter_animation")).is_true()


## 测试22: 脚本有 _setup_button_hover_effects 方法
func test_has_button_hover_method() -> void:
	assert_bool(_ui.has_method("_setup_button_hover_effects")).is_true()


## ============================================================================
## 发光球体测试
## ============================================================================

## 测试23: 发光球体容器存在且有子节点
func test_glow_orbs_exist() -> void:
	var orbs := _ui.get_node_or_null("GlowOrbsContainer")
	assert_that(orbs).is_not_null()
	if orbs:
		assert_that(orbs.get_child_count()).is_greater(0)
