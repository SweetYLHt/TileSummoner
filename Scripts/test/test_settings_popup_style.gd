## SettingsPopupStyle 样式工厂测试套件
## 测试范围：
## 1. 玻璃面板样式创建
## 2. 滑块样式创建
## 3. 按钮样式创建
## 4. 切换开关样式创建
## 5. 选项按钮样式创建
## 6. Footer 面板样式创建
## 7. 纯文字按钮样式创建

class_name TestSettingsPopupStyle
extends GdUnitTestSuite


## ============================================================================
## 依赖
## ============================================================================

const SettingsPopupStyle := preload("res://Scripts/ui/settings_popup/settings_popup_style.gd")


## ============================================================================
## 常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const GLASS_BG := Color(0.051, 0.059, 0.078, 0.92)
const COLOR_TOLERANCE := 0.05


## ============================================================================
## 辅助方法
## ============================================================================

func _colors_are_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < COLOR_TOLERANCE \
		and absf(a.g - b.g) < COLOR_TOLERANCE \
		and absf(a.b - b.b) < COLOR_TOLERANCE


## ============================================================================
## 玻璃面板样式测试
## ============================================================================

## 测试1: 玻璃面板样式返回有效 StyleBoxFlat
func test_create_glass_panel_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_glass_panel_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试2: 玻璃面板背景透明度为 0.92
func test_glass_panel_bg_alpha() -> void:
	var style := SettingsPopupStyle.create_glass_panel_style() as StyleBoxFlat
	assert_that(style.bg_color.a).is_equal_approx(0.92, 0.01)


## 测试3: 玻璃面板左侧直角，右侧圆角
func test_glass_panel_corner_radius() -> void:
	var style := SettingsPopupStyle.create_glass_panel_style() as StyleBoxFlat
	assert_that(style.corner_radius_top_right).is_greater(0)
	assert_that(style.corner_radius_bottom_right).is_greater(0)
	assert_that(style.corner_radius_top_left).is_equal(0)
	assert_that(style.corner_radius_bottom_left).is_equal(0)


## ============================================================================
## 滑块样式测试
## ============================================================================

## 测试4: 滑块抓取器纹理返回有效 ImageTexture
func test_create_slider_grabber_texture_returns_image_texture() -> void:
	var texture := SettingsPopupStyle.create_slider_grabber_texture()
	assert_that(texture).is_not_null()
	assert_that(texture).is_instanceof(ImageTexture)


## 测试5: 滑块抓取器纹理尺寸正确 (20x32)
func test_slider_grabber_texture_size() -> void:
	var texture := SettingsPopupStyle.create_slider_grabber_texture() as ImageTexture
	assert_that(texture.get_width()).is_equal(20)
	assert_that(texture.get_height()).is_equal(32)


## 测试6: 滑块轨道样式有效
func test_create_slider_track_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_slider_track_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试7: 滑块填充样式有效
func test_create_slider_fill_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_slider_fill_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试Y6: 滑块抓取器纹理高度大于宽度（竖条形状）
func test_slider_grabber_texture_is_vertical() -> void:
	var texture := SettingsPopupStyle.create_slider_grabber_texture() as ImageTexture
	assert_that(texture.get_height()).is_greater(texture.get_width())


## 测试Y7: 滑块轨道无圆角
func test_slider_track_no_rounded() -> void:
	var style := SettingsPopupStyle.create_slider_track_style() as StyleBoxFlat
	assert_that(style.corner_radius_top_left).is_equal(0)
	assert_that(style.corner_radius_top_right).is_equal(0)
	assert_that(style.corner_radius_bottom_left).is_equal(0)
	assert_that(style.corner_radius_bottom_right).is_equal(0)


## 测试Y7b: 滑块轨道设置了 expand_margin (Godot Slider 渲染必需)
func test_slider_track_has_expand_margin() -> void:
	var style := SettingsPopupStyle.create_slider_track_style() as StyleBoxFlat
	assert_that(style.expand_margin_top).is_greater(0.0)
	assert_that(style.expand_margin_bottom).is_greater(0.0)


## 测试Y7c: 滑块填充区域设置了 expand_margin (与轨道一致)
func test_slider_fill_has_expand_margin() -> void:
	var style := SettingsPopupStyle.create_slider_fill_style() as StyleBoxFlat
	assert_that(style.expand_margin_top).is_greater(0.0)
	assert_that(style.expand_margin_bottom).is_greater(0.0)


## 测试Y8: apply_slider_style 设置 grabber icon override
func test_apply_slider_style_sets_grabber_icon() -> void:
	var slider := HSlider.new()
	SettingsPopupStyle.apply_slider_style(slider)
	var grabber_icon := slider.get_theme_icon("grabber")
	assert_that(grabber_icon).is_not_null()
	assert_that(grabber_icon).is_instanceof(ImageTexture)
	slider.free()


## 测试Y9: apply_slider_style 设置 grabber_highlight icon override
func test_apply_slider_style_sets_grabber_highlight_icon() -> void:
	var slider := HSlider.new()
	SettingsPopupStyle.apply_slider_style(slider)
	var highlight_icon := slider.get_theme_icon("grabber_highlight")
	assert_that(highlight_icon).is_not_null()
	assert_that(highlight_icon).is_instanceof(ImageTexture)
	slider.free()


## ============================================================================
## 按钮样式测试
## ============================================================================

## 测试8: 主按钮样式有效
func test_create_primary_button_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_primary_button_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试9: 主按钮背景为金色
func test_primary_button_gold_background() -> void:
	var style := SettingsPopupStyle.create_primary_button_style() as StyleBoxFlat
	assert_that(style.bg_color.r).is_greater(0.8)


## 测试10: 次要按钮样式有效
func test_create_secondary_button_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_secondary_button_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试11: 次要按钮有边框
func test_secondary_button_has_border() -> void:
	var style := SettingsPopupStyle.create_secondary_button_style() as StyleBoxFlat
	var has_border := style.border_width_left > 0 or style.border_width_right > 0 \
		or style.border_width_top > 0 or style.border_width_bottom > 0
	assert_bool(has_border).is_true()


## ============================================================================
## 切换开关样式测试
## ============================================================================

## 测试12: 切换开关开启样式有效
func test_create_toggle_on_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_toggle_on_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试13: 切换开关关闭样式有效
func test_create_toggle_off_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_toggle_off_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## ============================================================================
## 选项按钮样式测试
## ============================================================================

## 测试14: 选项按钮样式有效
func test_create_option_button_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_option_button_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## ============================================================================
## 分隔线样式测试
## ============================================================================

## 测试15: 分隔线颜色方法返回有效颜色
func test_get_separator_color_returns_color() -> void:
	var color := SettingsPopupStyle.get_separator_color()
	assert_that(color).is_not_null()
	assert_that(color.a).is_greater(0.0)


## ============================================================================
## Footer 面板样式测试
## ============================================================================

## 测试16: Footer 面板样式返回有效 StyleBoxFlat
func test_create_footer_panel_style_returns_stylebox() -> void:
	var style := SettingsPopupStyle.create_footer_panel_style()
	assert_that(style).is_not_null()
	assert_that(style).is_instanceof(StyleBoxFlat)


## 测试17: Footer 面板背景半透明（alpha 约 0.4）
func test_footer_panel_bg_transparency() -> void:
	var style := SettingsPopupStyle.create_footer_panel_style() as StyleBoxFlat
	assert_that(style.bg_color.a).is_equal_approx(0.4, 0.1)


## ============================================================================
## 纯文字按钮样式测试
## ============================================================================

## 测试18: 纯文字按钮无边框、透明背景
func test_text_button_no_border() -> void:
	var style := SettingsPopupStyle.create_text_button_style()
	assert_that(style).is_not_null()
	if style is StyleBoxFlat:
		var flat := style as StyleBoxFlat
		assert_that(flat.bg_color.a).is_equal_approx(0.0, 0.01)
		assert_that(flat.border_width_left).is_equal(0)
		assert_that(flat.border_width_right).is_equal(0)
		assert_that(flat.border_width_top).is_equal(0)
		assert_that(flat.border_width_bottom).is_equal(0)
