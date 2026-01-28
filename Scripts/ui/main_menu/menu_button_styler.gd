## 主菜单按钮样式工厂
##
## 为主菜单按钮创建赛博朋克风格的 StyleBoxFlat 样式
## 支持 PRIMARY / DEFAULT / DANGER 三种类型
extends RefCounted
class_name MenuButtonStyler


## ============================================================================
## 枚举
## ============================================================================

enum ButtonType { PRIMARY, DEFAULT, DANGER }


## ============================================================================
## 颜色常量
## ============================================================================

const GOLD_COLOR := Color(0.87, 0.7, 0.16, 1.0)          # #dfb22a
const GOLD_BRIGHT := Color(0.94, 0.78, 0.23, 1.0)        # #f0c83a
const GRAY_BORDER := Color(0.267, 0.251, 0.235, 1.0)     # #44403c
const GRAY_BORDER_LIGHT := Color(0.47, 0.44, 0.42, 1.0)  # #78716c
const RED_HOVER := Color(0.8, 0.2, 0.2, 1.0)             # #cc3333
const RED_TEXT := Color(1.0, 0.267, 0.267, 1.0)           # #ff4444

const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_GRAY_WHITE := Color(0.84, 0.83, 0.82, 1.0)    # #d6d3d1
const TEXT_GRAY := Color(0.66, 0.63, 0.62, 1.0)          # #a8a29e

const BG_DARK := Color(0.04, 0.047, 0.059, 1.0)          # #0a0c0f
const BG_HOVER := Color(0.059, 0.067, 0.078, 1.0)        # #0f1114
const BG_HOVER_RED := Color(0.102, 0.039, 0.039, 1.0)    # #1a0a0a

const BORDER_SUBTLE := Color(0.176, 0.184, 0.2, 1.0)     # #2d2f33

const FONT_SIZE := 18
const LEFT_BORDER_WIDTH := 4
const OTHER_BORDER_WIDTH := 1
const CORNER_RADIUS := 6
const CONTENT_MARGIN_LEFT := 24
const CONTENT_MARGIN_RIGHT := 16
const CONTENT_MARGIN_VERTICAL := 14


## ============================================================================
## 公共静态方法
## ============================================================================

## 创建常态样式
static func create_normal_style(type: ButtonType) -> StyleBoxFlat:
	var style := _create_base_style()
	style.bg_color = BG_DARK

	match type:
		ButtonType.PRIMARY:
			style.border_color = GOLD_COLOR
		ButtonType.DEFAULT:
			style.border_color = GRAY_BORDER
		ButtonType.DANGER:
			style.border_color = GRAY_BORDER

	return style


## 创建 hover 样式
static func create_hover_style(type: ButtonType) -> StyleBoxFlat:
	var style := _create_base_style()

	match type:
		ButtonType.PRIMARY:
			style.bg_color = BG_HOVER
			style.border_color = GOLD_BRIGHT
		ButtonType.DEFAULT:
			style.bg_color = BG_HOVER
			style.border_color = GRAY_BORDER_LIGHT
		ButtonType.DANGER:
			style.bg_color = BG_HOVER_RED
			style.border_color = RED_HOVER

	return style


## 创建按下样式
static func create_pressed_style(type: ButtonType) -> StyleBoxFlat:
	var style := create_hover_style(type)
	# 按下时略微加深背景
	style.bg_color = style.bg_color.darkened(0.1)
	return style


## 创建禁用样式
static func create_disabled_style() -> StyleBoxFlat:
	var style := _create_base_style()
	style.bg_color = Color(BG_DARK.r, BG_DARK.g, BG_DARK.b, 0.4)
	style.border_color = Color(GRAY_BORDER.r, GRAY_BORDER.g, GRAY_BORDER.b, 0.3)
	return style


## 将样式应用到按钮
static func apply_to_button(button: Button, type: ButtonType) -> void:
	if not button:
		push_error("MenuButtonStyler: button is null")
		return

	button.add_theme_stylebox_override("normal", create_normal_style(type))
	button.add_theme_stylebox_override("hover", create_hover_style(type))
	button.add_theme_stylebox_override("pressed", create_pressed_style(type))
	button.add_theme_stylebox_override("focus", create_normal_style(type))

	if button.disabled:
		button.add_theme_stylebox_override("disabled", create_disabled_style())
		button.add_theme_color_override("font_disabled_color",
			Color(TEXT_GRAY.r, TEXT_GRAY.g, TEXT_GRAY.b, 0.4))
	else:
		button.add_theme_stylebox_override("disabled", create_disabled_style())

	# 字体颜色
	match type:
		ButtonType.PRIMARY:
			button.add_theme_color_override("font_color", TEXT_WHITE)
			button.add_theme_color_override("font_hover_color", GOLD_COLOR)
			button.add_theme_color_override("font_pressed_color", GOLD_BRIGHT)
		ButtonType.DEFAULT:
			button.add_theme_color_override("font_color", TEXT_GRAY_WHITE)
			button.add_theme_color_override("font_hover_color", TEXT_WHITE)
			button.add_theme_color_override("font_pressed_color", TEXT_WHITE)
		ButtonType.DANGER:
			button.add_theme_color_override("font_color", TEXT_GRAY)
			button.add_theme_color_override("font_hover_color", RED_TEXT)
			button.add_theme_color_override("font_pressed_color", RED_TEXT)

	# 字体大小
	button.add_theme_font_size_override("font_size", FONT_SIZE)

	# 对齐方式: 左对齐
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT


## ============================================================================
## 私有静态方法
## ============================================================================

## 创建基础样式 (共同属性)
static func _create_base_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	# 左边框强调
	style.border_width_left = LEFT_BORDER_WIDTH
	style.border_width_right = OTHER_BORDER_WIDTH
	style.border_width_top = OTHER_BORDER_WIDTH
	style.border_width_bottom = OTHER_BORDER_WIDTH

	# 右侧圆角
	style.corner_radius_top_left = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_top_right = CORNER_RADIUS
	style.corner_radius_bottom_right = CORNER_RADIUS

	# 内容边距
	style.content_margin_left = CONTENT_MARGIN_LEFT
	style.content_margin_right = CONTENT_MARGIN_RIGHT
	style.content_margin_top = CONTENT_MARGIN_VERTICAL
	style.content_margin_bottom = CONTENT_MARGIN_VERTICAL

	return style
