## MenuButtonStyler 按钮样式工厂测试套件
## 测试范围：
## 1. PRIMARY/DEFAULT/DANGER 样式创建
## 2. 样式属性正确性
## 3. 应用到按钮节点

class_name TestMenuButtonStyler
extends GdUnitTestSuite


## ============================================================================
## 常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const GRAY_BORDER_COLOR := Color(0.267, 0.251, 0.235, 1.0)
const RED_HOVER_COLOR := Color(0.8, 0.2, 0.2, 1.0)
const COLOR_TOLERANCE := 0.05


## ============================================================================
## 辅助方法
## ============================================================================

func _colors_are_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < COLOR_TOLERANCE \
		and absf(a.g - b.g) < COLOR_TOLERANCE \
		and absf(a.b - b.b) < COLOR_TOLERANCE


## ============================================================================
## PRIMARY 样式测试
## ============================================================================

## 测试1: primary 常态样式返回有效 StyleBoxFlat，左边框为金色
func test_create_primary_normal_style() -> void:
	var style := MenuButtonStyler.create_normal_style(MenuButtonStyler.ButtonType.PRIMARY)
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)
	if style is StyleBoxFlat:
		var sbox: StyleBoxFlat = style
		assert_that(sbox.border_width_left).is_greater(2)
		assert_bool(_colors_are_close(sbox.border_color, GOLD_COLOR)).is_true()


## 测试2: primary hover 样式有效
func test_create_primary_hover_style() -> void:
	var style := MenuButtonStyler.create_hover_style(MenuButtonStyler.ButtonType.PRIMARY)
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## ============================================================================
## DEFAULT 样式测试
## ============================================================================

## 测试3: default 常态样式左边框为灰色
func test_create_default_normal_style() -> void:
	var style := MenuButtonStyler.create_normal_style(MenuButtonStyler.ButtonType.DEFAULT)
	assert_that(style).is_not_null()
	if style is StyleBoxFlat:
		var sbox: StyleBoxFlat = style
		assert_that(sbox.border_width_left).is_greater(2)
		assert_bool(_colors_are_close(sbox.border_color, GRAY_BORDER_COLOR)).is_true()


## ============================================================================
## DANGER 样式测试
## ============================================================================

## 测试4: danger 常态样式左边框为灰色
func test_create_danger_normal_style() -> void:
	var style := MenuButtonStyler.create_normal_style(MenuButtonStyler.ButtonType.DANGER)
	assert_that(style).is_not_null()
	if style is StyleBoxFlat:
		var sbox: StyleBoxFlat = style
		assert_bool(_colors_are_close(sbox.border_color, GRAY_BORDER_COLOR)).is_true()


## 测试5: danger hover 样式左边框为红色
func test_create_danger_hover_style() -> void:
	var style := MenuButtonStyler.create_hover_style(MenuButtonStyler.ButtonType.DANGER)
	assert_that(style).is_not_null()
	if style is StyleBoxFlat:
		var sbox: StyleBoxFlat = style
		assert_bool(_colors_are_close(sbox.border_color, RED_HOVER_COLOR)).is_true()


## ============================================================================
## 禁用样式测试
## ============================================================================

## 测试6: disabled 样式半透明
func test_create_disabled_style() -> void:
	var style := MenuButtonStyler.create_disabled_style()
	assert_that(style).is_not_null()
	if style is StyleBoxFlat:
		var sbox: StyleBoxFlat = style
		# 禁用样式背景应有较低透明度
		assert_that(sbox.bg_color.a).is_less(1.0)


## ============================================================================
## 应用到按钮测试
## ============================================================================

## 测试7: 样式正确应用到 Button 节点
func test_apply_to_button() -> void:
	var button := Button.new()
	add_child(button)
	MenuButtonStyler.apply_to_button(button, MenuButtonStyler.ButtonType.PRIMARY)

	var normal_style := button.get_theme_stylebox("normal")
	assert_that(normal_style).is_not_null()
	assert_that(normal_style).is_instanceof(StyleBoxFlat)

	var hover_style := button.get_theme_stylebox("hover")
	assert_that(hover_style).is_not_null()

	button.queue_free()
