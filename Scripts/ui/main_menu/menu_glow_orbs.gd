## 主菜单发光球体装饰
##
## 管理背景区域的半透明发光球体，提供缓慢浮动动画效果
extends Node2D
class_name MenuGlowOrbs


## ============================================================================
## 常量
## ============================================================================

const ORB_CONFIGS := [
	{
		"color": Color(0.87, 0.7, 0.16, 0.08),   # 金色
		"radius": 160.0,
		"base_position": Vector2(800, 150),
		"float_range": Vector2(0, 30),
		"period": 6.0,
	},
	{
		"color": Color(0.2, 0.6, 0.8, 0.06),      # 青蓝色
		"radius": 200.0,
		"base_position": Vector2(900, 500),
		"float_range": Vector2(0, 40),
		"period": 8.0,
	},
	{
		"color": Color(0.5, 0.2, 0.7, 0.05),      # 紫色
		"radius": 120.0,
		"base_position": Vector2(700, 350),
		"float_range": Vector2(0, 25),
		"period": 7.0,
	},
]


## ============================================================================
## 成员变量
## ============================================================================

var _orbs: Array[ColorRect] = []
var _tweens: Array[Tween] = []
var _is_animating := false


## ============================================================================
## 生命周期
## ============================================================================

func _ready() -> void:
	_create_orbs()
	start_animations()


## ============================================================================
## 公共方法
## ============================================================================

## 启动浮动动画
func start_animations() -> void:
	if _is_animating:
		return
	_is_animating = true

	for i in range(_orbs.size()):
		_start_orb_animation(i)


## 停止所有动画
func stop_animations() -> void:
	_is_animating = false
	for tween in _tweens:
		if tween and tween.is_valid():
			tween.kill()
	_tweens.clear()


## ============================================================================
## 私有方法
## ============================================================================

## 创建所有球体
func _create_orbs() -> void:
	for config in ORB_CONFIGS:
		var orb := _create_single_orb(config)
		add_child(orb)
		_orbs.append(orb)


## 创建单个球体
func _create_single_orb(config: Dictionary) -> ColorRect:
	var orb := ColorRect.new()
	var diameter: float = config["radius"] * 2.0

	orb.custom_minimum_size = Vector2(diameter, diameter)
	orb.size = Vector2(diameter, diameter)
	orb.position = config["base_position"] - Vector2(config["radius"], config["radius"])

	# 使用大圆角 StyleBoxFlat 模拟圆形
	var style := StyleBoxFlat.new()
	style.bg_color = config["color"]
	style.corner_radius_top_left = int(config["radius"])
	style.corner_radius_top_right = int(config["radius"])
	style.corner_radius_bottom_left = int(config["radius"])
	style.corner_radius_bottom_right = int(config["radius"])
	style.anti_aliasing = true

	orb.add_theme_stylebox_override("panel", style)
	# ColorRect 不支持 stylebox，用 color 设为透明，通过子面板实现
	orb.color = Color.TRANSPARENT
	orb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 改用 Panel 方式
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	orb.add_child(panel)

	return orb


## 启动单个球体的浮动动画
func _start_orb_animation(index: int) -> void:
	if index >= _orbs.size() or index >= ORB_CONFIGS.size():
		return

	var orb := _orbs[index]
	var config: Dictionary = ORB_CONFIGS[index]
	var base_pos: Vector2 = config["base_position"] - Vector2(config["radius"], config["radius"])
	var float_range: Vector2 = config["float_range"]
	var period: float = config["period"]

	var tween := create_tween()
	tween.set_loops()

	# 上浮
	tween.tween_property(orb, "position:y",
		base_pos.y - float_range.y, period * 0.5) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_SINE)

	# 下沉
	tween.tween_property(orb, "position:y",
		base_pos.y + float_range.y, period * 0.5) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_SINE)

	_tweens.append(tween)


## 清理
func _exit_tree() -> void:
	stop_animations()
