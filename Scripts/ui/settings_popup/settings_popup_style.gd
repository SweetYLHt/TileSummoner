## 设置弹窗样式工厂
##
## 为玻璃拟态设置弹窗创建各种 StyleBoxFlat 样式
## 基于 HTML 设计规范实现
extends RefCounted
class_name SettingsPopupStyle


## ============================================================================
## 颜色常量
## ============================================================================

## 玻璃背景色 rgba(13, 15, 20, 0.92)
const GLASS_BG := Color(0.051, 0.059, 0.078, 0.92)

## 金色主题色 #dfb22a
const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)
const GOLD_BRIGHT := Color(0.94, 0.78, 0.23, 1.0)
const GOLD_DARK := Color(0.7, 0.56, 0.13, 1.0)

## 背景和边框色
const BG_DARK := Color(0.04, 0.047, 0.059, 1.0)
const BG_HOVER := Color(0.08, 0.09, 0.11, 1.0)
const BORDER_SUBTLE := Color(0.2, 0.22, 0.25, 1.0)
const BORDER_LIGHT := Color(0.3, 0.32, 0.35, 1.0)

## 滑块颜色
const SLIDER_TRACK_BG := Color(0.16, 0.18, 0.2, 1.0)
const SLIDER_FILL := Color(0.87, 0.7, 0.16, 0.8)
const SLIDER_GRABBER_GLOW := Color(0.87, 0.7, 0.16, 0.8)

## 切换开关颜色
const TOGGLE_ON_BG := Color(0.87, 0.7, 0.16, 1.0)
const TOGGLE_OFF_BG := Color(0.2, 0.22, 0.25, 1.0)

## 分隔线颜色
const SEPARATOR_COLOR := Color(0.25, 0.27, 0.3, 0.5)

## Footer 面板背景色
const FOOTER_BG := Color(0.0, 0.0, 0.0, 0.4)

## 文字颜色
const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_GRAY := Color(0.7, 0.7, 0.7, 1.0)
const TEXT_DARK := Color(0.1, 0.1, 0.1, 1.0)
const TEXT_STONE_400 := Color(0.66, 0.64, 0.6, 1.0)


## ============================================================================
## 尺寸常量
## ============================================================================

const CORNER_RADIUS := 12
const CORNER_RADIUS_SMALL := 6
const CORNER_RADIUS_TINY := 4

const CONTENT_MARGIN := 24
const CONTENT_MARGIN_SMALL := 12
const CONTENT_MARGIN_TINY := 8

const GRABBER_WIDTH := 12
const GRABBER_HEIGHT := 24
const GRABBER_GLOW_PADDING := 4

## 轨道扩展边距 (Godot Slider StyleBoxFlat 需要 expand_margin 才能显示轨道)
const SLIDER_TRACK_EXPAND := 3


## ============================================================================
## 玻璃面板样式
## ============================================================================

## 创建玻璃面板样式 (主容器)
static func create_glass_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = GLASS_BG

	# 右侧圆角，左侧直角（与金色边框配合）
	style.corner_radius_top_left = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_top_right = CORNER_RADIUS
	style.corner_radius_bottom_right = CORNER_RADIUS

	# 细微边框
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_width_left = 0
	style.border_color = BORDER_SUBTLE

	return style


## ============================================================================
## 滑块样式
## ============================================================================

## 创建滑块抓取器纹理 (金色矩形 + 发光边缘)
static func create_slider_grabber_texture() -> ImageTexture:
	return _create_grabber_texture(GOLD_COLOR, SLIDER_GRABBER_GLOW)


## 创建滑块抓取器高亮纹理
static func create_slider_grabber_highlight_texture() -> ImageTexture:
	return _create_grabber_texture(GOLD_BRIGHT, SLIDER_GRABBER_GLOW)


## 生成带发光的矩形抓取器纹理
static func _create_grabber_texture(core_color: Color, glow_color: Color) -> ImageTexture:
	var total_w := GRABBER_WIDTH + GRABBER_GLOW_PADDING * 2  # 20
	var total_h := GRABBER_HEIGHT + GRABBER_GLOW_PADDING * 2  # 32
	var img := Image.create(total_w, total_h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# 外层：半透明金色发光层 (整个纹理区域)
	_fill_rect_on_image(img, 0, 0, total_w, total_h, glow_color)

	# 内层：不透明金色核心矩形
	_fill_rect_on_image(img, GRABBER_GLOW_PADDING, GRABBER_GLOW_PADDING,
		GRABBER_WIDTH, GRABBER_HEIGHT, core_color)

	var texture := ImageTexture.create_from_image(img)
	return texture


## 在 Image 上填充矩形区域
static func _fill_rect_on_image(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py in range(y, y + h):
		for px in range(x, x + w):
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)


## 创建滑块轨道样式 (无圆角, bg-stone-800)
static func create_slider_track_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = SLIDER_TRACK_BG

	# 无圆角 (rounded-none)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# Godot Slider 的 StyleBoxFlat 需要 expand_margin 才能渲染轨道高度
	style.expand_margin_top = SLIDER_TRACK_EXPAND
	style.expand_margin_bottom = SLIDER_TRACK_EXPAND

	return style


## 创建滑块填充样式 (无圆角)
static func create_slider_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = SLIDER_FILL

	# 无圆角 (与轨道一致)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# 与轨道一致的 expand_margin
	style.expand_margin_top = SLIDER_TRACK_EXPAND
	style.expand_margin_bottom = SLIDER_TRACK_EXPAND

	return style


## ============================================================================
## 按钮样式
## ============================================================================

## 创建主按钮样式 (Save Changes)
static func create_primary_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = GOLD_COLOR

	style.corner_radius_top_left = CORNER_RADIUS_SMALL
	style.corner_radius_top_right = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_left = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = CORNER_RADIUS_SMALL

	style.content_margin_left = CONTENT_MARGIN
	style.content_margin_right = CONTENT_MARGIN
	style.content_margin_top = CONTENT_MARGIN_SMALL
	style.content_margin_bottom = CONTENT_MARGIN_SMALL

	return style


## 创建主按钮 hover 样式
static func create_primary_button_hover_style() -> StyleBoxFlat:
	var style := create_primary_button_style()
	style.bg_color = GOLD_BRIGHT
	return style


## 创建主按钮 pressed 样式
static func create_primary_button_pressed_style() -> StyleBoxFlat:
	var style := create_primary_button_style()
	style.bg_color = GOLD_DARK
	return style


## 创建次要按钮样式 (Cancel)
static func create_secondary_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)  # 透明背景

	style.corner_radius_top_left = CORNER_RADIUS_SMALL
	style.corner_radius_top_right = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_left = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = CORNER_RADIUS_SMALL

	# 边框
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = BORDER_LIGHT

	style.content_margin_left = CONTENT_MARGIN
	style.content_margin_right = CONTENT_MARGIN
	style.content_margin_top = CONTENT_MARGIN_SMALL
	style.content_margin_bottom = CONTENT_MARGIN_SMALL

	return style


## 创建次要按钮 hover 样式
static func create_secondary_button_hover_style() -> StyleBoxFlat:
	var style := create_secondary_button_style()
	style.bg_color = BG_HOVER
	style.border_color = TEXT_WHITE
	return style


## 创建次要按钮 pressed 样式
static func create_secondary_button_pressed_style() -> StyleBoxFlat:
	var style := create_secondary_button_style()
	style.bg_color = BG_DARK
	return style


## 创建纯文字按钮样式 (Restore Defaults - 无边框)
static func create_text_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)

	# 无边框
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0

	style.content_margin_left = CONTENT_MARGIN_SMALL
	style.content_margin_right = CONTENT_MARGIN_SMALL
	style.content_margin_top = CONTENT_MARGIN_TINY
	style.content_margin_bottom = CONTENT_MARGIN_TINY

	return style


## 创建纯文字按钮 hover 样式
static func create_text_button_hover_style() -> StyleBoxFlat:
	var style := create_text_button_style()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.05)
	return style


## ============================================================================
## Footer 面板样式
## ============================================================================

## 创建底部栏面板样式
static func create_footer_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = FOOTER_BG

	# 无圆角
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# 顶部 1px 边框
	style.border_width_top = 1
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.border_color = BORDER_SUBTLE

	style.content_margin_left = CONTENT_MARGIN
	style.content_margin_right = CONTENT_MARGIN
	style.content_margin_top = CONTENT_MARGIN_SMALL
	style.content_margin_bottom = CONTENT_MARGIN_SMALL

	return style


## ============================================================================
## 切换开关样式
## ============================================================================

## 创建切换开关开启样式
static func create_toggle_on_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = TOGGLE_ON_BG

	# 圆角
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	return style


## 创建切换开关关闭样式
static func create_toggle_off_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = TOGGLE_OFF_BG

	# 圆角
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	return style


## ============================================================================
## 选项按钮样式
## ============================================================================

## 创建选项按钮样式
static func create_option_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = BG_DARK

	style.corner_radius_top_left = CORNER_RADIUS_SMALL
	style.corner_radius_top_right = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_left = CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = CORNER_RADIUS_SMALL

	# 边框
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = BORDER_SUBTLE

	style.content_margin_left = CONTENT_MARGIN_SMALL
	style.content_margin_right = CONTENT_MARGIN_SMALL
	style.content_margin_top = CONTENT_MARGIN_TINY
	style.content_margin_bottom = CONTENT_MARGIN_TINY

	return style


## 创建选项按钮 hover 样式
static func create_option_button_hover_style() -> StyleBoxFlat:
	var style := create_option_button_style()
	style.bg_color = BG_HOVER
	style.border_color = BORDER_LIGHT
	return style


## ============================================================================
## 工具方法
## ============================================================================

## 获取分隔线颜色
static func get_separator_color() -> Color:
	return SEPARATOR_COLOR


## 获取金色主题色
static func get_gold_color() -> Color:
	return GOLD_COLOR


## 获取文字白色
static func get_text_white() -> Color:
	return TEXT_WHITE


## 获取文字灰色
static func get_text_gray() -> Color:
	return TEXT_GRAY


## 获取深色文字（用于金色按钮）
static func get_text_dark() -> Color:
	return TEXT_DARK


## ============================================================================
## 应用样式到节点
## ============================================================================

## 应用滑块样式
static func apply_slider_style(slider: HSlider) -> void:
	if not slider:
		push_error("SettingsPopupStyle: slider is null")
		return

	slider.add_theme_stylebox_override("slider", create_slider_track_style())
	slider.add_theme_stylebox_override("grabber_area", create_slider_fill_style())
	slider.add_theme_stylebox_override("grabber_area_highlight", create_slider_fill_style())
	slider.add_theme_icon_override("grabber", create_slider_grabber_texture())
	slider.add_theme_icon_override("grabber_highlight", create_slider_grabber_highlight_texture())


## 应用主按钮样式
static func apply_primary_button_style(button: Button) -> void:
	if not button:
		push_error("SettingsPopupStyle: button is null")
		return

	button.add_theme_stylebox_override("normal", create_primary_button_style())
	button.add_theme_stylebox_override("hover", create_primary_button_hover_style())
	button.add_theme_stylebox_override("pressed", create_primary_button_pressed_style())
	button.add_theme_stylebox_override("focus", create_primary_button_style())

	button.add_theme_color_override("font_color", TEXT_DARK)
	button.add_theme_color_override("font_hover_color", TEXT_DARK)
	button.add_theme_color_override("font_pressed_color", TEXT_DARK)


## 应用次要按钮样式
static func apply_secondary_button_style(button: Button) -> void:
	if not button:
		push_error("SettingsPopupStyle: button is null")
		return

	button.add_theme_stylebox_override("normal", create_secondary_button_style())
	button.add_theme_stylebox_override("hover", create_secondary_button_hover_style())
	button.add_theme_stylebox_override("pressed", create_secondary_button_pressed_style())
	button.add_theme_stylebox_override("focus", create_secondary_button_style())

	button.add_theme_color_override("font_color", TEXT_GRAY)
	button.add_theme_color_override("font_hover_color", TEXT_WHITE)
	button.add_theme_color_override("font_pressed_color", TEXT_WHITE)


## 应用纯文字按钮样式 (Restore Defaults)
static func apply_text_button_style(button: Button) -> void:
	if not button:
		push_error("SettingsPopupStyle: button is null")
		return

	button.add_theme_stylebox_override("normal", create_text_button_style())
	button.add_theme_stylebox_override("hover", create_text_button_hover_style())
	button.add_theme_stylebox_override("pressed", create_text_button_style())
	button.add_theme_stylebox_override("focus", create_text_button_style())

	button.add_theme_color_override("font_color", TEXT_GRAY)
	button.add_theme_color_override("font_hover_color", TEXT_WHITE)
	button.add_theme_color_override("font_pressed_color", TEXT_WHITE)


## 应用 footer 面板样式
static func apply_footer_panel_style(panel: PanelContainer) -> void:
	if not panel:
		push_error("SettingsPopupStyle: panel is null")
		return

	panel.add_theme_stylebox_override("panel", create_footer_panel_style())


## 应用选项按钮样式
static func apply_option_button_style(option: OptionButton) -> void:
	if not option:
		push_error("SettingsPopupStyle: option button is null")
		return

	option.add_theme_stylebox_override("normal", create_option_button_style())
	option.add_theme_stylebox_override("hover", create_option_button_hover_style())
	option.add_theme_stylebox_override("pressed", create_option_button_style())
	option.add_theme_stylebox_override("focus", create_option_button_style())

	option.add_theme_color_override("font_color", TEXT_WHITE)
	option.add_theme_color_override("font_hover_color", GOLD_COLOR)
