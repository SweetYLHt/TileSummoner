## 样式化按钮组件
##
## 支持 6 种按钮类型：PRIMARY, DEFAULT, SECONDARY, DANGER, TEXT, FILLED
## 可通过 @export 属性配置按钮类型和图标
extends RefCounted
class_name StyledButton


## ============================================================================
## 枚举
## ============================================================================

enum ButtonType {
	PRIMARY,    ## 主要按钮 - 金色左边框，深色背景（主菜单用）
	DEFAULT,    ## 默认按钮 - 灰色左边框，深色背景
	SECONDARY,  ## 次要按钮 - 透明背景，四边边框
	DANGER,     ## 危险按钮 - 红色 hover 效果
	TEXT,       ## 纯文字按钮 - 无边框
	FILLED,     ## 填充按钮 - 金色填充背景，深色文字（Save Changes 用）
}


## ============================================================================
## 公共静态方法
## ============================================================================

## 创建常态样式
static func create_normal_style(type: ButtonType) -> StyleBoxFlat:
	match type:
		ButtonType.PRIMARY:
			return _create_accent_style(UIThemeConstants.BG_DARK, UIThemeConstants.GOLD)
		ButtonType.DEFAULT:
			return _create_accent_style(UIThemeConstants.BG_DARK, UIThemeConstants.BORDER_GRAY)
		ButtonType.SECONDARY:
			return _create_bordered_style(Color(0, 0, 0, 0), UIThemeConstants.BORDER_LIGHT)
		ButtonType.DANGER:
			return _create_accent_style(UIThemeConstants.BG_DARK, UIThemeConstants.BORDER_GRAY)
		ButtonType.TEXT:
			return _create_text_style()
		ButtonType.FILLED:
			return _create_filled_style(UIThemeConstants.GOLD)

	return _create_accent_style(UIThemeConstants.BG_DARK, UIThemeConstants.BORDER_GRAY)


## 创建 hover 样式
static func create_hover_style(type: ButtonType) -> StyleBoxFlat:
	match type:
		ButtonType.PRIMARY:
			return _create_accent_style(UIThemeConstants.BG_HOVER, UIThemeConstants.GOLD_BRIGHT)
		ButtonType.DEFAULT:
			return _create_accent_style(UIThemeConstants.BG_HOVER, UIThemeConstants.BORDER_GRAY_LIGHT)
		ButtonType.SECONDARY:
			return _create_bordered_style(UIThemeConstants.BG_HOVER_LIGHT, UIThemeConstants.TEXT_WHITE)
		ButtonType.DANGER:
			return _create_accent_style(UIThemeConstants.BG_HOVER_RED, UIThemeConstants.RED_HOVER)
		ButtonType.TEXT:
			return _create_text_hover_style()
		ButtonType.FILLED:
			return _create_filled_style(UIThemeConstants.GOLD_BRIGHT)

	return _create_accent_style(UIThemeConstants.BG_HOVER, UIThemeConstants.BORDER_GRAY_LIGHT)


## 创建按下样式
static func create_pressed_style(type: ButtonType) -> StyleBoxFlat:
	var style := create_hover_style(type)
	style.bg_color = style.bg_color.darkened(0.1)
	return style


## 创建禁用样式
static func create_disabled_style() -> StyleBoxFlat:
	var style := _create_accent_style(
		Color(UIThemeConstants.BG_DARK.r, UIThemeConstants.BG_DARK.g, UIThemeConstants.BG_DARK.b, 0.4),
		Color(UIThemeConstants.BORDER_GRAY.r, UIThemeConstants.BORDER_GRAY.g, UIThemeConstants.BORDER_GRAY.b, 0.3)
	)
	return style


## 将样式应用到按钮
static func apply_to_button(button: Button, type: ButtonType) -> void:
	if not button:
		push_error("StyledButton: button is null")
		return

	button.add_theme_stylebox_override("normal", create_normal_style(type))
	button.add_theme_stylebox_override("hover", create_hover_style(type))
	button.add_theme_stylebox_override("pressed", create_pressed_style(type))
	button.add_theme_stylebox_override("focus", create_normal_style(type))
	button.add_theme_stylebox_override("disabled", create_disabled_style())

	_apply_font_colors(button, type)
	button.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_DEFAULT)

	# 设置对齐方式
	match type:
		ButtonType.PRIMARY, ButtonType.DEFAULT, ButtonType.DANGER:
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		ButtonType.SECONDARY, ButtonType.TEXT, ButtonType.FILLED:
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER


## ============================================================================
## 私有静态方法
## ============================================================================

## 创建左边框强调样式 (PRIMARY, DEFAULT, DANGER)
static func _create_accent_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color

	# 左边框强调
	style.border_width_left = UIThemeConstants.BORDER_WIDTH_LEFT_ACCENT
	style.border_width_right = UIThemeConstants.BORDER_WIDTH
	style.border_width_top = UIThemeConstants.BORDER_WIDTH
	style.border_width_bottom = UIThemeConstants.BORDER_WIDTH
	style.border_color = border_color

	# 右侧圆角
	style.corner_radius_top_left = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS_SMALL

	# 内容边距
	style.content_margin_left = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_right = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_SMALL

	return style


## 创建四边边框样式 (SECONDARY)
static func _create_bordered_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color

	# 四边统一边框
	style.border_width_left = UIThemeConstants.BORDER_WIDTH
	style.border_width_right = UIThemeConstants.BORDER_WIDTH
	style.border_width_top = UIThemeConstants.BORDER_WIDTH
	style.border_width_bottom = UIThemeConstants.BORDER_WIDTH
	style.border_color = border_color

	# 四角圆角
	style.corner_radius_top_left = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_bottom_left = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS_SMALL

	# 内容边距
	style.content_margin_left = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_right = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_SMALL

	return style


## 创建纯文字按钮样式 (TEXT)
static func _create_text_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)

	# 无边框
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0

	# 内容边距
	style.content_margin_left = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_right = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_TINY
	style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_TINY

	return style


## 创建纯文字按钮 hover 样式
static func _create_text_hover_style() -> StyleBoxFlat:
	var style := _create_text_style()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.05)
	return style


## 创建填充按钮样式 (FILLED) - 金色填充背景
static func _create_filled_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color

	# 无边框
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0

	# 四角圆角
	style.corner_radius_top_left = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_bottom_left = UIThemeConstants.CORNER_RADIUS_SMALL
	style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS_SMALL

	# 内容边距
	style.content_margin_left = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_right = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_SMALL

	return style


## 应用字体颜色
static func _apply_font_colors(button: Button, type: ButtonType) -> void:
	match type:
		ButtonType.PRIMARY:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.GOLD)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.GOLD_BRIGHT)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
		ButtonType.DEFAULT:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_GRAY_WHITE)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
		ButtonType.SECONDARY:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_GRAY_LIGHT)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
		ButtonType.DANGER:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_GRAY)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.RED_TEXT)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.RED_TEXT)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
		ButtonType.TEXT:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_GRAY_LIGHT)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.TEXT_WHITE)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
		ButtonType.FILLED:
			button.add_theme_color_override("font_color", UIThemeConstants.TEXT_DARK)
			button.add_theme_color_override("font_hover_color", UIThemeConstants.TEXT_DARK)
			button.add_theme_color_override("font_pressed_color", UIThemeConstants.TEXT_DARK)
			button.add_theme_color_override("font_disabled_color",
				Color(UIThemeConstants.TEXT_GRAY.r, UIThemeConstants.TEXT_GRAY.g, UIThemeConstants.TEXT_GRAY.b, 0.4))
