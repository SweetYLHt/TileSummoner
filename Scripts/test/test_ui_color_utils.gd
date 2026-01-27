## _UIColorUtils 颜色工具类测试套件
## 测试范围：
## 1. calculate_bg_color 背景色计算
## 2. calculate_icon_border_color 边框色计算
## 3. calculate_glow_color 发光色计算
## 4. calculate_hover_brighten_color hover变亮计算

class_name Test_UIColorUtils
extends GdUnitTestSuite

## 预加载工具类
const _UIColorUtils := preload("res://Scripts/utils/ui_color_utils.gd")


## ============================================================================
## 背景色计算测试
## ============================================================================

## 测试1：验证草地背景色计算
func test_calculate_bg_color_grassland() -> void:
	# 草地主色：#10b981 = (0.06, 0.73, 0.51)
	var main_color := Color(0.06, 0.73, 0.51, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color)

	# 验证亮度降低到 30%
	assert_that(bg_color.r).is_equal_approx(main_color.r * 0.3, 0.01)
	assert_that(bg_color.g).is_equal_approx(main_color.g * 0.3, 0.01)
	assert_that(bg_color.b).is_equal_approx(main_color.b * 0.3, 0.01)


## 测试2：验证水域背景色计算
func test_calculate_bg_color_water() -> void:
	# 水域主色：#3b82f6 = (0.23, 0.51, 0.96)
	var main_color := Color(0.23, 0.51, 0.96, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color)

	# 验证亮度降低到 30%
	assert_that(bg_color.r).is_equal_approx(main_color.r * 0.3, 0.01)
	assert_that(bg_color.g).is_equal_approx(main_color.g * 0.3, 0.01)
	assert_that(bg_color.b).is_equal_approx(main_color.b * 0.3, 0.01)


## 测试3：验证背景色透明度为 0.3
func test_calculate_bg_color_transparency() -> void:
	var main_color := Color(1.0, 0.5, 0.25, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color)

	# 验证透明度为 0.3
	assert_that(bg_color.a).is_equal_approx(0.3, 0.01)


## 测试4：验证背景色亮度降低到 30%
func test_calculate_bg_color_brightness() -> void:
	var main_color := Color(1.0, 1.0, 1.0, 1.0)  # 纯白色
	var bg_color := _UIColorUtils.calculate_bg_color(main_color)

	# 验证所有通道都降低到 30%
	assert_that(bg_color.r).is_equal_approx(0.3, 0.01)
	assert_that(bg_color.g).is_equal_approx(0.3, 0.01)
	assert_that(bg_color.b).is_equal_approx(0.3, 0.01)


## 测试5：验证自定义亮度参数
func test_calculate_bg_color_custom_brightness() -> void:
	var main_color := Color(1.0, 0.5, 0.0, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color, 0.5, 0.3)

	# 验证使用自定义亮度 50%
	assert_that(bg_color.r).is_equal_approx(0.5, 0.01)
	assert_that(bg_color.g).is_equal_approx(0.25, 0.01)


## 测试6：验证自定义透明度参数
func test_calculate_bg_color_custom_alpha() -> void:
	var main_color := Color(0.5, 0.5, 0.5, 1.0)
	var bg_color := _UIColorUtils.calculate_bg_color(main_color, 0.3, 0.6)

	# 验证使用自定义透明度 60%
	assert_that(bg_color.a).is_equal_approx(0.6, 0.01)


## ============================================================================
## 边框色计算测试
## ============================================================================

## 测试7：验证边框色计算
func test_calculate_icon_border_color() -> void:
	var main_color := Color(1.0, 0.5, 0.25, 1.0)
	var border_color := _UIColorUtils.calculate_icon_border_color(main_color)

	# 验证亮度降低到 50%
	assert_that(border_color.r).is_equal_approx(0.5, 0.01)
	assert_that(border_color.g).is_equal_approx(0.25, 0.01)
	assert_that(border_color.b).is_equal_approx(0.125, 0.01)
	# 默认透明度 0.5
	assert_that(border_color.a).is_equal_approx(0.5, 0.01)


## 测试8：验证边框色自定义透明度
func test_calculate_icon_border_color_custom_alpha() -> void:
	var main_color := Color(0.8, 0.4, 0.2, 1.0)
	var border_color := _UIColorUtils.calculate_icon_border_color(main_color, 0.8)

	# 验证自定义透明度 80%
	assert_that(border_color.a).is_equal_approx(0.8, 0.01)


## ============================================================================
## 发光色计算测试
## ============================================================================

## 测试9：验证发光色保留原色
func test_calculate_glow_color_preserves_rgb() -> void:
	var main_color := Color(0.87, 0.7, 0.16, 1.0)
	var glow_color := _UIColorUtils.calculate_glow_color(main_color)

	# 验证 RGB 不变
	assert_that(glow_color.r).is_equal_approx(main_color.r, 0.01)
	assert_that(glow_color.g).is_equal_approx(main_color.g, 0.01)
	assert_that(glow_color.b).is_equal_approx(main_color.b, 0.01)


## 测试10：验证发光色默认强度
func test_calculate_glow_color_default_intensity() -> void:
	var main_color := Color(0.5, 0.5, 0.5, 1.0)
	var glow_color := _UIColorUtils.calculate_glow_color(main_color)

	# 验证默认强度 0.5
	assert_that(glow_color.a).is_equal_approx(0.5, 0.01)


## 测试11：验证发光色自定义强度
func test_calculate_glow_color_custom_intensity() -> void:
	var main_color := Color(0.5, 0.5, 0.5, 1.0)
	var glow_color := _UIColorUtils.calculate_glow_color(main_color, 0.8)

	# 验证自定义强度 0.8
	assert_that(glow_color.a).is_equal_approx(0.8, 0.01)


## ============================================================================
## Hover 变亮色计算测试
## ============================================================================

## 测试12：验证 hover 变亮效果
func test_calculate_hover_brighten_color() -> void:
	var base_color := Color(0.5, 0.4, 0.3, 1.0)
	var hover_color := _UIColorUtils.calculate_hover_brighten_color(base_color)

	# 验证变亮 0.1
	assert_that(hover_color.r).is_equal_approx(0.6, 0.01)
	assert_that(hover_color.g).is_equal_approx(0.5, 0.01)
	assert_that(hover_color.b).is_equal_approx(0.4, 0.01)


## 测试13：验证 hover 变亮不超过 1.0
func test_calculate_hover_brighten_color_clamps() -> void:
	var base_color := Color(0.95, 0.98, 1.0, 1.0)
	var hover_color := _UIColorUtils.calculate_hover_brighten_color(base_color)

	# 验证不超过 1.0
	assert_that(hover_color.r).is_equal(1.0)
	assert_that(hover_color.g).is_equal(1.0)
	assert_that(hover_color.b).is_equal(1.0)


## 测试14：验证 hover 变亮保留透明度
func test_calculate_hover_brighten_color_preserves_alpha() -> void:
	var base_color := Color(0.5, 0.5, 0.5, 0.7)
	var hover_color := _UIColorUtils.calculate_hover_brighten_color(base_color)

	# 验证透明度不变
	assert_that(hover_color.a).is_equal_approx(0.7, 0.01)


## ============================================================================
## StyleBox 创建测试
## ============================================================================

## 测试15：验证地形样式创建
func test_create_terrain_stylebox() -> void:
	var main_color := Color(0.06, 0.73, 0.51, 1.0)
	var style := _UIColorUtils.create_terrain_stylebox(main_color)

	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)

	# 验证背景色计算正确
	var expected_bg := _UIColorUtils.calculate_bg_color(main_color)
	assert_that(style.bg_color.r).is_equal_approx(expected_bg.r, 0.01)


## 测试16：验证地形样式发光效果
func test_create_terrain_stylebox_with_glow() -> void:
	var main_color := Color(0.87, 0.7, 0.16, 1.0)
	var style := _UIColorUtils.create_terrain_stylebox(main_color, true, 10)

	assert_that(style.shadow_size).is_equal(10)
	assert_that(style.shadow_color.a).is_greater(0.0)
