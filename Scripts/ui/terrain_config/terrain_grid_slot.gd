## 地形网格槽位
## 用于显示战场网格中的单个槽位，支持拖拽和 hover 动画
extends Panel
class_name TerrainGridSlot

## 信号：接收拖拽数据
signal drop_data_received(slot: TerrainGridSlot, data: Dictionary)

## ============================================================================
## 导出变量
## ============================================================================

## 槽位行索引
@export var grid_row: int = 0

## 槽位列索引
@export var grid_col: int = 0

## ============================================================================
## 节点引用
## ============================================================================

@onready var _icon: TextureRect = $CenterContainer/Icon

## ============================================================================
## 内部变量
## ============================================================================

## 当前地形类型（-1 表示空）
var _current_terrain: int = -1

## 是否正在 hover
var _is_hovering: bool = false

## 选中状态
var is_selected: bool = false

## 拖拽高亮状态
var is_drag_highlighted: bool = false

## 当前拖拽高亮的槽位（静态）
static var _current_drag_highlighted: TerrainGridSlot = null

## 放置动画 tween
var _place_tween: Tween = null

## 基础位置
var _base_position: Vector2 = Vector2.ZERO

## ============================================================================
## Godot 生命周期
## ============================================================================

func _ready() -> void:
	_base_position = position
	_setup_panel_style()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_on_mouse_enter()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_on_mouse_exit()
	elif what == NOTIFICATION_DRAG_END:
		_clear_drag_highlight()


## ============================================================================
## 公共方法
## ============================================================================

## 设置网格位置
func set_grid_position(row: int, col: int) -> void:
	grid_row = row
	grid_col = col


## 获取网格行
func get_grid_row() -> int:
	return grid_row


## 获取网格列
func get_grid_col() -> int:
	return grid_col


## 设置地形
func set_terrain(tile_type: int) -> void:
	_current_terrain = tile_type
	_update_icon()


## 获取当前地形
func get_terrain() -> int:
	return _current_terrain


## 清除地形
func clear_terrain() -> void:
	set_terrain(-1)


## 设置选中状态
func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	_update_visual_state()


## 获取选中状态
func get_selected() -> bool:
	return is_selected


## 播放放置动画
func play_place_animation() -> void:
	if _place_tween and _place_tween.is_valid():
		_place_tween.kill()

	_place_tween = create_tween()
	_place_tween.set_parallel(false)

	# 缩小动画
	_place_tween.tween_property(_icon, "scale", Vector2(0.8, 0.8), 0.1)
	_place_tween.tween_property(_icon, "scale", Vector2(1.1, 1.1), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_place_tween.tween_property(_icon, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	# 发光效果
	_play_glow_effect()


## 播放清除动画
func play_clear_animation() -> void:
	if _place_tween and _place_tween.is_valid():
		_place_tween.kill()

	_place_tween = create_tween()
	_place_tween.set_parallel(true)

	# 淡出
	_place_tween.tween_property(_icon, "modulate:a", 0.0, 0.2)
	_place_tween.tween_property(_icon, "scale", Vector2(0.5, 0.5), 0.2)


## ============================================================================
## 拖拽功能
## ============================================================================

## 是否可以接收拖拽数据
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("tile_type"):
		_clear_drag_highlight()
		_show_drag_highlight()
		return true
	return false


## 处理拖拽数据
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_hide_drag_highlight()
	if data is Dictionary and data.has("tile_type"):
		drop_data_received.emit(self, data)


## 获取拖拽数据
func _get_drag_data(_at_position: Vector2) -> Variant:
	# 只有已放置地形的槽位才能拖拽
	if _current_terrain < 0:
		return null

	# 创建拖拽数据
	var drag_data: Dictionary = {
		"source": self,
		"source_type": "grid_slot",  # 标识来源是网格槽位
		"tile_type": _current_terrain as TileConstants.TileType,
		"from_row": grid_row,
		"from_col": grid_col,
	}

	# 创建拖拽预览
	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return drag_data


## 创建拖拽预览
func _create_drag_preview() -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(80, 80)  # 修改：50→80
	container.z_index = 1000

	# 背景
	var bg := Panel.new()
	bg.custom_minimum_size = Vector2(80, 80)  # 修改：50→80
	container.add_child(bg)

	# 边框样式
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.87, 0.7, 0.16, 0.2)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.87, 0.7, 0.16, 1)
	style.set_corner_radius_all(6)
	bg.add_theme_stylebox_override("panel", style)

	# 图标
	if _icon.texture:
		var icon_rect := TextureRect.new()
		icon_rect.texture = _icon.texture
		icon_rect.custom_minimum_size = Vector2(68, 68)  # 修改：42→68
		icon_rect.position = Vector2(6, 6)  # 修改：4→6
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(icon_rect)

	return container


## ============================================================================
## 内部方法
## ============================================================================

## 设置面板样式
func _setup_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.16, 0.5)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.24, 0.3, 0.8)
	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)


## 更新图标显示
func _update_icon() -> void:
	if _current_terrain < 0:
		_icon.texture = null
		_icon.modulate = Color.TRANSPARENT
	else:
		var type: TileConstants.TileType = _current_terrain as TileConstants.TileType
		var data: TileBlockData = _get_tile_data_for_type(type)
		if data:
			# 优先使用 SVG 图标
			if not data.icon_path.is_empty():
				_icon.texture = load(data.icon_path)
			elif data.texture:
				_icon.texture = data.texture
			_icon.modulate = data.main_color  # 关键：应用主色
	_update_visual_state()  # 应用完整颜色状态


## 获取地块数据
func _get_tile_data_for_type(type: TileConstants.TileType) -> TileBlockData:
	return tileDatabase.get_tile_data(type)


## 更新视觉状态（根据选中、悬停、拖拽高亮状态）
func _update_visual_state() -> void:
	if _current_terrain < 0:
		return

	var data: TileBlockData = _get_tile_data_for_type(_current_terrain as TileConstants.TileType)
	if not data:
		return

	var final_border_color: Color
	var final_icon_color: Color

	# 优先级：选中 > 拖拽 > 悬停 > 默认
	if is_selected:
		final_border_color = data.accent_color
		final_icon_color = data.accent_color
	elif is_drag_highlighted:
		final_border_color = Color(1.2, 1.2, 0.8)
		final_icon_color = data.main_color
	elif _is_hovering:
		final_border_color = data.hover_color
		final_icon_color = data.main_color
	else:
		final_border_color = data.border_color
		final_icon_color = data.main_color

	_apply_colors_to_panel(final_border_color, final_icon_color)


## 应用颜色到面板
func _apply_colors_to_panel(border_color: Color, icon_color: Color) -> void:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	if not style:
		style = StyleBoxFlat.new()

	var new_style := style.duplicate() as StyleBoxFlat
	new_style.border_color = border_color
	remove_theme_stylebox_override("panel")
	add_theme_stylebox_override("panel", new_style)

	if _icon:
		_icon.modulate = icon_color


## 显示拖拽高亮
func _show_drag_highlight() -> void:
	if is_drag_highlighted:
		return
	is_drag_highlighted = true
	_current_drag_highlighted = self
	_update_visual_state()


## 隐藏拖拽高亮
func _hide_drag_highlight() -> void:
	if not is_drag_highlighted:
		return
	is_drag_highlighted = false
	_update_visual_state()


## 清除全局拖拽高亮
static func _clear_drag_highlight() -> void:
	if _current_drag_highlighted:
		_current_drag_highlighted._hide_drag_highlight()
		_current_drag_highlighted = null


## 鼠标进入
func _on_mouse_enter() -> void:
	_is_hovering = true
	_update_visual_state()


## 鼠标离开
func _on_mouse_exit() -> void:
	_is_hovering = false
	_update_visual_state()


## 播放发光效果
func _play_glow_effect() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	# 闪烁发光效果
	tween.tween_method(_set_glow_intensity, 0.0, 1.0, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_glow_intensity, 1.0, 0.0, 0.2).set_ease(Tween.EASE_IN).set_delay(0.15)


## 设置发光强度
func _set_glow_intensity(intensity: float) -> void:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	if style is StyleBoxFlat:
		var new_style := style.duplicate() as StyleBoxFlat
		new_style.shadow_color = Color(0.87, 0.7, 0.16, intensity * 0.4)
		new_style.shadow_size = int(6 + intensity * 4)
		add_theme_stylebox_override("panel", new_style)
