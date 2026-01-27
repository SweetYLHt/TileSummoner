## UI 颜色工具类
## 提供 UI 组件的颜色计算功能
extends RefCounted
class_name UIColorUtils

## ============================================================================
## 常量定义
## ============================================================================

## 默认背景亮度比例（30%）
const DEFAULT_BG_BRIGHTNESS: float = 0.3

## 默认背景透明度（30%）
const DEFAULT_BG_ALPHA: float = 0.3

## 边框变亮比例
const BORDER_LIGHTEN_RATIO: float = 0.5

## ============================================================================
## 静态方法
## ============================================================================

## 计算深色半透明背景色
## 根据主色计算适合作为背景的深色半透明颜色
## @param main_color: 主颜色（地形的 main_color）
## @param brightness: 亮度比例，默认 0.3（降低到 30%）
## @param alpha: 透明度，默认 0.3（30% 不透明）
## @return: 计算后的背景颜色
static func calculate_bg_color(
	main_color: Color,
	brightness: float = DEFAULT_BG_BRIGHTNESS,
	alpha: float = DEFAULT_BG_ALPHA
) -> Color:
	return Color(
		main_color.r * brightness,
		main_color.g * brightness,
		main_color.b * brightness,
		alpha
	)


## 计算图标容器边框色
## 基于主色计算半透明边框颜色
## @param main_color: 主颜色
## @param alpha: 透明度，默认 0.5
## @return: 边框颜色
static func calculate_icon_border_color(
	main_color: Color,
	alpha: float = 0.5
) -> Color:
	return Color(
		main_color.r * BORDER_LIGHTEN_RATIO,
		main_color.g * BORDER_LIGHTEN_RATIO,
		main_color.b * BORDER_LIGHTEN_RATIO,
		alpha
	)


## 计算发光颜色
## 基于主色计算发光效果使用的颜色
## @param main_color: 主颜色
## @param intensity: 发光强度，默认 0.5
## @return: 发光颜色
static func calculate_glow_color(
	main_color: Color,
	intensity: float = 0.5
) -> Color:
	return Color(
		main_color.r,
		main_color.g,
		main_color.b,
		intensity
	)


## 计算 hover 变亮颜色
## 将颜色变亮用于 hover 效果
## @param base_color: 基础颜色
## @param brighten_amount: 变亮量，默认 0.1
## @return: 变亮后的颜色
static func calculate_hover_brighten_color(
	base_color: Color,
	brighten_amount: float = 0.1
) -> Color:
	return Color(
		minf(base_color.r + brighten_amount, 1.0),
		minf(base_color.g + brighten_amount, 1.0),
		minf(base_color.b + brighten_amount, 1.0),
		base_color.a
	)


## 创建地形专属样式
## 根据地形数据创建 StyleBoxFlat
## @param main_color: 主颜色
## @param with_glow: 是否添加发光效果
## @param glow_size: 发光尺寸
## @return: StyleBoxFlat 样式
static func create_terrain_stylebox(
	main_color: Color,
	with_glow: bool = false,
	glow_size: int = 8
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg_color := calculate_bg_color(main_color)
	var border_color := calculate_icon_border_color(main_color)

	style.bg_color = bg_color
	style.set_border_width_all(1)
	style.border_color = border_color
	style.set_corner_radius_all(4)

	if with_glow:
		style.shadow_color = calculate_glow_color(main_color)
		style.shadow_size = glow_size
		style.shadow_offset = Vector2.ZERO

	return style
