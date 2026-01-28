## 玻璃面板组件
##
## 支持 3 种变体：DEFAULT, SIDEBAR, FOOTER
## 提供玻璃拟态风格的面板样式
extends RefCounted
class_name GlassPanel


## ============================================================================
## 枚举
## ============================================================================

enum PanelVariant {
	DEFAULT,  ## 默认面板 - 玻璃背景，右侧圆角
	SIDEBAR,  ## 侧边栏面板 - 与 DEFAULT 类似
	FOOTER,   ## 底栏面板 - 半透明黑色，顶部边框
}


## ============================================================================
## 常量
## ============================================================================

const ACCENT_BAR_WIDTH := 4


## ============================================================================
## 公共静态方法
## ============================================================================

## 创建面板样式
static func create_style(variant: PanelVariant) -> StyleBoxFlat:
	match variant:
		PanelVariant.DEFAULT, PanelVariant.SIDEBAR:
			return _create_glass_style()
		PanelVariant.FOOTER:
			return _create_footer_style()

	return _create_glass_style()


## 创建强调条样式
static func create_accent_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style


## 将样式应用到面板 (支持 Panel 和 PanelContainer)
static func apply_to_panel(panel: Control, variant: PanelVariant) -> void:
	if not panel:
		push_error("GlassPanel: panel is null")
		return

	panel.add_theme_stylebox_override("panel", create_style(variant))


## ============================================================================
## 私有静态方法
## ============================================================================

## 创建玻璃风格样式 (DEFAULT, SIDEBAR)
static func _create_glass_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIThemeConstants.GLASS_BG

	# 右侧圆角，左侧直角（与金色边框配合）
	style.corner_radius_top_left = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_top_right = UIThemeConstants.CORNER_RADIUS
	style.corner_radius_bottom_right = UIThemeConstants.CORNER_RADIUS

	# 细微边框（不含左侧）
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_width_left = 0
	style.border_color = UIThemeConstants.BORDER_SUBTLE

	return style


## 创建底栏样式 (FOOTER)
static func _create_footer_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIThemeConstants.FOOTER_BG

	# 无圆角
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# 仅顶部边框
	style.border_width_top = 1
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.border_color = UIThemeConstants.BORDER_SUBTLE

	# 内容边距
	style.content_margin_left = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_right = UIThemeConstants.CONTENT_MARGIN
	style.content_margin_top = UIThemeConstants.CONTENT_MARGIN_SMALL
	style.content_margin_bottom = UIThemeConstants.CONTENT_MARGIN_SMALL

	return style
