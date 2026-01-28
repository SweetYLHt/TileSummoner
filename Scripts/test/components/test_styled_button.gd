## StyledButton 组件单元测试
extends GdUnitTestSuite


const StyledButton := preload("res://Scripts/ui/components/styled_button.gd")
const UIThemeConstants := preload("res://Scripts/ui/components/ui_theme_constants.gd")


var _button: Button


func before_test() -> void:
	_button = auto_free(Button.new())
	add_child(_button)


func after_test() -> void:
	_button = null


## ============================================================================
## 枚举测试
## ============================================================================

func test_button_type_enum_values() -> void:
	assert_int(StyledButton.ButtonType.PRIMARY).is_equal(0)
	assert_int(StyledButton.ButtonType.DEFAULT).is_equal(1)
	assert_int(StyledButton.ButtonType.SECONDARY).is_equal(2)
	assert_int(StyledButton.ButtonType.DANGER).is_equal(3)
	assert_int(StyledButton.ButtonType.TEXT).is_equal(4)
	assert_int(StyledButton.ButtonType.FILLED).is_equal(5)


## ============================================================================
## 样式创建测试
## ============================================================================

func test_create_normal_style_primary() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.PRIMARY)

	assert_object(style).is_not_null()
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_color(style.border_color).is_equal(UIThemeConstants.GOLD)
	assert_color(style.bg_color).is_equal(UIThemeConstants.BG_DARK)


func test_create_normal_style_default() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.DEFAULT)

	assert_color(style.border_color).is_equal(UIThemeConstants.BORDER_GRAY)


func test_create_normal_style_secondary() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.SECONDARY)

	# SECONDARY 透明背景
	assert_float(style.bg_color.a).is_equal_approx(0.0, 0.01)
	assert_color(style.border_color).is_equal(UIThemeConstants.BORDER_LIGHT)


func test_create_normal_style_danger() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.DANGER)

	assert_color(style.border_color).is_equal(UIThemeConstants.BORDER_GRAY)


func test_create_normal_style_text() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.TEXT)

	# TEXT 无边框
	assert_int(style.border_width_left).is_equal(0)
	assert_int(style.border_width_right).is_equal(0)


func test_create_hover_style_primary() -> void:
	var style := StyledButton.create_hover_style(StyledButton.ButtonType.PRIMARY)

	assert_color(style.border_color).is_equal(UIThemeConstants.GOLD_BRIGHT)
	assert_color(style.bg_color).is_equal(UIThemeConstants.BG_HOVER)


func test_create_hover_style_danger() -> void:
	var style := StyledButton.create_hover_style(StyledButton.ButtonType.DANGER)

	assert_color(style.border_color).is_equal(UIThemeConstants.RED_HOVER)
	assert_color(style.bg_color).is_equal(UIThemeConstants.BG_HOVER_RED)


func test_create_pressed_style_darkened() -> void:
	var hover_style := StyledButton.create_hover_style(StyledButton.ButtonType.PRIMARY)
	var pressed_style := StyledButton.create_pressed_style(StyledButton.ButtonType.PRIMARY)

	# 按下时背景应比 hover 更暗
	assert_float(pressed_style.bg_color.v).is_less(hover_style.bg_color.v)


func test_create_disabled_style() -> void:
	var style := StyledButton.create_disabled_style()

	assert_object(style).is_not_null()
	# 禁用时透明度较低
	assert_float(style.bg_color.a).is_less(1.0)


## ============================================================================
## 应用样式测试
## ============================================================================

func test_apply_to_button_null_check() -> void:
	# 不应崩溃
	StyledButton.apply_to_button(null, StyledButton.ButtonType.PRIMARY)


func test_apply_to_button_primary() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.PRIMARY)

	var normal_style := _button.get_theme_stylebox("normal")
	assert_object(normal_style).is_not_null()

	# 检查字体颜色
	var font_color := _button.get_theme_color("font_color")
	assert_color(font_color).is_equal(UIThemeConstants.TEXT_WHITE)


func test_apply_to_button_danger_text_color() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.DANGER)

	var hover_color := _button.get_theme_color("font_hover_color")
	assert_color(hover_color).is_equal(UIThemeConstants.RED_TEXT)


func test_apply_to_button_sets_font_size() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.DEFAULT)

	var font_size := _button.get_theme_font_size("font_size")
	assert_int(font_size).is_equal(UIThemeConstants.FONT_SIZE_DEFAULT)


## ============================================================================
## 按钮对齐测试
## ============================================================================

func test_primary_button_left_aligned() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.PRIMARY)

	# PRIMARY/DEFAULT/DANGER 左对齐
	assert_int(_button.alignment).is_equal(HORIZONTAL_ALIGNMENT_LEFT)


func test_secondary_button_center_aligned() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.SECONDARY)

	# SECONDARY/TEXT 居中
	assert_int(_button.alignment).is_equal(HORIZONTAL_ALIGNMENT_CENTER)


func test_text_button_center_aligned() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.TEXT)

	assert_int(_button.alignment).is_equal(HORIZONTAL_ALIGNMENT_CENTER)


## ============================================================================
## 边框样式测试
## ============================================================================

func test_primary_has_left_accent_border() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.PRIMARY)

	# 左边框加粗
	assert_int(style.border_width_left).is_equal(UIThemeConstants.BORDER_WIDTH_LEFT_ACCENT)
	assert_int(style.border_width_right).is_equal(UIThemeConstants.BORDER_WIDTH)


func test_secondary_has_uniform_border() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.SECONDARY)

	# 四边统一边框
	assert_int(style.border_width_left).is_equal(UIThemeConstants.BORDER_WIDTH)
	assert_int(style.border_width_right).is_equal(UIThemeConstants.BORDER_WIDTH)
	assert_int(style.border_width_top).is_equal(UIThemeConstants.BORDER_WIDTH)
	assert_int(style.border_width_bottom).is_equal(UIThemeConstants.BORDER_WIDTH)


## ============================================================================
## 圆角测试
## ============================================================================

func test_primary_right_rounded() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.PRIMARY)

	# 右侧圆角，左侧直角
	assert_int(style.corner_radius_top_left).is_equal(0)
	assert_int(style.corner_radius_bottom_left).is_equal(0)
	assert_int(style.corner_radius_top_right).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)
	assert_int(style.corner_radius_bottom_right).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)


func test_secondary_all_rounded() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.SECONDARY)

	# 四角都有圆角
	assert_int(style.corner_radius_top_left).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)
	assert_int(style.corner_radius_top_right).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)


## ============================================================================
## FILLED 类型测试
## ============================================================================

func test_create_normal_style_filled() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.FILLED)

	# FILLED 金色填充背景
	assert_object(style).is_not_null()
	assert_color(style.bg_color).is_equal(UIThemeConstants.GOLD)


func test_filled_button_no_border() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.FILLED)

	# 无边框
	assert_int(style.border_width_left).is_equal(0)
	assert_int(style.border_width_right).is_equal(0)
	assert_int(style.border_width_top).is_equal(0)
	assert_int(style.border_width_bottom).is_equal(0)


func test_filled_button_all_rounded() -> void:
	var style := StyledButton.create_normal_style(StyledButton.ButtonType.FILLED)

	# 四角圆角
	assert_int(style.corner_radius_top_left).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)
	assert_int(style.corner_radius_top_right).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)
	assert_int(style.corner_radius_bottom_left).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)
	assert_int(style.corner_radius_bottom_right).is_equal(UIThemeConstants.CORNER_RADIUS_SMALL)


func test_filled_button_center_aligned() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.FILLED)

	# FILLED 居中
	assert_int(_button.alignment).is_equal(HORIZONTAL_ALIGNMENT_CENTER)


func test_filled_button_dark_text() -> void:
	StyledButton.apply_to_button(_button, StyledButton.ButtonType.FILLED)

	# 深色文字
	var font_color := _button.get_theme_color("font_color")
	assert_color(font_color).is_equal(UIThemeConstants.TEXT_DARK)


func test_create_hover_style_filled() -> void:
	var style := StyledButton.create_hover_style(StyledButton.ButtonType.FILLED)

	# FILLED hover 更亮的金色
	assert_color(style.bg_color).is_equal(UIThemeConstants.GOLD_BRIGHT)
